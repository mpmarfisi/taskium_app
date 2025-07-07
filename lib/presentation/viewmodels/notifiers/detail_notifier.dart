import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:file_picker/file_picker.dart';
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
    print('DetailNotifier: Initializing with task: ${task.id} - ${task.title}'); // Debug print
    state = state.copyWith(
      screenState: DetailScreenState.idle,
      task: task,
      errorMessage: null,
      hasChanges: false, // Always reset hasChanges
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
        hasChanges: false, // Don't trigger another pop
      );
    } catch (e) {
      state = state.copyWith(
        screenState: DetailScreenState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> uploadFile() async {
    final task = state.task;
    if (task == null) return;
    try {
      state = state.copyWith(screenState: DetailScreenState.loading);
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) {
        state = state.copyWith(screenState: DetailScreenState.idle);
        return;
      }
      final file = result.files.first;
      final storageRef = storage.FirebaseStorage.instance
          .ref()
          .child('tasks/${task.id ?? 'unknown'}/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
      final uploadTask = await storageRef.putData(file.bytes!);
      final url = await uploadTask.ref.getDownloadURL();

      // Update task with new file URL
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        imageUrl: task.imageUrl,
        dueDate: task.dueDate,
        category: task.category,
        priority: task.priority,
        progress: task.progress,
        isCompleted: task.isCompleted,
        createdAt: task.createdAt,
        completedAt: task.completedAt,
        userId: task.userId,
        files: [...task.files, url],
      );
      await _tasksRepository.updateTask(updatedTask);
      state = state.copyWith(
        screenState: DetailScreenState.idle,
        task: updatedTask,
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
