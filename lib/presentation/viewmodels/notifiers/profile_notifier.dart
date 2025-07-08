import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskium/data/users_repository.dart';
import 'package:taskium/domain/user.dart';
import 'package:taskium/presentation/viewmodels/states/profile_state.dart';

final profileUsersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

class ProfileNotifier extends AutoDisposeNotifier<ProfileState> {
  late final UsersRepository _usersRepository;

  @override
  ProfileState build() {
    _usersRepository = ref.read(profileUsersRepositoryProvider);
    return const ProfileState(screenState: ProfileScreenState.idle);
  }

  Future<void> loadUser(String username) async {
    try {
      state = state.copyWith(screenState: ProfileScreenState.loading);
      
      final user = await _usersRepository.getUserByUsername(username);
      
      state = state.copyWith(
        screenState: ProfileScreenState.idle,
        user: user,
        errorMessage: null,
        hasChanges: false,
        imageLoadError: false,
      );
    } catch (e) {
      state = state.copyWith(
        screenState: ProfileScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateUser(User user) async {
    try {
      state = state.copyWith(screenState: ProfileScreenState.updating);
      
      await _usersRepository.updateUser(user);
      
      state = state.copyWith(
        screenState: ProfileScreenState.updated,
        user: user,
        errorMessage: null,
        hasChanges: false,
        imageLoadError: false,
      );
    } catch (e) {
      state = state.copyWith(
        screenState: ProfileScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void updateBornDate(String bornDate) {
    if (state.user != null) {
      final updatedUser = User(
        username: state.user!.username,
        name: state.user!.name,
        email: state.user!.email,
        imageUrl: state.user!.imageUrl,
        bornDate: bornDate,
      );
      state = state.copyWith(user: updatedUser);
      _checkForChanges();
    }
  }

  void setHasChanges(bool hasChanges) {
    state = state.copyWith(hasChanges: hasChanges);
  }

  void setImageLoadError(bool hasError) {
    state = state.copyWith(imageLoadError: hasError);
  }

  bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        return false;
      }
      
      final path = uri.path.toLowerCase();
      return path.endsWith('.jpg') || 
             path.endsWith('.jpeg') || 
             path.endsWith('.png') || 
             path.endsWith('.gif') || 
             path.endsWith('.webp') ||
             path.endsWith('.bmp');
    } catch (e) {
      return false;
    }
  }

  void _checkForChanges() {
    // This would need access to the form controllers
    // For now, we'll rely on the UI to call setHasChanges
  }

  void setIdle() {
    if (state.screenState == ProfileScreenState.updated) {
      state = state.copyWith(screenState: ProfileScreenState.idle);
    }
  }

  void clearError() {
    state = state.copyWith(
      screenState: ProfileScreenState.idle,
      errorMessage: null,
    );
  }
}

final profileNotifierProvider = AutoDisposeNotifierProvider<ProfileNotifier, ProfileState>(() => ProfileNotifier());
