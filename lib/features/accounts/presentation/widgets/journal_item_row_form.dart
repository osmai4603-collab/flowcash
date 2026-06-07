import 'package:flutter/material.dart';
import 'package:flowcash/widgets/combo_box_form.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_simple_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entry_form/journal_entry_form_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class JournalItemRowForm extends StatefulWidget {
  final int index;
  final JournalItemDraft draft;
  final JournalItemSide side;
  final List<SubAccountSimpleEntity> subAccounts;
  final void Function({
    int? accountId,
    String? accountName,
    double? debit,
    double? credit,
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
  late TextEditingController _debitController;
  late TextEditingController _creditController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _accountController = TextEditingController(
      text: widget.draft.accountName ?? '',
    );
    _debitController = TextEditingController(
      text: widget.draft.debit > 0 ? widget.draft.debit.toString() : '',
    );
    _creditController = TextEditingController(
      text: widget.draft.credit > 0 ? widget.draft.credit.toString() : '',
    );
    _descController = TextEditingController(text: widget.draft.lineDescription);
  }

  // @override
  // void didUpdateWidget(covariant JournalItemRowForm oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.draft.accountName != _accountController.text) {
  //     _accountController.text = widget.draft.accountName ?? '';
  //   }
  //   final targetDebitStr = widget.draft.debit > 0 ? widget.draft.debit.toString() : '';
  //   if (targetDebitStr != _debitController.text) {
  //     _debitController.text = targetDebitStr;
  //   }
  //   final targetCreditStr = widget.draft.credit > 0 ? widget.draft.credit.toString() : '';
  //   if (targetCreditStr != _creditController.text) {
  //     _creditController.text = targetCreditStr;
  //   }
  //   if (widget.draft.lineDescription != _descController.text) {
  //     _descController.text = widget.draft.lineDescription;
  //   }
  // }

  @override
  void dispose() {
    _accountController.dispose();
    _debitController.dispose();
    _creditController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String? _validateAmounts() {
    final debitVal = double.tryParse(_debitController.text) ?? 0.0;
    final creditVal = double.tryParse(_creditController.text) ?? 0.0;
    if (debitVal > 0 && creditVal > 0) {
      return 'لا يمكن أن يحتوي البند على مدين ودائن معًا';
    }
    if (debitVal == 0.0 && creditVal == 0.0) {
      return 'أدخل مبلغاً للمدين أو الدائن';
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
                if (widget.draft.accountId == null) {
                  return 'اختر حساباً صالحاً من القائمة';
                }
                return null;
              },
              onChanged: (value) {
                if (widget.draft.accountId != null &&
                    value != widget.draft.accountName) {
                  widget.onChanged(accountId: null, accountName: null);
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
                widget.onChanged(
                  accountId: selectedAcc.id,
                  accountName: selectedAcc.accountName,
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // Amount field (single) - shows debit or credit based on `side`
          Expanded(
            flex: 2,
            child: widget.side == JournalItemSide.debit
                ? fluent.TextFormBox(
                    controller: _debitController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textDirection: TextDirection.ltr,
                    placeholder: '0.00',
                    prefix: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: fluent.Icon(fluent.FluentIcons.chevron_down),
                    ),
                    validator: (_) => _validateAmounts(),
                    onChanged: (val) {
                      final debitVal = double.tryParse(val) ?? 0.0;
                      widget.onChanged(debit: debitVal);
                    },
                  )
                : fluent.TextFormBox(
                    controller: _creditController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textDirection: TextDirection.ltr,
                    placeholder: '0.00',
                    prefix: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: fluent.Icon(fluent.FluentIcons.chevron_up),
                    ),
                    validator: (_) => _validateAmounts(),
                    onChanged: (val) {
                      final creditVal = double.tryParse(val) ?? 0.0;
                      widget.onChanged(credit: creditVal);
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
                widget.onChanged(lineDescription: val);
              },
            ),
          ),
          const SizedBox(width: 8),

          // 5. Delete Button
          IconButton(
            icon: const fluent.Icon(
              fluent.FluentIcons.delete,
              color: Colors.red,
            ),
            onPressed: widget.canDelete ? widget.onDelete : null,
          ),
        ],
      ),
    );
  }
}
