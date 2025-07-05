// // GENERATED CODE - DO NOT MODIFY BY HAND

// part of 'database.dart';

// // **************************************************************************
// // FloorGenerator
// // **************************************************************************

// abstract class $AppDatabaseBuilderContract {
//   /// Adds migrations to the builder.
//   $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

//   /// Adds a database [Callback] to the builder.
//   $AppDatabaseBuilderContract addCallback(Callback callback);

//   /// Creates the database and initializes it.
//   Future<AppDatabase> build();
// }

// // ignore: avoid_classes_with_only_static_members
// class $FloorAppDatabase {
//   /// Creates a database builder for a persistent database.
//   /// Once a database is built, you should keep a reference to it and re-use it.
//   static $AppDatabaseBuilderContract databaseBuilder(String name) =>
//       _$AppDatabaseBuilder(name);

//   /// Creates a database builder for an in memory database.
//   /// Information stored in an in memory database disappears when the process is killed.
//   /// Once a database is built, you should keep a reference to it and re-use it.
//   static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
//       _$AppDatabaseBuilder(null);
// }

// class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
//   _$AppDatabaseBuilder(this.name);

//   final String? name;

//   final List<Migration> _migrations = [];

//   Callback? _callback;

//   @override
//   $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
//     _migrations.addAll(migrations);
//     return this;
//   }

//   @override
//   $AppDatabaseBuilderContract addCallback(Callback callback) {
//     _callback = callback;
//     return this;
//   }

//   @override
//   Future<AppDatabase> build() async {
//     final path = name != null
//         ? await sqfliteDatabaseFactory.getDatabasePath(name!)
//         : ':memory:';
//     final database = _$AppDatabase();
//     database.database = await database.open(
//       path,
//       _migrations,
//       _callback,
//     );
//     return database;
//   }
// }

// class _$AppDatabase extends AppDatabase {
//   _$AppDatabase([StreamController<String>? listener]) {
//     changeListener = listener ?? StreamController<String>.broadcast();
//   }

//   TasksDao? _tasksDaoInstance;

//   UserDao? _userDaoInstance;

//   Future<sqflite.Database> open(
//     String path,
//     List<Migration> migrations, [
//     Callback? callback,
//   ]) async {
//     final databaseOptions = sqflite.OpenDatabaseOptions(
//       version: 1,
//       onConfigure: (database) async {
//         await database.execute('PRAGMA foreign_keys = ON');
//         await callback?.onConfigure?.call(database);
//       },
//       onOpen: (database) async {
//         await callback?.onOpen?.call(database);
//       },
//       onUpgrade: (database, startVersion, endVersion) async {
//         await MigrationAdapter.runMigrations(
//             database, startVersion, endVersion, migrations);

//         await callback?.onUpgrade?.call(database, startVersion, endVersion);
//       },
//       onCreate: (database, version) async {
//         await database.execute(
//             'CREATE TABLE IF NOT EXISTS `Task` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `imageUrl` TEXT, `dueDate` TEXT, `category` TEXT NOT NULL, `priority` INTEGER NOT NULL, `progress` INTEGER NOT NULL, `isCompleted` INTEGER NOT NULL, `createdAt` TEXT, `completedAt` TEXT, `userId` TEXT NOT NULL, FOREIGN KEY (`userId`) REFERENCES `User` (`username`) ON UPDATE NO ACTION ON DELETE CASCADE)');
//         await database.execute(
//             'CREATE TABLE IF NOT EXISTS `User` (`username` TEXT NOT NULL, `name` TEXT NOT NULL, `email` TEXT NOT NULL, `password` TEXT NOT NULL, `imageUrl` TEXT, `bornDate` TEXT NOT NULL, PRIMARY KEY (`username`))');

//         await callback?.onCreate?.call(database, version);
//       },
//     );
//     return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
//   }

//   @override
//   TasksDao get tasksDao {
//     return _tasksDaoInstance ??= _$TasksDao(database, changeListener);
//   }

//   @override
//   UserDao get userDao {
//     return _userDaoInstance ??= _$UserDao(database, changeListener);
//   }
// }

