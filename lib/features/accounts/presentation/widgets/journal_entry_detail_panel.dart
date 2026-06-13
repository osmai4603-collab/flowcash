import 'package:flutter/material.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';
import 'package:flowcash/core/enums/journal_status_enum.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class JournalEntryDetailPanel extends StatelessWidget {
  final JournalEntryEntity entry;
  final List<JournalItemEntity> items;

  const JournalEntryDetailPanel({
    super.key,
    required this.entry,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double totalDebit = 0.0;
    double totalCredit = 0.0;
    for (final item in items) {
      if (item.journalStatus == JournalStatus.increment) {
        totalDebit += item.amount;
      } else {
        totalCredit += item.amount;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 2)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              fluent.Icon(
                fluent.FluentIcons.list,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: fluent.Text(
                  'تفاصيل القيد رقم: ${entry.referenceNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (entry.description != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: fluent.Text(
                    'البيان: ${entry.description}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: fluent.Text('جاري تحميل البنود...'),
              ),
            )
          else ...[
            fluent.Table(
              columnWidths: const {
                0: FlexColumnWidth(4), // Account Name
                1: FlexColumnWidth(2), // Debit
                2: FlexColumnWidth(2), // Credit
                3: FlexColumnWidth(4), // Details/Notes
              },
              border: fluent.TableBorder.all(
                color: theme.dividerColor.withAlpha(50),
                width: 0.5,
              ),
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(40),
                  ),
                  children: const [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: fluent.Text(
                          'الحساب',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: fluent.Text(
                          'مدين',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: fluent.Text(
                          'دائن',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: fluent.Text(
                          'البيان التفصيلي',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                // Data Rows
                ...items.map((item) {
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: fluent.Text(
                            'حساب #${item.accountId}',
                          ), // In real usage, resolved to account names via a repository or stream
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: fluent.Text(
                            item.journalStatus == JournalStatus.increment
                                ? item.amount.toStringAsFixed(2)
                                : '-',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: fluent.Text(
                            item.journalStatus == JournalStatus.decrement
                                ? item.amount.toStringAsFixed(2)
                                : '-',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: fluent.Text(item.lineDescription ?? ''),
                        ),
                      ),
                    ],
                  );
                }),
                // Total Summary Row
                TableRow(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withAlpha(50),
                  ),
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: fluent.Text(
                          'الإجمالي',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: fluent.Text(
                          totalDebit.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: fluent.Text(
                          totalCredit.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    const TableCell(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
