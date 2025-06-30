import 'package:taskium/domain/task.dart';

abstract class FirebaseTaskDataSource {
  Future<List<Task>> getTasks();
  Future<List<Task>> getTask(int id);
  Future<List<Task>> getTasksByUserId(String userId);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(int id);
  Future<void> deleteTasksByUserId(String userId);
  Future<void> deleteAllTasks();
}