// class _$TasksDao extends TasksDao {
//   _$TasksDao(
//     this.database,
//     this.changeListener,
//   )   : _queryAdapter = QueryAdapter(database),
//         _taskInsertionAdapter = InsertionAdapter(
//             database,
//             'Task',
//             (Task item) => <String, Object?>{
//                   'id': item.id,
//                   'title': item.title,
//                   'description': item.description,
//                   'imageUrl': item.imageUrl,
//                   'dueDate': item.dueDate,
//                   'category': item.category,
//                   'priority': item.priority,
//                   'progress': item.progress,
//                   'isCompleted': item.isCompleted ? 1 : 0,
//                   'createdAt': item.createdAt,
//                   'completedAt': item.completedAt,
//                   'userId': item.userId
//                 }),
//         _taskUpdateAdapter = UpdateAdapter(
//             database,
//             'Task',
//             ['id'],
//             (Task item) => <String, Object?>{
//                   'id': item.id,
//                   'title': item.title,
//                   'description': item.description,
//                   'imageUrl': item.imageUrl,
//                   'dueDate': item.dueDate,
//                   'category': item.category,
//                   'priority': item.priority,
//                   'progress': item.progress,
//                   'isCompleted': item.isCompleted ? 1 : 0,
//                   'createdAt': item.createdAt,
//                   'completedAt': item.completedAt,
//                   'userId': item.userId
//                 }),
//         _taskDeletionAdapter = DeletionAdapter(
//             database,
//             'Task',
//             ['id'],
//             (Task item) => <String, Object?>{
//                   'id': item.id,
//                   'title': item.title,
//                   'description': item.description,
//                   'imageUrl': item.imageUrl,
//                   'dueDate': item.dueDate,
//                   'category': item.category,
//                   'priority': item.priority,
//                   'progress': item.progress,
//                   'isCompleted': item.isCompleted ? 1 : 0,
//                   'createdAt': item.createdAt,
//                   'completedAt': item.completedAt,
//                   'userId': item.userId
//                 });

//   final sqflite.DatabaseExecutor database;

//   final StreamController<String> changeListener;

//   final QueryAdapter _queryAdapter;

//   final InsertionAdapter<Task> _taskInsertionAdapter;

//   final UpdateAdapter<Task> _taskUpdateAdapter;

//   final DeletionAdapter<Task> _taskDeletionAdapter;

//   @override
//   Future<List<Task>> getAllTasks() async {
//     return _queryAdapter.queryList('SELECT * FROM Task',
//         mapper: (Map<String, Object?> row) => Task(
//             id: row['id'] as int?,
//             title: row['title'] as String,
//             description: row['description'] as String,
//             imageUrl: row['imageUrl'] as String?,
//             dueDate: row['dueDate'] as String?,
//             priority: row['priority'] as int,
//             progress: row['progress'] as int,
//             category: row['category'] as String,
//             isCompleted: (row['isCompleted'] as int) != 0,
//             createdAt: row['createdAt'] as String?,
//             completedAt: row['completedAt'] as String?,
//             userId: row['userId'] as String));
//   }

//   @override
//   Future<Task?> getTaskById(int id) async {
//     return _queryAdapter.query('SELECT * FROM Task WHERE id = ?1',
//         mapper: (Map<String, Object?> row) => Task(
//             id: row['id'] as int?,
//             title: row['title'] as String,
//             description: row['description'] as String,
//             imageUrl: row['imageUrl'] as String?,
//             dueDate: row['dueDate'] as String?,
//             priority: row['priority'] as int,
//             progress: row['progress'] as int,
//             category: row['category'] as String,
//             isCompleted: (row['isCompleted'] as int) != 0,
//             createdAt: row['createdAt'] as String?,
//             completedAt: row['completedAt'] as String?,
//             userId: row['userId'] as String),
//         arguments: [id]);
//   }

//   @override
//   Future<List<Task>> getTasksByUserId(String userId) async {
//     return _queryAdapter.queryList('SELECT * FROM Task WHERE userId = ?1',
//         mapper: (Map<String, Object?> row) => Task(
//             id: row['id'] as int?,
//             title: row['title'] as String,
//             description: row['description'] as String,
//             imageUrl: row['imageUrl'] as String?,
//             dueDate: row['dueDate'] as String?,
//             priority: row['priority'] as int,
//             progress: row['progress'] as int,
//             category: row['category'] as String,
//             isCompleted: (row['isCompleted'] as int) != 0,
//             createdAt: row['createdAt'] as String?,
//             completedAt: row['completedAt'] as String?,
//             userId: row['userId'] as String),
//         arguments: [userId]);
//   }

