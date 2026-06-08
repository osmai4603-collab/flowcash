import 'package:flowcash/core/theme/spacings.dart';
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
  final List<WarehouseEntity> _parentWarehouses = [];
  bool _isLoadingParents = true;
  String? _parentLoadError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialValue?.warehouseName ?? '',
    );
    _locationController = TextEditingController(
      text: widget.initialValue?.location ?? '',
    );
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
        final parentRoots = warehouses
            .where((warehouse) => warehouse.parentId == null)
            .toList();
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
      child: Builder(
        builder: (context) {
          return BlocListener<WarehouseFormBloc, WarehouseFormState>(
            listener: (context, state) {
              if (state.isSuccess && state.savedEntity != null) {
                Navigator.of(context).pop(state.savedEntity);
              }
            },
            child: fluent.ContentDialog(
              constraints: const BoxConstraints(maxWidth: 400, minWidth: 400),
              title: fluent.Text(
                widget.initialValue == null ? 'إضافة مستودع' : 'تعديل المستودع',
              ),

              content: BlocBuilder<WarehouseFormBloc, WarehouseFormState>(
                builder: (context, state) {
                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        spacing: Spacings.small,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          fluent.InfoLabel(
                            label: 'اسم المستودع',
                            child: fluent.TextFormBox(
                              controller: _nameController,
                              placeholder: 'اسم المستودع',
                              // prefix: const Padding(
                              //   padding: EdgeInsets.all(8.0),
                              //   child: fluent.Icon(fluent.FluentIcons.store_logo16),
                              // ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'الرجاء إدخال اسم المستودع';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                context.read<WarehouseFormBloc>().add(
                                  WarehouseFormNameChanged(value),
                                );
                              },
                            ),
                          ),
                          fluent.InfoLabel(
                            label: 'العنوان',
                            child: fluent.TextFormBox(
                              controller: _locationController,
                              placeholder: 'العنوان',
                              // prefix: const Padding(
                              //   padding: EdgeInsets.all(8.0),
                              //   child: fluent.Icon(fluent.FluentIcons.location),
                              // ),
                              onChanged: (value) {
                                context.read<WarehouseFormBloc>().add(
                                  WarehouseFormLocationChanged(value),
                                );
                              },
                            ),
                          ),
                          fluent.Row(
                            children: [
                              fluent.Expanded(
                                child: fluent.InfoLabel(
                                  label: 'نوع المستودع',
                                  child:
                                      fluent.ComboboxFormField<WarehouseType>(
                                        value: state.warehouse.warehouseType,
                                        isExpanded: true,
                                        items: WarehouseType.values.map((
                                          warehouseType,
                                        ) {
                                          return fluent.ComboBoxItem<
                                            WarehouseType
                                          >(
                                            value: warehouseType,
                                            child: fluent.Text(
                                              warehouseType.displayName(),
                                            ),
                                          );
                                        }).toList(),
                                        placeholder: const fluent.Text(
                                          'حدد نوع مستودع',
                                        ),
                                        onChanged: (value) {
                                          if (value != null) {
                                            context
                                                .read<WarehouseFormBloc>()
                                                .add(
                                                  WarehouseFormTypeChanged(
                                                    value,
                                                  ),
                                                );
                                          }
                                        },
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              fluent.Expanded(
                                child: fluent.InfoLabel(
                                  label: 'المستودع الأب (اختياري)',
                                  child: fluent.ComboboxFormField<int?>(
                                    value: state.warehouse.parentId,
                                    isExpanded: true,
                                    items: [
                                      const fluent.ComboBoxItem<int?>(
                                        value: null,
                                        child: fluent.Text('لا يوجد مستودع أب'),
                                      ),
                                      ..._parentWarehouses.map(
                                        (
                                          warehouse,
                                        ) => fluent.ComboBoxItem<int?>(
                                          value: warehouse.id,
                                          child: fluent.Text(
                                            '${warehouse.warehouseName} (${warehouse.id})',
                                          ),
                                        ),
                                      ),
                                    ],
                                    placeholder: fluent.Text(
                                      _isLoadingParents
                                          ? 'جاري تحميل المستودعات...'
                                          : 'حدد مستودع أب',
                                    ),
                                    onChanged: _isLoadingParents
                                        ? null
                                        : (value) {
                                            context
                                                .read<WarehouseFormBloc>()
                                                .add(
                                                  WarehouseFormParentIdChanged(
                                                    value,
                                                  ),
                                                );
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_isLoadingParents)
                            const LinearProgressIndicator(),

                          if (_parentLoadError != null)
                            fluent.SelectableText(
                              _parentLoadError!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          if (state.errorMessage != null)
                            fluent.SelectableText(
                              state.errorMessage!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                        ],
                      ),
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
                    context.read<WarehouseFormBloc>().add(
                      WarehouseFormSubmitted(),
                    );
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
          );
        },
      ),
    );
  }
}
