import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, ProgressRing;
class WarehouseEditDialog extends StatefulWidget {
  const WarehouseEditDialog({super.key, required this.warehouse});

  final WarehouseEntity warehouse;

  @override
  State<WarehouseEditDialog> createState() => _WarehouseEditDialogState();
}

class _WarehouseEditDialogState extends State<WarehouseEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;

  UpdateWarehouseUseCase get _updateWarehouseUseCase => GetIt.instance<UpdateWarehouseUseCase>();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.warehouse.warehouseName;
    _locationController.text = widget.warehouse.location;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final updatedWarehouse = widget.warehouse.copyWith(
      warehouseName: _nameController.text.trim(),
      location: _locationController.text.trim(),
    );

    final result = await _updateWarehouseUseCase(updatedWarehouse);
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

    return ContentDialog(
      title: const Text('تعديل المستودع'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستودع',
                      
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال اسم المستودع';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
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
                  child: ProgressRing(strokeWidth: 2),
                )
              : const Text('حفظ التغيير'),
        ),
      ],
    );
  }
}
