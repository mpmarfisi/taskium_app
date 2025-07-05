import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskium/data/interfaces/firebase_task_datasource.dart';
import 'package:taskium/domain/task.dart';

class TasksRepository implements FirebaseTaskDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  @override
  Future<List<Task>> getTasks() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .withConverter(
            fromFirestore: Task.fromFirestore,
            toFirestore: (Task task, _) => task.toFirestore(),
          )
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  @override
  Future<List<Task>> getTask(String id) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('id', isEqualTo: id)
          .withConverter(
            fromFirestore: Task.fromFirestore,
            toFirestore: (Task task, _) => task.toFirestore(),
          )
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get task with id $id: $e');
    }
  }

  @override
  Future<List<Task>> getTasksByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .withConverter(
            fromFirestore: Task.fromFirestore,
            toFirestore: (Task task, _) => task.toFirestore(),
          )
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to get tasks for user $userId: $e');
    }
  }

  @override
  Future<void> addTask(Task task) async {
    final tasksCollection = _firestore
        .collection(_collection)
        .withConverter(
          fromFirestore: Task.fromFirestore,
          toFirestore: (Task task, _) => task.toFirestore(),
        );
    try {
      // Use add() to let Firestore generate the document ID
      final docRef = await tasksCollection.add(task);
      // Optionally, update the task with the generated ID if you want to store it in the document
      // await docRef.set(task.copyWith(id: docRef.id));
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final tasksCollection = _firestore
        .collection(_collection)
        .withConverter(
          fromFirestore: Task.fromFirestore,
          toFirestore: (Task task, _) => task.toFirestore(),
        );
    try {
      if (task.id == null) {
        throw Exception('Task ID cannot be null for update operation');
      }
      await tasksCollection.doc(task.id).set(task, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete task with id $id: $e');
    }
  }

  @override
  Future<void> deleteAllTasks() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete all tasks: $e');
    }
  }

  @override
  Future<void> deleteTasksByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete tasks for user $userId: $e');
    }
  }
}
