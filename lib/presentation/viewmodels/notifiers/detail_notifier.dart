import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskium/data/tasks_repository.dart';
import 'package:taskium/domain/task.dart';
import 'package:taskium/presentation/viewmodels/states/detail_state.dart';

final detailTasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

class DetailNotifier extends Notifier<DetailState> {
  late final TasksRepository _tasksRepository;

  @override
  DetailState build() {
    _tasksRepository = ref.read(detailTasksRepositoryProvider);
    return const DetailState(screenState: DetailScreenState.idle);
  }

  void initialize(Task task) {
    state = state.copyWith(
      screenState: DetailScreenState.idle,
      task: task,
      errorMessage: null,
      hasChanges: false,
    );
  }

  Future<void> updateTask(Task updatedTask) async {
    try {
      state = state.copyWith(screenState: DetailScreenState.loading);

      await _tasksRepository.updateTask(updatedTask);
      
      state = state.copyWith(
        screenState: DetailScreenState.idle,
        task: updatedTask,
        errorMessage: null,
        hasChanges: true,
      );
    } catch (e) {
      state = state.copyWith(
        screenState: DetailScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteTask() async {
    if (state.task?.id == null) return;

    try {
      state = state.copyWith(screenState: DetailScreenState.deleting);

      await _tasksRepository.deleteTask(state.task!.id!);
      
      state = state.copyWith(
        screenState: DetailScreenState.deleted,
        errorMessage: null,
        hasChanges: true,
      );
    } catch (e) {
      state = state.copyWith(
        screenState: DetailScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void setIdle() {
    state = state.copyWith(screenState: DetailScreenState.idle);
  }

  void clearError() {
    state = state.copyWith(
      screenState: DetailScreenState.idle,
      errorMessage: null,
    );
  }
}

final detailNotifierProvider = NotifierProvider<DetailNotifier, DetailState>(() => DetailNotifier());
        