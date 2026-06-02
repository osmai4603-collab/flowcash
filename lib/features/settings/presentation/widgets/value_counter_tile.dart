import 'package:flowcash/features/settings/domain/entities/value_counter_entity.dart';
import 'package:flutter/material.dart';

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
                  Text(
                    counter.counterType.displayName(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Count: ${counter.count}'),
                  Text('Format: ${counter.formatValue}'),
                  Text('Type: ${counter.counterType.displayName()}'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onIncrement,
              child: const Text('Increment'),
            ),
          ],
        ),
      ),
    );
  }
}
