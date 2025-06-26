import 'package:floor/floor.dart';
import 'package:taskium/domain/user.dart';

@Entity(
  tableName: 'Task',
  foreignKeys: [
    ForeignKey(
      childColumns: ['userId'],
      parentColumns: ['username'],
      entity: User,
      onDelete: ForeignKeyAction.cascade, // Delete tasks if the user is deleted
    ),
  ],
)
class Task {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String title;
  final String description;
  final String? imageUrl;
  final String? dueDate;
  final String category;
  final int priority;
  final int progress;
  final bool isCompleted;
  final String? createdAt;
  final String? completedAt;
  final String userId; // Foreign key to reference the User

  Task({
    this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.dueDate,
    required this.priority,
    this.progress = 0,
    this.category = 'General',
    this.isCompleted = false,
    this.createdAt,
    this.completedAt,
    required this.userId,
  });
}
