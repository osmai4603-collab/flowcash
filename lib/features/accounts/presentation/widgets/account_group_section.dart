import 'package:flutter/material.dart';
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';
import 'package:fluent_ui/fluent_ui.dart' show FluentIcons;

class AccountGroupSection extends StatelessWidget {
  final MainAccountGroup group;
  final List<MainAccountEntity> mainAccounts;

  const AccountGroupSection({
    super.key,
    required this.group,
    required this.mainAccounts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate sum of balances for this group
    double totalDebit = 0.0;
    double totalCredit = 0.0;
    for (final acc in mainAccounts) {
      totalDebit += acc.debitBalance;
      totalCredit += acc.creditBalance;
    }
    final totalNet = totalDebit - totalCredit;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.10),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.60),
            width: 1.5,
          ),
          top: BorderSide(
            color: theme.colorScheme.primary.withValues(alpha: 0.20),
            width: 0.5,
          ),
        ),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(60),
          1: FlexColumnWidth(6),
          2: FlexColumnWidth(2),
          3: FixedColumnWidth(90),
          4: FixedColumnWidth(90),
          5: FixedColumnWidth(90),
          6: FixedColumnWidth(80),
          7: FixedColumnWidth(120),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 4.0),
                child: Icon(
                  FluentIcons.folder_open,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 4.0, bottom: 4.0, start: 8),
                child: Text(
                  group.displayName(),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  totalDebit.toStringAsFixed(2),
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  totalCredit.toStringAsFixed(2),
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  totalNet.toStringAsFixed(2),
                  style: TextStyle(
                    color: totalNet >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
