import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskium/domain/user.dart';
import 'package:taskium/presentation/viewmodels/notifiers/profile_notifier.dart';
import 'package:taskium/presentation/viewmodels/states/profile_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.username});

  final String username;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController bornDateController;
  late TextEditingController imageUrlController;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    usernameController = TextEditingController();
    bornDateController = TextEditingController();
    imageUrlController = TextEditingController();
    
    // Load user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(profileNotifierProvider.notifier).loadUser(widget.username);
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    bornDateController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  void _populateControllers(User user) {
    if (!mounted) return;
    nameController.text = user.name;
    emailController.text = user.email;
    usernameController.text = user.username;
    bornDateController.text = user.bornDate.substring(0, 10);
    imageUrlController.text = user.imageUrl ?? '';
    _controllersInitialized = true;
  }

  void _checkIfModified() {
    if (!mounted || !_controllersInitialized) return;

    final user = ref.read(profileNotifierProvider).user;
    if (user != null) {
      final hasChanges = nameController.text != user.name ||
          emailController.text != user.email ||
          bornDateController.text != user.bornDate.substring(0, 10) ||
          imageUrlController.text != (user.imageUrl ?? '');
      
      ref.read(profileNotifierProvider.notifier).setHasChanges(hasChanges);
    }
  }

  Future<void> _saveChanges() async {
    if (!mounted || !(_formKey.currentState?.validate() ?? false)) return;

    final currentUser = ref.read(profileNotifierProvider).user;
    if (currentUser != null) {
      final updatedUser = User(
        username: currentUser.username,
        name: nameController.text,
        email: emailController.text,
        password: currentUser.password,
        imageUrl: imageUrlController.text.isEmpty ? null : imageUrlController.text,
        bornDate: bornDateController.text,
      );
      
      await ref.read(profileNotifierProvider.notifier).updateUser(updatedUser);
    }
  }

  Future<void> _selectBornDate() async {
    if (!mounted) return;
    final user = ref.read(profileNotifierProvider).user;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(user?.bornDate.substring(0, 10) ?? DateTime.now().toString().substring(0, 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && mounted) {
      final formattedDate = '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      bornDateController.text = formattedDate;
      ref.read(profileNotifierProvider.notifier).updateBornDate(formattedDate);
      _checkIfModified();
    }
  }

  Widget _buildAvatar(User user, ProfileNotifier notifier) {
    final hasValidImageUrl = notifier.isValidImageUrl(user.imageUrl) && 
                            !ref.watch(profileNotifierProvider).imageLoadError;
    
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[300],
      backgroundImage: hasValidImageUrl ? NetworkImage(user.imageUrl!) : null,
      onBackgroundImageError: hasValidImageUrl ? (exception, stackTrace) {
        notifier.setImageLoadError(true);
      } : null,
      child: !hasValidImageUrl 
          ? const Icon(Icons.person, size: 50, color: Colors.grey)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final profileNotifier = ref.read(profileNotifierProvider.notifier);

    // Update controllers when user data is loaded
    ref.listen<ProfileState>(profileNotifierProvider, (previous, next) {
      if (mounted && next.user != null && (previous?.user != next.user || !_controllersInitialized)) {
        _populateControllers(next.user!);
      }
      
      // Show success message
      if (mounted && next.screenState.isUpdated && previous?.screenState.isUpdating == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Reset state to idle to prevent snackbar from showing again on rebuild
        WidgetsBinding.instance.addPostFrameCallback((_) {
          profileNotifier.setIdle();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: profileState.screenState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${profileState.errorMessage}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => profileNotifier.loadUser(widget.username),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        updating: () => Stack(
          children: [
            _buildProfileForm(profileState, profileNotifier),
            const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
        updated: () => _buildProfileForm(profileState, profileNotifier),
        idle: () => _buildProfileForm(profileState, profileNotifier),
      ),
    );
  }

  Widget _buildProfileForm(ProfileState profileState, ProfileNotifier profileNotifier) {
    final user = profileState.user;
    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildAvatar(user, profileNotifier),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
                onChanged: (_) => _checkIfModified(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: usernameController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onChanged: (_) => _checkIfModified(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: bornDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Born Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selectBornDate,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  border: const OutlineInputBorder(),
                  helperText: 'Enter a valid image URL (jpg, png, gif, etc.)',
                  suffixIcon: imageUrlController.text.isNotEmpty
                      ? (profileNotifier.isValidImageUrl(imageUrlController.text)
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.error, color: Colors.red))
                      : null,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && !profileNotifier.isValidImageUrl(value)) {
                    return 'Please enter a valid image URL';
                  }
                  return null;
                },
                onChanged: (value) {
                  _checkIfModified();
                  // Reset image load error when URL changes
                  if (profileState.imageLoadError) {
                    profileNotifier.setImageLoadError(false);
                  }
                },
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: profileState.hasChanges && !profileState.screenState.isUpdating
                      ? _saveChanges
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: profileState.screenState.isUpdating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
