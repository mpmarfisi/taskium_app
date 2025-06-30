import 'package:taskium/domain/user.dart';

abstract class FirebaseUserDataSource {
  Future<User?> getUserByUsername(String username);
  Future<void> addUser(User user);
  Future<void> updateUser(User user);
  Future<void> deleteUser(String username);
}
