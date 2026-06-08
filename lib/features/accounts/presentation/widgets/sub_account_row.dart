import 'package:flutter/material.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

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
    final netBalance = subAccount.debitBalance - subAccount.creditBalance;

    return Container(
      padding: const EdgeInsetsDirectional.only(
        top: 8.0,
        bottom: 8.0,
        start: 16,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(120),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withAlpha(50),
            width: 0.5,
          ),
        ),
      ),
      child: fluent.Table(
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
              const SizedBox(
                width: 60,
              ), // Empty space for alignment with main account
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: 4.0,
                  bottom: 4.0,
                ),
                child: Row(
                  children: [
                    fluent.Icon(
                      fluent.FluentIcons.double_chevron_left,
                      size: 16,
                      color: Colors.grey,
                    ),
                    fluent.Text(
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
                padding: const EdgeInsetsDirectional.only(
                  top: 4.0,
                  bottom: 4.0,
                  start: 16,
                ),
                child: fluent.Text(
                  subAccount.accountName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(60),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: fluent.Text(
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
                child: fluent.Text(
                  subAccount.debitBalance.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: fluent.Text(
                  subAccount.creditBalance.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: fluent.Text(
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
                child: fluent.Text(
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
                      fluent.Tooltip(
                        message: 'كشف الحساب',
                        child: fluent.IconButton(
                          icon: const fluent.Icon(
                            fluent.FluentIcons.receipt_processing,
                            size: 18,
                            color: Colors.blue,
                          ),
                          onPressed: onViewStatement,
                        ),
                      ),
                      const SizedBox(width: 2),
                      fluent.Tooltip(
                        message: 'تعديل',
                        child: fluent.IconButton(
                          icon: const fluent.Icon(
                            fluent.FluentIcons.edit,
                            size: 18,
                            color: Colors.orange,
                          ),
                          onPressed: onEdit,
                        ),
                      ),
                      const SizedBox(width: 2),
                      fluent.Tooltip(
                        message: 'حذف',
                        child: fluent.IconButton(
                          icon: const fluent.Icon(
                            fluent.FluentIcons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: onDelete,
                        ),
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
