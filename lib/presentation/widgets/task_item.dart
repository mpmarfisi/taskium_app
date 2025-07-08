import 'package:flutter/material.dart';
import 'package:taskium/domain/task.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
  });

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: task.imageUrl != null
            ? _getImage(task.imageUrl!)
            : const Icon(Icons.task, size: 40),
        title: Text(task.title.isNotEmpty ? task.title : 'Untitled Task'),
        subtitle: Text(
          task.description.isNotEmpty ? task.description : 'No description',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _getImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        task.imageUrl!,
        width: 40,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.broken_image,
            size: 40,
            color: Colors.grey,
          );
        },
      ),
    );
  }
}