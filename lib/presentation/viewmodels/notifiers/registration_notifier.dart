import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskium/data/users_repository.dart';
import 'package:taskium/domain/user.dart';
import 'package:taskium/presentation/viewmodels/states/registration_state.dart';

final registrationUsersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

class RegistrationNotifier extends AutoDisposeNotifier<RegistrationState> {
  late final UsersRepository _usersRepository;
  late final auth.FirebaseAuth _firebaseAuth;

  @override
  RegistrationState build() {
    _usersRepository = ref.read(registrationUsersRepositoryProvider);
    _firebaseAuth = auth.FirebaseAuth.instance;
    return const RegistrationState();
  }

  Future<void> registerUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String bornDate,
  }) async {
    try {
      state = state.copyWith(screenState: RegistrationScreenState.registering);

      final existingUser = await _usersRepository.getUserByUsername(username);
      if (existingUser != null) {
        throw Exception('Username already exists. Please choose another one.');
      }
      
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = User(
        username: username,
        name: name,
        email: email,
        bornDate: bornDate,
      );
      await _usersRepository.addUser(newUser);

      state = state.copyWith(screenState: RegistrationScreenState.success, errorMessage: null);
    } on auth.FirebaseAuthException catch (e) {
      state = state.copyWith(
        screenState: RegistrationScreenState.error,
        errorMessage: e.message ?? 'An unknown authentication error occurred.',
      );
    } catch (e) {
      state = state.copyWith(
        screenState: RegistrationScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void setBornDate(String bornDate) {
    state = state.copyWith(bornDate: bornDate);
  }
}

final registrationNotifierProvider = AutoDisposeNotifierProvider<RegistrationNotifier, RegistrationState>(
  () => RegistrationNotifier(),
);
