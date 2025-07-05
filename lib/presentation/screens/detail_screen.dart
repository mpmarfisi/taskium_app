import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskium/domain/task.dart';
import 'package:taskium/presentation/viewmodels/notifiers/detail_notifier.dart';
import 'package:taskium/presentation/viewmodels/states/detail_state.dart';

class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({
    super.key,
    required this.taskId,
    this.task,
  });

  final int taskId;
  final Task? task;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize with the passed task
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.task != null) {
        ref.read(detailNotifierProvider.notifier).initialize(widget.task!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(detailNotifierProvider);
    final detailNotifier = ref.read(detailNotifierProvider.notifier);

    return WillPopScope(
      onWillPop: () async {
        context.pop(detailState.hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Detail'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: detailState.task == null || detailState.screenState.isLoading || detailState.screenState.isDeleting
                  ? null
                  : () async {
                      final updatedTask = await context.push('/edit', extra: {
                        'task': detailState.task,
                        'userId': detailState.task!.userId
                      });
                      if (updatedTask != null) {
                        detailNotifier.updateTask(updatedTask as Task);
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: detailState.task == null || detailState.screenState.isLoading || detailState.screenState.isDeleting
                  ? null
                  : () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Task'),
                            content: const Text('Are you sure you want to delete this task?'),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () async {
                                  context.pop();
                                  await detailNotifier.deleteTask();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
            ),
          ],
        ),
        body: detailState.screenState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          idle: () => detailState.task == null
              ? const Center(child: Text('Task not found'))
              : TaskDetailView(task: detailState.task!),
          error: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${detailState.errorMessage}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => detailNotifier.clearError(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          deleting: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Deleting task...'),
              ],
            ),
          ),
          deleted: () {
            // Navigate back when deleted
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.pop(true);
            });
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 64),
                  SizedBox(height: 16),
                  Text('Task deleted successfully'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class TaskDetailView extends StatelessWidget {
  const TaskDetailView({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        SlideFirstView(task: task),
        SlideSecondView(task: task), // Combined view
      ],
    );
  }
}

class SlideFirstView extends StatelessWidget {
  const SlideFirstView({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                if (task.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                    task.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.grey,
                      );
                    },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                task.title,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const Divider(),
              Text(
                'Description:',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 10),
              Text(
                task.description.isNotEmpty
                    ? task.description
                    : 'No description available.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlideSecondView extends StatelessWidget {
  const SlideSecondView({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              title: const Text('Category'),
              subtitle: Text(task.category),
              leading: const Icon(Icons.category),
            ),
            const Divider(),
            ListTile(
              title: const Text('Priority'),
              subtitle: Text(task.priority.toString()),
              leading: const Icon(Icons.priority_high),
            ),
            const Divider(),
            ListTile(
              title: const Text('Progress'),
              subtitle: Text('${task.progress}%'),
              leading: const Icon(Icons.timeline),
            ),
            const Divider(),
            ListTile(
              title: const Text('Created At'),
              subtitle: Text(task.createdAt?.substring(0, 10) ?? 'N/A'),
              leading: const Icon(Icons.date_range),
            ),
            const Divider(),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(task.dueDate ?? 'N/A'),
              leading: const Icon(Icons.calendar_today),
            ),
            if (task.isCompleted) ...[
              const Divider(),
              ListTile(
                title: const Text('Completed At'),
                subtitle: Text(task.completedAt?.substring(0, 10) ?? 'N/A'),
                leading: const Icon(Icons.check_circle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
  }
}

