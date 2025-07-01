

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskium/data/tasks_repository.dart';
import 'package:taskium/domain/task.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

class TasksNotifier extends AsyncNotifier<List<Task>> {
  late final TasksRepository _tasksRepository;

  @override
  Future<List<Task>> build() async {
    _tasksRepository = ref.read(tasksRepositoryProvider);
    return _tasksRepository.getTasksByUserId('user123'); // replace with actual user ID
  }

  Future<void> fetchTasks() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => _tasksRepository.getTasksByUserId('user123')); // Replace with actual user ID
  }

  Future<void> addTask(Task task) async {
    await _tasksRepository.addTask(task);
    await fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    await _tasksRepository.updateTask(task);
    await fetchTasks();
  }

  Future<void> deleteTask(String id) async {
    await _tasksRepository.deleteTask(int.parse(id));
    await fetchTasks();
  }
}

final taskNotifierProvider = AsyncNotifierProvider<TasksNotifier, List<Task>>(() => TasksNotifier());