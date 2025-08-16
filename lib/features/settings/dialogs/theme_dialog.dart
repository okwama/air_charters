import 'package:flutter/material.dart';

class ThemeDialog extends StatelessWidget {
  final Function(String) onThemeSelected;

  const ThemeDialog({
    super.key,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Theme'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Light Mode'),
            onTap: () {
              onThemeSelected('light');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Dark Mode'),
            onTap: () {
              onThemeSelected('dark');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Auto (System)'),
            onTap: () {
              onThemeSelected('auto');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
