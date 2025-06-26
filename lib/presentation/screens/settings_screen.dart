import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:go_router/go_router.dart';
import 'package:taskium/presentation/providers/theme_provider.dart'; // Import theme provider
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Import color picker

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Dark mode'),
              value: appTheme.isDarkMode,
              onChanged: (value) => themeNotifier.setDarkMode(value),
            ),
            const Divider(),
            ListTile(
              // contentPadding: EdgeInsets.zero,
              title: Row(
                children: [
                  const Text(
                    'Theme color:',
                    // style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: appTheme.selectedColor,
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      Color selectedColor = appTheme.selectedColor;
                      return AlertDialog(
                        title: const Text('Pick a Theme Color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: selectedColor,
                            onColorChanged: (color) {
                              selectedColor = color;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              themeNotifier.setColorTheme(selectedColor);
                              context.pop();
                            },
                            child: const Text('Select'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Change'),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Font Size'),
              subtitle: Slider(
                value: appTheme.fontSize,
                min: 12.0,
                max: 24.0,
                divisions: 6,
                label: '${appTheme.fontSize.toInt()}',
                onChanged: (value) => themeNotifier.setFontSize(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}