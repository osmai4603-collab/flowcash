import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_value_usecases.dart';

class WarehouseValueEditDialog extends StatefulWidget {
  const WarehouseValueEditDialog({super.key, required this.value});

  final WarehouseValueEntity value;

  @override
  State<WarehouseValueEditDialog> createState() => _WarehouseValueEditDialogState();
}

class _WarehouseValueEditDialogState extends State<WarehouseValueEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  bool _isSaving = false;
  bool _isLoadingSubAccount = false;
  String? _errorMessage;
  SubAccountEntity? _subAccount;

  UpdateWarehouseValueUseCase get _updateUseCase => GetIt.instance<UpdateWarehouseValueUseCase>();
  GetSubAccountByIdUseCase get _getSubAccountByIdUseCase => GetIt.instance<GetSubAccountByIdUseCase>();

  @override
  void initState() {
    super.initState();
    _accountController.text = widget.value.value?.toString() ?? '';
    _loadSubAccount();
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _loadSubAccount() async {
    final valueString = _accountController.text.trim();
    final id = int.tryParse(valueString);
    if (id == null) {
      return;
    }

    setState(() {
      _isLoadingSubAccount = true;
    });

    final result = await _getSubAccountByIdUseCase(id);
    result.match(
      (_) {
        setState(() {
          _subAccount = null;
          _isLoadingSubAccount = false;
        });
      },
      (subAccount) {
        setState(() {
          _subAccount = subAccount;
          _isLoadingSubAccount = false;
        });
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final text = _accountController.text.trim();
    final Object? newValue = text.isEmpty ? null : int.tryParse(text) ?? text;

    final updatedEntity = widget.value.copyWith(value: newValue);
    final result = await _updateUseCase(updatedEntity);

    result.match(
      (failure) {
        setState(() {
          _isSaving = false;
          _errorMessage = failure.message;
        });
      },
      (_) {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      scrollable: true,
      title: const Text('تعديل قيمة المستودع'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('المستودع: ${widget.value.warehouseId}', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('النوع: ${widget.value.valueType.displayName()}', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _accountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  decoration: const InputDecoration(
                    labelText: 'رقم الحساب الفرعي',
                    hintText: 'اتركه فارغًا إذا لم يكن مرتبطًا',
                    
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'الرجاء إدخال رقم حساب فرعي صحيح أو ترك الحقل فارغًا';
                    }
                    return null;
                  },
                  onChanged: (_) => _loadSubAccount(),
                ),
                const SizedBox(height: 12),
                if (_isLoadingSubAccount) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 12),
                ],
                if (_subAccount != null) ...[
                  Text('الحساب الفرعي الحالي:', style: theme.textTheme.bodyMedium),
                  Text('${_subAccount!.accountNumber} - ${_subAccount!.accountName}', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 12),
                ],
                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ'),
        ),
      ],
    );
  }
}
