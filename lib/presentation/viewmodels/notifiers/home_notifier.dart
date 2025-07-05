import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskium/data/tasks_repository.dart';
import 'package:taskium/domain/task.dart';
import 'package:taskium/presentation/viewmodels/states/home_state.dart';

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

class HomeNotifier extends Notifier<HomeState> {
  late final TasksRepository _tasksRepository;

  @override
  HomeState build() {
    _tasksRepository = ref.read(tasksRepositoryProvider);
    return const HomeState(screenState: HomeScreenState.idle);
  }

  Future<void> initialize([String? userId]) async {
    await fetchTasks(userId);
  }

  Future<void> fetchTasks([String? userId]) async {
    try {
      state = state.copyWith(screenState: HomeScreenState.loading);

      final tasks = await _tasksRepository.getTasksByUserId(userId ?? 'user123');

      if (tasks.isEmpty) {
        state = state.copyWith(
          screenState: HomeScreenState.empty,
          tasks: tasks,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          screenState: HomeScreenState.success,
          tasks: tasks,
          errorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        screenState: HomeScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshTasks([String? userId]) async {
    try {
      state = state.copyWith(screenState: HomeScreenState.refreshing);

      final tasks = await _tasksRepository.getTasksByUserId(userId ?? 'user123');

      if (tasks.isEmpty) {
        state = state.copyWith(
          screenState: HomeScreenState.empty,
          tasks: tasks,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          screenState: HomeScreenState.success,
          tasks: tasks,
          errorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        screenState: HomeScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addTask(Task task) async {
    try {
      state = state.copyWith(screenState: HomeScreenState.submitting);

      await _tasksRepository.addTask(task);
      await fetchTasks(task.userId);
    } catch (e) {
      state = state.copyWith(
        screenState: HomeScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      state = state.copyWith(screenState: HomeScreenState.submitting);

      await _tasksRepository.updateTask(task);
      await fetchTasks(task.userId);
    } catch (e) {
      state = state.copyWith(
        screenState: HomeScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteTask(String id, String userId) async {
    try {
      state = state.copyWith(screenState: HomeScreenState.submitting);

      await _tasksRepository.deleteTask(int.parse(id));
      await fetchTasks(userId);
    } catch (e) {
      state = state.copyWith(
        screenState: HomeScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void setIdle() {
    state = state.copyWith(screenState: HomeScreenState.idle);
  }

  void clearError() {
    state = state.copyWith(
      screenState: HomeScreenState.idle,
      errorMessage: null,
    );
  }
}

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(() => HomeNotifier());