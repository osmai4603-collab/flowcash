import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/enums/warehouse_type_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouses/warehouse_form_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, FluentIcons, ProgressRing;
class WarehouseFormPage extends StatefulWidget {
  const WarehouseFormPage({super.key, this.initialValue});

  final WarehouseEntity? initialValue;

  @override
  State<WarehouseFormPage> createState() => _WarehouseFormPageState();
}

class _WarehouseFormPageState extends State<WarehouseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  final List<WarehouseEntity> _parentWarehouses = [];
  bool _isLoadingParents = true;
  String? _parentLoadError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue?.warehouseName ?? '');
    _locationController = TextEditingController(text: widget.initialValue?.location ?? '');
    _loadParentWarehouses();
  }

  Future<void> _loadParentWarehouses() async {
    final result = await GetIt.instance<GetWarehousesUseCase>().call();
    result.match(
      (failure) {
        if (!mounted) return;
        setState(() {
          _parentLoadError = failure.message;
          _isLoadingParents = false;
        });
      },
      (warehouses) {
        if (!mounted) return;
        setState(() {
          _parentWarehouses
            ..clear()
            ..addAll(warehouses.where((warehouse) => warehouse.parentId == null));
          _isLoadingParents = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WarehouseFormBloc(
        initialValue: widget.initialValue,
        insertWarehouseUseCase: GetIt.instance<InsertWarehouseUseCase>(),
        updateWarehouseUseCase: GetIt.instance<UpdateWarehouseUseCase>(),
      ),
      child: BlocListener<WarehouseFormBloc, WarehouseFormState>(
        listener: (context, state) {
          if (state.isSuccess && state.savedEntity != null) {
            Navigator.of(context).pop(state.savedEntity);
          }
        },
        child: ContentDialog(
          constraints: const BoxConstraints(maxWidth: 400, minWidth: 400),
          title: Text(widget.initialValue == null ? 'إضافة مستودع' : 'تعديل المستودع'),
          
          content: BlocBuilder<WarehouseFormBloc, WarehouseFormState>(
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المستودع',
                        
                        prefixIcon: Icon(FluentIcons.store_logo16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال اسم المستودع';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        context.read<WarehouseFormBloc>().add(WarehouseFormNameChanged(value));
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        
                        prefixIcon: Icon(FluentIcons.location),
                      ),
                      onChanged: (value) {
                        context.read<WarehouseFormBloc>().add(WarehouseFormLocationChanged(value));
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<WarehouseType>(
                      initialValue: state.warehouse.warehouseType,
                      decoration: const InputDecoration(
                        labelText: 'نوع المستودع',
                        
                        prefixIcon: Icon(FluentIcons.category_classification),
                      ),
                      items: WarehouseType.values.map((warehouseType) {
                        return DropdownMenuItem(
                          value: warehouseType,
                          child: Text(warehouseType.displayName()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        context.read<WarehouseFormBloc>().add(WarehouseFormTypeChanged(value));
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      initialValue: state.warehouse.parentId,
                      decoration: const InputDecoration(
                        labelText: 'المستودع الأب (اختياري)',
                        
                        prefixIcon: Icon(FluentIcons.account_management),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('لا يوجد مستودع أب'),
                        ),
                        ..._parentWarehouses.map(
                          (warehouse) => DropdownMenuItem<int?>(
                            value: warehouse.id,
                            child: Text('${warehouse.warehouseName} (${warehouse.id})'),
                          ),
                        ),
                      ],
                      onChanged: _isLoadingParents
                          ? null
                          : (value) {
                              context.read<WarehouseFormBloc>().add(WarehouseFormParentIdChanged(value));
                            },
                    ),
                    if (_isLoadingParents) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                    if (_parentLoadError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _parentLoadError!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;
                context.read<WarehouseFormBloc>().add(WarehouseFormSubmitted());
              },
              child: BlocBuilder<WarehouseFormBloc, WarehouseFormState>(
                builder: (context, state) {
                  return state.isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: ProgressRing(strokeWidth: 2),
                        )
                      : const Text('حفظ');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
