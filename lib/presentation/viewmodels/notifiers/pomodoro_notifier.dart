import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskium/presentation/viewmodels/states/pomodoro_state.dart';

class PomodoroNotifier extends Notifier<PomodoroState> {
  Timer? _timer;

  @override
  PomodoroState build() {
    return const PomodoroState();
  }

  @override
  void dispose() {
    _timer?.cancel();
  }

  void startTimer() {
    if (state.timerState.isRunning) return;

    state = state.copyWith(timerState: PomodoroTimerState.running);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _completeCurrentPhase();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(timerState: PomodoroTimerState.paused);
  }

  void resetTimer() {
    _timer?.cancel();
    final newRemainingSeconds = state.totalSeconds;
    state = state.copyWith(
      timerState: PomodoroTimerState.idle,
      remainingSeconds: newRemainingSeconds,
    );
  }

  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(
      timerState: PomodoroTimerState.idle,
      currentPhase: PomodoroPhase.work,
      remainingSeconds: state.settings.workDuration * 60,
      completedSessions: 0,
      currentSessionInCycle: 0,
    );
  }

  void _completeCurrentPhase() {
    _timer?.cancel();
    
    if (state.currentPhase == PomodoroPhase.work) {
      final newCompletedSessions = state.completedSessions + 1;
      final newCurrentSessionInCycle = state.currentSessionInCycle + 1;
      
      if (newCurrentSessionInCycle >= state.settings.sessionsUntilLongBreak) {
        // Time for long break
        state = state.copyWith(
          timerState: PomodoroTimerState.completed,
          currentPhase: PomodoroPhase.longBreak,
          remainingSeconds: state.settings.longBreakDuration * 60,
          completedSessions: newCompletedSessions,
          currentSessionInCycle: 0, // Reset cycle
        );
      } else {
        // Time for short break
        state = state.copyWith(
          timerState: PomodoroTimerState.completed,
          currentPhase: PomodoroPhase.shortBreak,
          remainingSeconds: state.settings.shortBreakDuration * 60,
          completedSessions: newCompletedSessions,
          currentSessionInCycle: newCurrentSessionInCycle,
        );
      }
    } else {
      // Break completed, back to work
      state = state.copyWith(
        timerState: PomodoroTimerState.completed,
        currentPhase: PomodoroPhase.work,
        remainingSeconds: state.settings.workDuration * 60,
      );
    }
  }

  void startNextPhase() {
    state = state.copyWith(timerState: PomodoroTimerState.idle);
    startTimer();
  }

  void updateSettings(PomodoroSettings newSettings) {
    _timer?.cancel();
    
    // Update remaining time if we're in idle state
    int newRemainingSeconds = state.remainingSeconds;
    if (state.timerState.isIdle) {
      switch (state.currentPhase) {
        case PomodoroPhase.work:
          newRemainingSeconds = newSettings.workDuration * 60;
          break;
        case PomodoroPhase.shortBreak:
          newRemainingSeconds = newSettings.shortBreakDuration * 60;
          break;
        case PomodoroPhase.longBreak:
          newRemainingSeconds = newSettings.longBreakDuration * 60;
          break;
      }
    }

    state = state.copyWith(
      settings: newSettings,
      remainingSeconds: newRemainingSeconds,
      timerState: PomodoroTimerState.idle,
    );
  }
}

final pomodoroNotifierProvider = NotifierProvider<PomodoroNotifier, PomodoroState>(() => PomodoroNotifier());
