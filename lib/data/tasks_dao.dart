import 'package:floor/floor.dart';
import 'package:taskium/domain/task.dart';

@dao
abstract class TasksDao {
  @Query('SELECT * FROM Task')
  Future<List<Task>> getAllTasks();

  @Query('SELECT * FROM Task WHERE id = :id')
  Future<Task?> getTaskById(String id);

  @Query('SELECT * FROM Task WHERE userId = :userId')
  Future<List<Task>> getTasksByUserId(String userId);

  @Query('SELECT * FROM Task WHERE id = :id AND userId = :userId')
  Future<Task?> getTaskByIdAndUserId(String id, String userId);

  @insert
  Future<void> insertTask(Task task);

  @update
  Future<void> updateTask(Task task);

  @delete
  Future<void> deleteTask(Task task);
}


