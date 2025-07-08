import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:taskium/domain/task.dart';
import 'package:taskium/presentation/providers/theme_provider.dart';
import 'package:taskium/presentation/screens/pomodoro_screen.dart';
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
  int _selectedIndex = 0;
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    // Initialize with user's tasks
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).initialize(widget.username);
    });
  }

  Widget _buildBody(HomeState homeState, HomeNotifier homeNotifier) {
    switch (_selectedIndex) {
      case 0:
        // Main List
        return homeState.screenState.when(
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
        );
      case 1:
        // Upcoming Tasks View (no calendar)
        return CalendarView(
          tasks: homeState.tasks,
          month: _calendarMonth,
          onPrevMonth: () {
            setState(() {
              _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1);
            });
          },
          onNextMonth: () {
            setState(() {
              _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1);
            });
          },
        );
      case 2:
        // Pomodoro View
        return const PomodoroScreen();
      case 3:
        // Stats View placeholder
        return const Center(child: Text('Stats View (Coming Soon)'));
      default:
        return const SizedBox.shrink();
    }
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
      body: _buildBody(homeState, homeNotifier),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
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
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Main List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Pomodoro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
        type: BottomNavigationBarType.fixed,
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

class CalendarView extends StatefulWidget {
  final List<Task> tasks;
  final DateTime month;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const CalendarView({
    super.key,
    required this.tasks,
    required this.month,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDay();
    });
  }

  @override
  void didUpdateWidget(CalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentDay();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentDay() {
    final today = DateTime.now();
    if (today.year == widget.month.year && today.month == widget.month.month) {
      final todayIndex = today.day - 2;
      const itemHeight = 74.0; // Approximate height of each day item
      final targetOffset = todayIndex * itemHeight - 100; // Center with some offset
      
      if (_scrollController.hasClients && targetOffset > 0) {
        _scrollController.jumpTo(targetOffset); // <-- changed from animateTo to jumpTo
      }
    }
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    return List<DateTime>.generate(
      last.day,
      (i) => DateTime(month.year, month.month, i + 1),
    );
  }

  Map<String, List<Task>> _tasksByDate() {
    final map = <String, List<Task>>{};
    for (final task in widget.tasks) {
      if (task.dueDate == null || task.dueDate!.isEmpty) continue;
      final date = task.dueDate!.substring(0, 10);
      map.putIfAbsent(date, () => []).add(task);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(widget.month);
    final tasksByDate = _tasksByDate();
    final monthFormat = DateFormat.yMMMM();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: widget.onPrevMonth,
              ),
              Text(
                monthFormat.format(widget.month),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: widget.onNextMonth,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: days.length,
            itemBuilder: (context, i) {
              final day = days[i];
              final dateStr = DateFormat('yyyy-MM-dd').format(day);
              final dayTasks = tasksByDate[dateStr] ?? [];
              final isToday = DateTime.now().year == day.year &&
                  DateTime.now().month == day.month &&
                  DateTime.now().day == day.day;
              final hasTasks = dayTasks.isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasTasks
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.07)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: isToday ? 2 : 1,
                  ),
                ),
                height: hasTasks ? 64.0 + 28.0 * dayTasks.length : 50.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (hasTasks)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...dayTasks.map((task) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle, size: 8, color: Colors.blueGrey),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      )
                    else
                      Expanded(
                        child: Center(
                          child: Text(
                            DateFormat.E().format(day),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
