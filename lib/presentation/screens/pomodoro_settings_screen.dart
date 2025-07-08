import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskium/presentation/viewmodels/states/pomodoro_state.dart';

class PomodoroSettingsScreen extends StatefulWidget {
  final PomodoroSettings settings;

  const PomodoroSettingsScreen({super.key, required this.settings});

  @override
  State<PomodoroSettingsScreen> createState() => _PomodoroSettingsScreenState();
}

class _PomodoroSettingsScreenState extends State<PomodoroSettingsScreen> {
  late int workDuration;
  late int shortBreakDuration;
  late int longBreakDuration;
  late int sessionsUntilLongBreak;

  @override
  void initState() {
    super.initState();
    workDuration = widget.settings.workDuration;
    shortBreakDuration = widget.settings.shortBreakDuration;
    longBreakDuration = widget.settings.longBreakDuration;
    sessionsUntilLongBreak = widget.settings.sessionsUntilLongBreak;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Settings'),
        actions: [
          TextButton(
            onPressed: () {
              final newSettings = PomodoroSettings(
                workDuration: workDuration,
                shortBreakDuration: shortBreakDuration,
                longBreakDuration: longBreakDuration,
                sessionsUntilLongBreak: sessionsUntilLongBreak,
              );
              context.pop(newSettings);
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSliderSetting(
              title: 'Work Session Duration',
              value: workDuration,
              min: 1,
              max: 90,
              divisions: 89,
              onChanged: (value) => setState(() => workDuration = value.round()),
              suffix: 'minutes',
            ),
            const SizedBox(height: 24),
            _buildSliderSetting(
              title: 'Short Break Duration',
              value: shortBreakDuration,
              min: 1,
              max: 30,
              divisions: 29,
              onChanged: (value) => setState(() => shortBreakDuration = value.round()),
              suffix: 'minutes',
            ),
            const SizedBox(height: 24),
            _buildSliderSetting(
              title: 'Long Break Duration',
              value: longBreakDuration,
              min: 5,
              max: 60,
              divisions: 55,
              onChanged: (value) => setState(() => longBreakDuration = value.round()),
              suffix: 'minutes',
            ),
            const SizedBox(height: 24),
            _buildSliderSetting(
              title: 'Sessions Until Long Break',
              value: sessionsUntilLongBreak,
              min: 2,
              max: 8,
              divisions: 6,
              onChanged: (value) => setState(() => sessionsUntilLongBreak = value.round()),
              suffix: 'sessions',
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Work: ${workDuration}min → Short Break: ${shortBreakDuration}min'),
                    Text('After $sessionsUntilLongBreak sessions: Long Break ${longBreakDuration}min'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required int value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              '$value $suffix',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
