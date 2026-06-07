import 'package:flutter/material.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
class MainAccountRow extends StatelessWidget {
  final MainAccountEntity mainAccount;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onAddSubAccount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MainAccountRow({
    super.key,
    required this.mainAccount,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onAddSubAccount,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netBalance =
        mainAccount.debitBalance - mainAccount.creditBalance;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.10,
        ),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.50),
        ),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(60),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(4),
          3: FlexColumnWidth(2),
          4: FixedColumnWidth(90),
          5: FixedColumnWidth(90),
          6: FixedColumnWidth(90),
          7: FixedColumnWidth(80),
          8: FixedColumnWidth(120),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: IconButton(
                  icon: Icon(
                  isExpanded
                    ? fluent.FluentIcons.chevron_down
                    : fluent.FluentIcons.chevron_left,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: onToggleExpand,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 4.0, bottom: 4.0, start: 8),
                child: fluent.Text(
                  mainAccount.accountNumber,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: fluent.Text(
                  mainAccount.accountName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: fluent.Text(
                    mainAccount.mainAccountType.displayName(),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: fluent.Text(
                  mainAccount.debitBalance.toStringAsFixed(2),
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: fluent.Text(
                  mainAccount.creditBalance.toStringAsFixed(2),
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: fluent.Text(
                  netBalance.toStringAsFixed(2),
                  style: TextStyle(
                    color: netBalance >= 0
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: fluent.Text(
                  mainAccount.currencyId == '1'
                      ? 'ر.ي'
                      : (mainAccount.currencyId == '2' ? 'ر.س' : '\$'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(fluent.FluentIcons.add,
                        size: 20,
                        color: Colors.green,
                      ),
                      tooltip: 'إضافة حساب فرعي',
                      onPressed: onAddSubAccount,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(fluent.FluentIcons.edit, size: 20, color: Colors.orange),
                      tooltip: 'تعديل',
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(fluent.FluentIcons.delete, size: 20, color: Colors.red),
                      tooltip: 'حذف',
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
