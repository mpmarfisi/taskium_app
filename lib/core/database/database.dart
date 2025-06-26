// required package imports
import 'dart:async';

import 'package:floor/floor.dart';
import 'package:taskium/data/user_dao.dart';
import 'package:taskium/domain/user.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:taskium/domain/task.dart';
import 'package:taskium/data/tasks_dao.dart';

part 'database.g.dart'; // el código generado va a estar en el .g.dart

@Database(version: 1, entities: [Task, User])
abstract class AppDatabase extends FloorDatabase {
  TasksDao get tasksDao;
  UserDao get userDao;

  static Future<AppDatabase> create(String name) {
    return $FloorAppDatabase.databaseBuilder(name).addCallback(Callback(
      onCreate: (database, version) async {
        await _prepopulate(database);
        // await _saveAssetsInDevice();
      },
    )).build();
  }

  static Future<void> _prepopulate(sqflite.DatabaseExecutor database) async {
    final users = [
      User(
        username: 'user123',
        name: 'User Name1',
        email: 'user@example.com',
        password: 'pass123',
        bornDate: DateTime(1990, 1, 1).toString(),
      ),
      User(
        username: 'user456',
        name: 'User Name2',
        email: 'user@example.com',
        password: 'pass456',
        bornDate: DateTime(1990, 1, 1).toString(),
      ),
    ];

    for (final user in users) {
      await database.insert('User', {
        'username': user.username,
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'imageUrl': user.imageUrl,
        'bornDate': user.bornDate,
      });
    }
  }
}