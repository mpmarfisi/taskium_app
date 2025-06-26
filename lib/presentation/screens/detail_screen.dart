import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskium/domain/task.dart';
import 'package:taskium/main.dart';

class DetailScreen extends StatefulWidget{
  const DetailScreen({
    super.key,
    required this.taskId,
  });

  final int taskId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Task? task;
  bool isLoading = true;
  bool hasChanges = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      final fetchedTask = await database.tasksDao.getTaskById(widget.taskId);
      if (fetchedTask == null) {
        setState(() {
          errorMessage = 'Task not found.';
          isLoading = false;
        });
      } else {
        setState(() {
          task = fetchedTask;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.pop(hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Detail'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: task == null ? null : () async {
                final updatedTask = await context.push('/edit', extra: {'task': task, 'userId': task!.userId});
                if (updatedTask != null) {
                  await database.tasksDao.updateTask(updatedTask as Task);
                  setState(() {
                    task = updatedTask;
                    hasChanges = true;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: task == null ? null : () async {
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
                                  await database.tasksDao.deleteTask(task!);
                                  context.pop();
                                  context.pop(true);
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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : TaskDetailView(task: task!),
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

