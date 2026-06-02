import 'package:flutter/material.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_item_entity.dart';

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
      totalDebit += item.debit;
      totalCredit += item.credit;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 2),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تفاصيل القيد رقم: ${entry.referenceNumber}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (entry.description != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'البيان: ${entry.description}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
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
                child: Text('جاري تحميل البنود...'),
              ),
            )
          else ...[
            Table(
              columnWidths: const {
                0: FlexColumnWidth(4), // Account Name
                1: FlexColumnWidth(2), // Debit
                2: FlexColumnWidth(2), // Credit
                3: FlexColumnWidth(4), // Details/Notes
              },
              border: TableBorder.all(
                color: theme.dividerColor.withAlpha(50),
                width: 0.5,
              ),
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withAlpha(40)),
                  children: const [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('الحساب', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('مدين', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('دائن', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('البيان التفصيلي', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          child: Text('حساب #${item.accountId}'), // In real usage, resolved to account names via a repository or stream
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.debit > 0 ? item.debit.toStringAsFixed(2) : '-',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.credit > 0 ? item.credit.toStringAsFixed(2) : '-',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item.lineDescription ?? ''),
                        ),
                      ),
                    ],
                  );
                }),
                // Total Summary Row
                TableRow(
                  decoration: BoxDecoration(color: theme.colorScheme.surfaceVariant.withAlpha(50)),
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          totalDebit.toStringAsFixed(2),
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          totalCredit.toStringAsFixed(2),
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    const TableCell(
                      child: SizedBox(),
                    ),
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
