import 'package:taskium/domain/task.dart';

enum HomeScreenState { loading, empty, error, refreshing, submitting, success, idle }

extension HomeScreenStateX on HomeScreenState {
  bool get isLoading => this == HomeScreenState.loading;
  bool get isEmpty => this == HomeScreenState.empty;
  bool get isError => this == HomeScreenState.error;
  bool get isRefreshing => this == HomeScreenState.refreshing;
  bool get isSubmitting => this == HomeScreenState.submitting;
  bool get isSuccess => this == HomeScreenState.success;
  bool get isIdle => this == HomeScreenState.idle;

  R when<R>({
    required R Function() loading,
    required R Function() empty,
    required R Function() error,
    required R Function() refreshing,
    required R Function() submitting,
    required R Function() success,
    required R Function() idle,
  }) {
    final state = this;
    switch (state) {
      case HomeScreenState.loading:
        return loading();
      case HomeScreenState.empty:
        return empty();
      case HomeScreenState.error:
        return error();
      case HomeScreenState.refreshing:
        return refreshing();
      case HomeScreenState.submitting:
        return submitting();
      case HomeScreenState.success:
        return success();
      case HomeScreenState.idle:
        return idle();
      default:
        throw AssertionError();
    }
  }
}

class HomeState {
  final HomeScreenState screenState;
  final List<Task> tasks;
  final String? errorMessage;
  final int selectedIndex;
  final DateTime calendarMonth;

  const HomeState({
    this.screenState = HomeScreenState.idle,
    this.tasks = const [],
    this.errorMessage,
    this.selectedIndex = 0,
    required this.calendarMonth,
  });

  HomeState copyWith({
    HomeScreenState? screenState,
    List<Task>? tasks,
    String? errorMessage,
    int? selectedIndex,
    DateTime? calendarMonth,
  }) {
    return HomeState(
      screenState: screenState ?? this.screenState,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      calendarMonth: calendarMonth ?? this.calendarMonth,
    );
  }

  @override
  List<Object?> get props => [screenState, tasks, errorMessage, selectedIndex, calendarMonth];
}