//   @override
//   Future<Task?> getTaskByIdAndUserId(
//     int id,
//     String userId,
//   ) async {
//     return _queryAdapter.query(
//         'SELECT * FROM Task WHERE id = ?1 AND userId = ?2',
//         mapper: (Map<String, Object?> row) => Task(
//             id: row['id'] as int?,
//             title: row['title'] as String,
//             description: row['description'] as String,
//             imageUrl: row['imageUrl'] as String?,
//             dueDate: row['dueDate'] as String?,
//             priority: row['priority'] as int,
//             progress: row['progress'] as int,
//             category: row['category'] as String,
//             isCompleted: (row['isCompleted'] as int) != 0,
//             createdAt: row['createdAt'] as String?,
//             completedAt: row['completedAt'] as String?,
//             userId: row['userId'] as String),
//         arguments: [id, userId]);
//   }

//   @override
//   Future<void> insertTask(Task task) async {
//     await _taskInsertionAdapter.insert(task, OnConflictStrategy.abort);
//   }

//   @override
//   Future<void> updateTask(Task task) async {
//     await _taskUpdateAdapter.update(task, OnConflictStrategy.abort);
//   }

//   @override
//   Future<void> deleteTask(Task task) async {
//     await _taskDeletionAdapter.delete(task);
//   }
// }

// class _$UserDao extends UserDao {
//   _$UserDao(
//     this.database,
//     this.changeListener,
//   )   : _queryAdapter = QueryAdapter(database),
//         _userInsertionAdapter = InsertionAdapter(
//             database,
//             'User',
//             (User item) => <String, Object?>{
//                   'username': item.username,
//                   'name': item.name,
//                   'email': item.email,
//                   'password': item.password,
//                   'imageUrl': item.imageUrl,
//                   'bornDate': item.bornDate
//                 }),
//         _userUpdateAdapter = UpdateAdapter(
//             database,
//             'User',
//             ['username'],
//             (User item) => <String, Object?>{
//                   'username': item.username,
//                   'name': item.name,
//                   'email': item.email,
//                   'password': item.password,
//                   'imageUrl': item.imageUrl,
//                   'bornDate': item.bornDate
//                 }),
//         _userDeletionAdapter = DeletionAdapter(
//             database,
//             'User',
//             ['username'],
//             (User item) => <String, Object?>{
//                   'username': item.username,
//                   'name': item.name,
//                   'email': item.email,
//                   'password': item.password,
//                   'imageUrl': item.imageUrl,
//                   'bornDate': item.bornDate
//                 });

//   final sqflite.DatabaseExecutor database;

//   final StreamController<String> changeListener;

//   final QueryAdapter _queryAdapter;

//   final InsertionAdapter<User> _userInsertionAdapter;

//   final UpdateAdapter<User> _userUpdateAdapter;

//   final DeletionAdapter<User> _userDeletionAdapter;

//   @override
//   Future<List<User>> getAllUsers() async {
//     return _queryAdapter.queryList('SELECT * FROM User',
//         mapper: (Map<String, Object?> row) => User(
//             username: row['username'] as String,
//             name: row['name'] as String,
//             email: row['email'] as String,
//             password: row['password'] as String,
//             bornDate: row['bornDate'] as String,
//             imageUrl: row['imageUrl'] as String?));
//   }

//   @override
//   Future<User?> getUserByUsername(String username) async {
//     return _queryAdapter.query('SELECT * FROM User WHERE username = ?1',
//         mapper: (Map<String, Object?> row) => User(
//             username: row['username'] as String,
//             name: row['name'] as String,
//             email: row['email'] as String,
//             password: row['password'] as String,
//             bornDate: row['bornDate'] as String,
//             imageUrl: row['imageUrl'] as String?),
//         arguments: [username]);
//   }

//   @override
//   Future<void> insertUser(User user) async {
//     await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
//   }

//   @override
//   Future<void> updateUser(User user) async {
//     await _userUpdateAdapter.update(user, OnConflictStrategy.abort);
//   }

//   @override
//   Future<void> deleteUser(User user) async {
//     await _userDeletionAdapter.delete(user);
//   }
// }
