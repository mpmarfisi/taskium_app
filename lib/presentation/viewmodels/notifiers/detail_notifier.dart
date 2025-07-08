import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:taskium/data/tasks_repository.dart';
import 'package:taskium/domain/task.dart';
import 'package:taskium/presentation/viewmodels/states/detail_state.dart';

final detailTasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepository();
});

class DetailNotifier extends AutoDisposeNotifier<DetailState> {
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
      hasChanges: false,
      shouldPreventNavigation: false, // Reset navigation prevention
      galleryIndex: null, // Reset gallery index on new task
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
        hasChanges: false,
        shouldPreventNavigation: true, // Prevent navigation after delete
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
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf'],
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

  Future<String?> getPdfFile(String url) async {
    try {
      state = state.copyWith(isLoadingPdf: true);
      
      final dir = await getTemporaryDirectory();
      final filename = 'taskium_${url.hashCode}.pdf';
      final file = File('${dir.path}/$filename');
      
      if (await file.exists()) {
        final stat = await file.stat();
        if (stat.size > 0) {
          state = state.copyWith(
            isLoadingPdf: false,
            localFilePath: file.path,
          );
          return file.path;
        }
      }
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        state = state.copyWith(
          isLoadingPdf: false,
          localFilePath: file.path,
        );
        return file.path;
      } else {
        throw Exception('Failed to download PDF: HTTP ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingPdf: false,
        errorMessage: 'Error downloading PDF: $e',
      );
      return null;
    }
  } 

  Future<void> removeAttachment(String url) async {
    final task = state.task;
    if (task == null) return;
    try {
      state = state.copyWith(screenState: DetailScreenState.loading);
      final updatedFiles = List<String>.from(task.files)..remove(url);
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
        files: updatedFiles,
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

  void setGalleryIndex(int index) {
    state = state.copyWith(galleryIndex: index);
  }

  void clearGalleryIndex() {
    state = state.copyWith(galleryIndex: null);
  }

  bool shouldNavigateBack() {
    return state.hasChanges;
  }

  bool shouldPreventNavigation() {
    return state.shouldPreventNavigation;
  }
}

final detailNotifierProvider = AutoDisposeNotifierProvider<DetailNotifier, DetailState>(() => DetailNotifier());
