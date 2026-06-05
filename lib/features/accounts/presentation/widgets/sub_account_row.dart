import 'package:flutter/material.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;
class SubAccountRow extends StatelessWidget {
  final SubAccountEntity subAccount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewStatement;

  const SubAccountRow({
    super.key,
    required this.subAccount,
    required this.onEdit,
    required this.onDelete,
    required this.onViewStatement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netBalance =
        subAccount.incrementsBalance - subAccount.decrementsBalance;

    return Container(
                padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 8.0, start: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(120),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withAlpha(50),
            width: 0.5,
          ),
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
              const SizedBox(width: 60), // Empty space for alignment with main account
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 4.0, bottom: 4.0),
                child: Row(
                  children: [
                    Icon(FluentIcons.double_chevron_left,
                      size: 16,
                      color: Colors.grey,
                    ),
                    Text(
                      subAccount.accountNumber,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurface.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 4.0, bottom: 4.0, start: 16),
                child: Text(
                  subAccount.accountName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(60),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    subAccount.subAccountType.displayName(),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  subAccount.incrementsBalance.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  subAccount.decrementsBalance.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  netBalance.toStringAsFixed(2),
                  style: TextStyle(
                    color: netBalance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  subAccount.currencyId == '1'
                      ? 'ر.ي'
                      : (subAccount.currencyId == '2' ? 'ر.س' : '\$'),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(FluentIcons.receipt_processing,
                          size: 18,
                          color: Colors.blue,
                        ),
                        tooltip: 'كشف الحساب',
                        onPressed: onViewStatement,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 18,
                          height: 18,
                        ),
                        splashRadius: 18,
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(FluentIcons.edit, size: 18, color: Colors.orange),
                        tooltip: 'تعديل',
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 18,
                          height: 18,
                        ),
                        splashRadius: 18,
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        icon: const Icon(FluentIcons.delete, size: 18, color: Colors.red),
                        tooltip: 'حذف',
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 18,
                          height: 18,
                        ),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
