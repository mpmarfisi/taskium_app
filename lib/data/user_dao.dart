import 'package:floor/floor.dart';
import 'package:taskium/domain/user.dart';

@dao
abstract class UserDao {
  @Query('SELECT * FROM User')
  Future<List<User>> getAllUsers();

  @Query('SELECT * FROM User WHERE username = :username')
  Future<User?> getUserByUsername(String username);

  @insert
  Future<void> insertUser(User user);

  @update
  Future<void> updateUser(User user);

  @delete
  Future<void> deleteUser(User user);

  Future<void> safeInsertUser(User user) async {
    final existingUser = await getUserByUsername(user.username);
    if (existingUser != null) {
      throw Exception('User with username "${user.username}" already exists.');
    }
    await insertUser(user);
  }
}
