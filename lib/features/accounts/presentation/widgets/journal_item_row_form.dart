import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flutter/material.dart';
import 'package:flowcash/widgets/combo_box_form.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import '../../../../../core/enums/account_status_enum.dart';

class JournalItemRowForm extends StatefulWidget {
  final int index;
  final JournalItemDraft draft;
  final AccountStatus side;
  final List<SubAccountSimpleEntity> subAccounts;
  final void Function({
    int? accountId,
    String? accountName,
    double? amount,
    String? lineDescription,
  })
  onChanged;
  final VoidCallback onDelete;
  final bool canDelete;

  const JournalItemRowForm({
    super.key,
    required this.index,
    required this.draft,
    required this.side,
    required this.subAccounts,
    required this.onChanged,
    required this.onDelete,
    this.canDelete = true,
  });

  @override
  State<JournalItemRowForm> createState() => _JournalItemRowFormState();
}

class _JournalItemRowFormState extends State<JournalItemRowForm> {
  late TextEditingController _accountController;
  late TextEditingController _amountController;
  late TextEditingController _descController;

  SubAccountSimpleEntity? _accoutSelected;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(
      text: widget.draft.account?.accountName ?? '',
    );
    _amountController = TextEditingController(
      text: widget.draft.amount > 0 ? widget.draft.amount.toString() : '',
    );
    _descController = TextEditingController(text: widget.draft.lineDescription);
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String? _validateAmounts() {
    final val = _amountController.text;
    final amountVal = double.tryParse(val) ?? 0.0;
    if (amountVal <= 0.0) {
      return 'أدخل مبلغاً صالحاً أكبر من الصفر';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Account Search Autocomplete ComboBox
          Expanded(
            flex: 4,
            child: ComboBoxForm<SubAccountSimpleEntity>(
              controller: _accountController,

              prefix: Padding(
                padding: const EdgeInsets.all(8.0),
                child: fluent.Icon(fluent.FluentIcons.account_browser),
              ),
              placeHolder: 'ابحث عن الحساب الفرعي...',
              validator: (_) {
                if (_accountController.text.trim().isEmpty) {
                  return 'الحساب مطلوب';
                }
                if (widget.draft.account == null) {
                  return 'اختر حساباً صالحاً من القائمة';
                }
                return null;
              },
              onChanged: (value) {
                if (widget.draft.account != null &&
                    value != widget.draft.account?.accountName) {
                  widget.onChanged(
                    accountId: null,
                    accountName: null,
                    amount: double.tryParse(
                      _amountController.text.replaceAll(',', ''),
                    ),
                    lineDescription: _descController.text,
                  );
                }
              },
              labelMenu: (opt) => '${opt.accountName} (${opt.accountNumber})',
              labelString: (opt) => opt.accountName,
              itemsBuilder: (query) {
                final normalized = query.toLowerCase();
                return widget.subAccounts.where((acc) {
                  return acc.accountName.toLowerCase().contains(normalized) ||
                      acc.accountNumber.contains(normalized);
                }).toList();
              },
              onSelectedItem: (selectedAcc) {
                _accoutSelected = selectedAcc;
                widget.onChanged(
                  accountId: selectedAcc.id,
                  accountName: selectedAcc.accountName,
                  amount: double.tryParse(
                    _amountController.text.replaceAll(',', ''),
                  ),
                  lineDescription: _descController.text,
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // Amount field (single) - shows debit or credit icon based on `side`
          Expanded(
            flex: 2,
            child: fluent.TextFormBox(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textDirection: TextDirection.ltr,
              placeholder: '0.00',
              prefix: Padding(
                padding: const EdgeInsets.all(8.0),
                child: fluent.Icon(
                  widget.side.isDebtor
                      ? fluent.FluentIcons.chevron_down
                      : fluent.FluentIcons.chevron_up,
                ),
              ),
              validator: (_) => _validateAmounts(),
              onChanged: (val) {
                widget.onChanged(
                  lineDescription: _descController.text,
                  accountId: _accoutSelected?.id,
                  amount: double.tryParse(val.replaceAll(',', '')) ?? 0.0,
                  accountName:
                      _accoutSelected?.accountName ?? _accountController.text,
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // 4. Line Description
          Expanded(
            flex: 4,
            child: fluent.TextFormBox(
              controller: _descController,
              placeholder: 'البيان التفصيلي للبند...',
              prefix: const Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Icon(fluent.FluentIcons.note_pinned),
              ),
              onChanged: (val) {
                widget.onChanged(
                  lineDescription: val,
                  accountId: _accoutSelected?.id,
                  amount:
                      double.tryParse(
                        _amountController.text.replaceAll(',', ''),
                      ) ??
                      0.0,
                  accountName:
                      _accoutSelected?.accountName ?? _accountController.text,
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // 5. Delete Button
          fluent.Tooltip(
            message: 'حذف البند',
            child: fluent.IconButton(
              icon: const fluent.Icon(
                fluent.FluentIcons.delete,
                color: Colors.red,
              ),
              onPressed: widget.canDelete ? widget.onDelete : null,
            ),
          ),
        ],
      ),
    );
  }
}
