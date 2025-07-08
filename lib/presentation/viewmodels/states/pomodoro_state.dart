enum PomodoroPhase { work, shortBreak, longBreak }

enum PomodoroTimerState { idle, running, paused, completed }

extension PomodoroTimerStateX on PomodoroTimerState {
  bool get isIdle => this == PomodoroTimerState.idle;
  bool get isRunning => this == PomodoroTimerState.running;
  bool get isPaused => this == PomodoroTimerState.paused;
  bool get isCompleted => this == PomodoroTimerState.completed;
}

class PomodoroSettings {
  final int workDuration; // in minutes
  final int shortBreakDuration; // in minutes
  final int longBreakDuration; // in minutes
  final int sessionsUntilLongBreak;

  const PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsUntilLongBreak = 4,
  });

  PomodoroSettings copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    int? sessionsUntilLongBreak,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      sessionsUntilLongBreak: sessionsUntilLongBreak ?? this.sessionsUntilLongBreak,
    );
  }
}

class PomodoroState {
  final PomodoroTimerState timerState;
  final PomodoroPhase currentPhase;
  final PomodoroSettings settings;
  final int remainingSeconds;
  final int completedSessions;
  final int currentSessionInCycle;

  const PomodoroState({
    this.timerState = PomodoroTimerState.idle,
    this.currentPhase = PomodoroPhase.work,
    this.settings = const PomodoroSettings(),
    this.remainingSeconds = 1500, // 25 minutes default
    this.completedSessions = 0,
    this.currentSessionInCycle = 0,
  });

  PomodoroState copyWith({
    PomodoroTimerState? timerState,
    PomodoroPhase? currentPhase,
    PomodoroSettings? settings,
    int? remainingSeconds,
    int? completedSessions,
    int? currentSessionInCycle,
  }) {
    return PomodoroState(
      timerState: timerState ?? this.timerState,
      currentPhase: currentPhase ?? this.currentPhase,
      settings: settings ?? this.settings,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      completedSessions: completedSessions ?? this.completedSessions,
      currentSessionInCycle: currentSessionInCycle ?? this.currentSessionInCycle,
    );
  }

  int get totalSeconds {
    switch (currentPhase) {
      case PomodoroPhase.work:
        return settings.workDuration * 60;
      case PomodoroPhase.shortBreak:
        return settings.shortBreakDuration * 60;
      case PomodoroPhase.longBreak:
        return settings.longBreakDuration * 60;
    }
  }

  double get progress {
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get phaseTitle {
    switch (currentPhase) {
      case PomodoroPhase.work:
        return 'Work Session';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }
}
