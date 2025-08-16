import 'package:flutter/material.dart';

class LanguageDialog extends StatelessWidget {
  final Function(String) onLanguageSelected;

  const LanguageDialog({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('English'),
            onTap: () {
              onLanguageSelected('en');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Español'),
            onTap: () {
              onLanguageSelected('es');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Français'),
            onTap: () {
              onLanguageSelected('fr');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Deutsch'),
            onTap: () {
              onLanguageSelected('de');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
