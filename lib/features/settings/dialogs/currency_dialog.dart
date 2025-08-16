import 'package:flutter/material.dart';

class CurrencyDialog extends StatelessWidget {
  final Function(String) onCurrencySelected;

  const CurrencyDialog({
    super.key,
    required this.onCurrencySelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Currency'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('US Dollar (\$)'),
            onTap: () {
              onCurrencySelected('USD');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Euro (€)'),
            onTap: () {
              onCurrencySelected('EUR');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('British Pound (£)'),
            onTap: () {
              onCurrencySelected('GBP');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Canadian Dollar (C\$)'),
            onTap: () {
              onCurrencySelected('CAD');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
