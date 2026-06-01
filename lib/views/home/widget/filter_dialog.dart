import 'package:flutter/material.dart';

class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Workshops'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Filter options will go here'),
          // TODO: Implement actual filters based on specialization, services etc.
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
