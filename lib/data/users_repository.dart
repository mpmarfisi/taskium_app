import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskium/data/interfaces/firebase_user_datasource.dart';
import 'package:taskium/domain/user.dart';

class UsersRepository implements FirebaseUserDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  @override
  Future<User?> getUserByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('username', isEqualTo: username)
          .withConverter(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, _) => user.toFirestore(),
          )
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return querySnapshot.docs.first.data();
    } catch (e) {
      throw Exception('Failed to get user with username $username: $e');
    }
  }

  @override
  Future<void> addUser(User user) async {
    try {
      // Check if user already exists
      final existingUser = await getUserByUsername(user.username);
      if (existingUser != null) {
        throw Exception('User with username "${user.username}" already exists');
      }

      await _firestore
          .collection(_collection)
          .withConverter(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, _) => user.toFirestore(),
          )
          .add(user);
    } catch (e) {
      throw Exception('Failed to add user: $e');
    }
  }

  @override
  Future<void> updateUser(User user) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('username', isEqualTo: user.username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User with username ${user.username} not found');
      }

      final docId = querySnapshot.docs.first.id;
      await _firestore
          .collection(_collection)
          .doc(docId)
          .withConverter(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, _) => user.toFirestore(),
          )
          .set(user);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  @override
  Future<void> deleteUser(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('User with username $username not found');
      }

      final docId = querySnapshot.docs.first.id;
      await _firestore.collection(_collection).doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to delete user with username $username: $e');
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .withConverter(
            fromFirestore: User.fromFirestore,
            toFirestore: (User user, _) => user.toFirestore(),
          )
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get all users: $e');
    }
  }
}
