import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/enums/warehouse_type_enum.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouses/warehouse_form_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
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
  late final TextEditingController _warehouseTypeController;
  late final TextEditingController _parentWarehouseController;
  final List<WarehouseEntity> _parentWarehouses = [];
  bool _isLoadingParents = true;
  String? _parentLoadError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue?.warehouseName ?? '');
    _locationController = TextEditingController(text: widget.initialValue?.location ?? '');
    _warehouseTypeController = TextEditingController(
      text: widget.initialValue?.warehouseType.displayName() ?? '',
    );
    _parentWarehouseController = TextEditingController();
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
        final parentRoots = warehouses.where((warehouse) => warehouse.parentId == null).toList();
        final selectedParent = parentRoots.where((warehouse) => warehouse.id == widget.initialValue?.parentId).toList();
        if (selectedParent.isNotEmpty) {
          _parentWarehouseController.text = '${selectedParent.first.warehouseName} (${selectedParent.first.id})';
        }
        setState(() {
          _parentWarehouses
            ..clear()
            ..addAll(parentRoots);
          _isLoadingParents = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _warehouseTypeController.dispose();
    _parentWarehouseController.dispose();
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
        child: fluent.ContentDialog(
          constraints: const BoxConstraints(maxWidth: 400, minWidth: 400),
          title: fluent.Text(widget.initialValue == null ? 'إضافة مستودع' : 'تعديل المستودع'),
          
          content: BlocBuilder<WarehouseFormBloc, WarehouseFormState>(
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fluent.InfoLabel(
                      label: 'اسم المستودع',
                      child: fluent.TextFormBox(
                        controller: _nameController,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.store_logo16),
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
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'العنوان',
                      child: fluent.TextFormBox(
                        controller: _locationController,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.location),
                        ),
                        onChanged: (value) {
                          context.read<WarehouseFormBloc>().add(WarehouseFormLocationChanged(value));
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'نوع المستودع',
                      child: fluent.AutoSuggestBox<WarehouseType>.form(
                        controller: _warehouseTypeController,
                        items: WarehouseType.values.map((warehouseType) {
                          return fluent.AutoSuggestBoxItem<WarehouseType>(
                            value: warehouseType,
                            label: warehouseType.displayName(),
                          );
                        }).toList(),
                        leadingIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.category_classification),
                        ),
                        placeholder: 'حدد نوع مستودع',
                        onSelected: (item) {
                          _warehouseTypeController.text = item.label;
                          context.read<WarehouseFormBloc>().add(WarehouseFormTypeChanged(item.value!));
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'المستودع الأب (اختياري)',
                      child: fluent.AutoSuggestBox<int?>.form(
                        controller: _parentWarehouseController,
                        items: [
                          fluent.AutoSuggestBoxItem<int?>(
                            value: null,
                            label: 'لا يوجد مستودع أب',
                          ),
                          ..._parentWarehouses.map(
                            (warehouse) => fluent.AutoSuggestBoxItem<int?>(
                              value: warehouse.id,
                              label: '${warehouse.warehouseName} (${warehouse.id})',
                            ),
                          ),
                        ],
                        leadingIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.account_management),
                        ),
                        placeholder: _isLoadingParents
                            ? 'جاري تحميل المستودعات...'
                            : 'حدد مستودع أب',
                        enabled: !_isLoadingParents,
                        onSelected: (item) {
                          _parentWarehouseController.text = item.label;
                          context.read<WarehouseFormBloc>().add(WarehouseFormParentIdChanged(item.value));
                        },
                        noResultsFoundBuilder: (_) => const fluent.Text('لا يوجد نتائج'),
                      ),
                    ),
                    if (_isLoadingParents) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(),
                    ],
                    if (_parentLoadError != null) ...[
                      const SizedBox(height: 12),
                      fluent.Text(
                        _parentLoadError!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                    ],
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      fluent.Text(
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
            fluent.Button(
              onPressed: () => Navigator.of(context).pop(),
              child: const fluent.Text('إلغاء'),
            ),
            fluent.FilledButton(
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
                          child: fluent.ProgressRing(strokeWidth: 2),
                        )
                      : const fluent.Text('حفظ');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
