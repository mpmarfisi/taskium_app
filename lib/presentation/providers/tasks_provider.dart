

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskium/data/tasks_repository.dart';
import 'package:taskium/domain/task.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

class TasksNotifier extends Notifier<List<Task>> {
  late TasksRepository _tasksRepository;

  @override
  List<Task> build() {
    _tasksRepository = ref.read(tasksRepositoryProvider);
    fetchTasks();
    return [];
  }

  Future<void> fetchTasks() async {
    try {
      final tasks = await _tasksRepository.getTasksByUserId('user123'); // Replace with actual user ID
      state = tasks;
    } catch (e) {
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _tasksRepository.addTask(task);
      await fetchTasks();
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _tasksRepository.updateTask(task);
      await fetchTasks();
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _tasksRepository.deleteTask(int.parse(id));
      await fetchTasks();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}

final taskNotifierProvider = NotifierProvider<TasksNotifier, List<Task>>(() => TasksNotifier());