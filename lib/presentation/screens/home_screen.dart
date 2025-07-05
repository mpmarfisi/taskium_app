import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskium/domain/task.dart';
import 'package:taskium/presentation/providers/theme_provider.dart';
import 'package:taskium/presentation/viewmodels/notifiers/home_notifier.dart';
import 'package:taskium/presentation/viewmodels/states/home_state.dart';
import 'package:taskium/presentation/widgets/task_item.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.username});

  final String username;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize with user's tasks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).initialize(widget.username);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final homeState = ref.watch(homeNotifierProvider);
    final homeNotifier = ref.read(homeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => homeNotifier.refreshTasks(widget.username),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                context.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                context.pop(context); // Close the drawer
                context.push('/profile', extra: widget.username);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                context.pop(context); // Close the drawer
                context.push('/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logoff'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: const Text('Are you sure you want to logoff?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            context.pop();
                          },
                        ),
                        FilledButton(
                          child: const Text('Logoff'),
                          onPressed: () {
                            themeNotifier.resetTheme(); // Reset theme
                            context.pop();
                            context.pop(context);
                            context.go('/login');
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: homeState.screenState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        empty: () => const Center(child: Text('No tasks available.')),
        error: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${homeState.errorMessage}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => homeNotifier.fetchTasks(widget.username),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        refreshing: () => Stack(
          children: [
            _TasksView(
              tasks: homeState.tasks,
              onTasksUpdated: () => homeNotifier.fetchTasks(widget.username),
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
        submitting: () => Stack(
          children: [
            _TasksView(
              tasks: homeState.tasks,
              onTasksUpdated: () => homeNotifier.fetchTasks(widget.username),
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
        success: () => _TasksView(
          tasks: homeState.tasks,
          onTasksUpdated: () => homeNotifier.fetchTasks(widget.username),
        ),
        idle: () => _TasksView(
          tasks: homeState.tasks,
          onTasksUpdated: () => homeNotifier.fetchTasks(widget.username),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: homeState.screenState.isSubmitting ? null : () async {
          final Task? newTask;
          try {
            newTask = await context.push('/edit', extra: {'userId': widget.username}) as Task?;
            if (newTask != null) {
              homeNotifier.addTask(newTask);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error adding task')),
            );
          }
        },
        shape: CircleBorder(
          side: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 3,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView({
    required this.tasks,
    required this.onTasksUpdated,
  });

  final List<Task> tasks;
  final VoidCallback onTasksUpdated; // Callback to notify HomeScreen

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks available.'));
    }

    final priorities = [
      {'label': 'Priority 3', 'color': Colors.red, 'value': 3},
      {'label': 'Priority 2', 'color': Colors.orange, 'value': 2},
      {'label': 'Priority 1', 'color': Colors.blue, 'value': 1},
      {'label': 'Priority 0', 'color': Colors.grey, 'value': 0},
    ];

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: priorities
          .map((priority) => _buildPrioritySection(
                label: priority['label'] as String,
                color: priority['color'] as Color,
                priorityValue: priority['value'] as int,
                tasks: tasks,
                onTasksUpdated: onTasksUpdated,
                context: context,
              ))
          .toList(),
    );
  }

  Widget _buildPriorityLabel(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        label,
        style: TextStyle(
          // fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPrioritySection({
    required String label,
    required Color color,
    required int priorityValue,
    required List<Task> tasks,
    required VoidCallback onTasksUpdated,
    required BuildContext context,
  }) {
    final filteredTasks = tasks.where((task) => task.priority == priorityValue).toList();

    if (filteredTasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPriorityLabel(label, color),
        ...filteredTasks.map((task) => TaskItem(
              task: task,
              onTap: () async {
                print('Navigating to task details with task: ${task.id}'); // Debug print
                // final hasChanges = await context.push('/task-details/${task.id}', extra: task) as bool?;
                final hasChanges = await context.push('/task-details/', extra: task) as bool?;
                if (hasChanges == true) {
                  onTasksUpdated(); // Only refresh if there were changes
                }
              },
            )),
      ],
    );
  }
}
