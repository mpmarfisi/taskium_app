import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;

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

  Map<String, dynamic> toFirestore() {
    final map = {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'dueDate': dueDate,
      'category': category,
      'priority': priority,
      'progress': progress,
      'isCompleted': isCompleted,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'userId': userId,
    };
    return map;
  }

  static Task fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Task(
      id: snapshot.id, // Always use the Firestore document ID
      title: data?['title'] ?? '',
      description: data?['description'] ?? '',
      imageUrl: data?['imageUrl'],
      dueDate: data?['dueDate'],
      category: data?['category'] ?? 'General',
      priority: data?['priority'] ?? 0,
      progress: data?['progress'] ?? 0,
      isCompleted: data?['isCompleted'] ?? false,
      createdAt: data?['createdAt'],
      completedAt: data?['completedAt'],
      userId: data?['userId'] ?? '',
    );
  }
}
