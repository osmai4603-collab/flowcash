import 'package:flowcash/features/settings/domain/entities/value_counter_entity.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class ValueCounterTile extends StatelessWidget {
  final ValueCounterEntity counter;
  final VoidCallback onIncrement;

  const ValueCounterTile({super.key, required this.counter, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  fluent.Text(
                    counter.counterType.displayName(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  fluent.Text('Count: ${counter.count}'),
                  fluent.Text('Format: ${counter.formatValue}'),
                  fluent.Text('Type: ${counter.counterType.displayName()}'),
                ],
              ),
            ),
            fluent.FilledButton(
              onPressed: onIncrement,
              child: const fluent.Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
