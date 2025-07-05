import 'package:go_router/go_router.dart';
import 'package:taskium/domain/task.dart';
import 'package:taskium/presentation/screens/detail_screen.dart';
import 'package:taskium/presentation/screens/edit_screen.dart';
import 'package:taskium/presentation/screens/home_screen.dart';
import 'package:taskium/presentation/screens/login_screen.dart';
import 'package:taskium/presentation/screens/profile_screen.dart';
import 'package:taskium/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final username = state.extra as String; // Explicitly cast to String
        return HomeScreen(username: username);
      },
    ),
    GoRoute(
     path: '/task-details/:taskId', 
     builder: (context, state) {
      final taskIdString = state.pathParameters['taskId'];
      final taskIdInt = int.tryParse(taskIdString ?? '') ?? 1;
      final task = state.extra as Task?; // Get the task object if passed
      
      return DetailScreen(
        taskId: taskIdInt,
        task: task,
      );
    }),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final username = state.extra as String; // Explicitly cast to String
        return ProfileScreen(username: username);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen()
    ),
    GoRoute(
      path: '/edit',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final task = extra['task'] as Task?;
        final userId = extra['userId'] as String;
        return EditScreen(task: task, userId: userId);
      },
    ),
    // Add more routes here
  ],
);