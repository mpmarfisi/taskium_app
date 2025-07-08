import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taskium/presentation/viewmodels/notifiers/pomodoro_notifier.dart';
import 'package:taskium/presentation/viewmodels/states/pomodoro_state.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoroState = ref.watch(pomodoroNotifierProvider);
    final pomodoroNotifier = ref.read(pomodoroNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await context.push('/pomodoro-settings', extra: pomodoroState.settings);
              if (result != null) {
                pomodoroNotifier.updateSettings(result as PomodoroSettings);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Phase indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _getPhaseColor(pomodoroState.currentPhase).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getPhaseColor(pomodoroState.currentPhase),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      pomodoroState.phaseTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getPhaseColor(pomodoroState.currentPhase),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: pomodoroState.progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getPhaseColor(pomodoroState.currentPhase),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                pomodoroState.formattedTime,
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sessions: ${pomodoroState.completedSessions}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (pomodoroState.timerState.isCompleted)
                    _buildCompletedControls(pomodoroNotifier)
                  else
                    _buildTimerControls(pomodoroState, pomodoroNotifier),
                ],
              ),
            ),
          ),
          _buildSessionCycleIndicator(pomodoroState),
        ],
      ),
    );
  }

  Widget _buildTimerControls(PomodoroState state, PomodoroNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            if (state.timerState.isRunning) {
              notifier.pauseTimer();
            } else {
              notifier.startTimer();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getPhaseColor(state.currentPhase),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                state.timerState.isRunning ? Icons.pause : Icons.play_arrow,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                state.timerState.isRunning ? 'Pause' : 'Start',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Reset button
        OutlinedButton(
          onPressed: () => notifier.resetTimer(),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: _getPhaseColor(state.currentPhase)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                color: _getPhaseColor(state.currentPhase),
              ),
              const SizedBox(width: 8),
              Text(
                'Reset',
                style: TextStyle(
                  color: _getPhaseColor(state.currentPhase),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton(
          onPressed: () => notifier.stopTimer(),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stop, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Stop',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedControls(PomodoroNotifier notifier) {
    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          size: 48,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        const Text(
          'Phase Complete!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => notifier.startNextPhase(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text(
            'Start Next Phase',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCycleIndicator(PomodoroState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Session Cycle Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(state.settings.sessionsUntilLongBreak, (index) {
              final isCompleted = index < state.currentSessionInCycle;
              final isCurrent = index == state.currentSessionInCycle && state.currentPhase == PomodoroPhase.work;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.green
                      : isCurrent
                          ? Colors.orange
                          : Colors.grey.shade300,
                  border: isCurrent ? Border.all(color: Colors.orange, width: 2) : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor(PomodoroPhase phase) {
    switch (phase) {
      case PomodoroPhase.work:
        return Colors.red;
      case PomodoroPhase.shortBreak:
        return Colors.green;
      case PomodoroPhase.longBreak:
        return Colors.blue;
    }
  }
}
