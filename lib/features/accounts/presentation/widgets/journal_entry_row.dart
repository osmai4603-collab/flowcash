import 'package:flutter/material.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:intl/intl.dart';

import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
class JournalEntryRow extends StatelessWidget {
  final JournalEntryEntity entry;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const JournalEntryRow({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('yyyy-MM-dd').format(entry.createdAt);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withAlpha(50)
              : theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withAlpha(50),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Reference Number
            Expanded(
              flex: 2,
              child: Text(
                entry.referenceNumber,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Description
            Expanded(
              flex: 4,
              child: Text(
                entry.description ?? 'بدون وصف',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Date
            Expanded(
              flex: 2,
              child: Text(
                dateStr,
                style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
              ),
            ),

            // Currency
            Expanded(
              flex: 1,
              child: Text(
                entry.currencyId == '1' ? 'ر.ي' : (entry.currencyId == '2' ? 'ر.س' : '\$'),
                textAlign: TextAlign.center,
              ),
            ),

            // Base Amount
            Expanded(
              flex: 2,
              child: Text(
                entry.baseAmount.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
            ),

            // Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(FluentIcons.edit, size: 18, color: Colors.orange),
                    onPressed: onEdit,
                    tooltip: 'تعديل القيد',
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.delete, size: 18, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'حذف القيد',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
