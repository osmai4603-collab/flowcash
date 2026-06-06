import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_value_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_value_usecases.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouse_values/warehouse_value_form_bloc.dart';
import 'package:flowcash/core/enums/warehouse_value_type_enum.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
class WarehouseValueFormPage extends StatefulWidget {
  const WarehouseValueFormPage({super.key, this.initialValue});

  final WarehouseValueEntity? initialValue;

  @override
  State<WarehouseValueFormPage> createState() => _WarehouseValueFormPageState();
}

class _WarehouseValueFormPageState extends State<WarehouseValueFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _warehouseController = TextEditingController();
  final _valueTypeController = TextEditingController();
  final _subAccountController = TextEditingController();
  List<WarehouseEntity> _warehouses = [];
  List<SubAccountEntity> _subAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLookupData();
  }

  Future<void> _loadLookupData() async {
    final warehousesRes = await GetIt.instance<GetWarehousesUseCase>().call();
    final subAccountsRes = await GetIt.instance<GetSubAccountsUseCase>().call();

    if (!mounted) return;

    warehousesRes.fold((_) => _warehouses = [], (list) => _warehouses = list);

    subAccountsRes.fold(
      (_) => _subAccounts = [],
      (list) => _subAccounts = list,
    );

    setState(() {
      _isLoading = false;
    });
  }

  List<SubAccountEntity> _filterSubAccounts(WarehouseValueType valueType) {
    switch (valueType) {
      case DefaultSalesAccount():
        return _subAccounts
            .where((a) => a.subAccountType == SubAccountType.sales)
            .toList();
      case DefaultBuysAccount():
        return _subAccounts
            .where(
              (a) =>
                  a.subAccountType == SubAccountType.buys ||
                  a.subAccountType == SubAccountType.costOfGoodsSold,
            )
            .toList();
      case DefaultBackSalesAccount():
        return _subAccounts
            .where((a) => a.subAccountType == SubAccountType.salesReturn)
            .toList();
      case DefaultBackBuysAccount():
        return _subAccounts
            .where((a) => a.subAccountType == SubAccountType.buysReturn)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WarehouseValueFormBloc(
        initialValue: widget.initialValue,
        insertWarehouseValueUseCase:
            GetIt.instance<InsertWarehouseValueUseCase>(),
        updateWarehouseValueUseCase:
            GetIt.instance<UpdateWarehouseValueUseCase>(),
      ),
      child: BlocListener<WarehouseValueFormBloc, WarehouseValueFormState>(
        listener: (context, state) {
          if (state.isSuccess && state.savedEntity != null) {
            Navigator.of(context).pop(state.savedEntity);
          }
        },
        child: fluent.ContentDialog(
          title: fluent.Text(
            widget.initialValue == null
                ? 'إضافة قيمة مستودع'
                : 'تعديل قيمة مستودع',
          ),
          
          content: BlocBuilder<WarehouseValueFormBloc, WarehouseValueFormState>(
            builder: (context, state) {
              if (_isLoading) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: fluent.ProgressRing()),
                );
              }

              final filteredSubAccounts = _filterSubAccounts(state.valueType);
              final int? selectedSubAccountId = int.tryParse(state.valueText);

              if (_warehouseController.text.isEmpty && state.warehouseId > 0 && _warehouses.isNotEmpty) {
                final selectedWarehouse = _warehouses.firstWhere(
                  (warehouse) => warehouse.id == state.warehouseId,
                  orElse: () => _warehouses.first,
                );
                if (selectedWarehouse.id > 0) {
                  _warehouseController.text = selectedWarehouse.warehouseName;
                }
              }

              if (_valueTypeController.text.isEmpty) {
                _valueTypeController.text = state.valueType.displayName();
              }

              if (_subAccountController.text.isEmpty && selectedSubAccountId != null && filteredSubAccounts.isNotEmpty) {
                final selectedAccount = filteredSubAccounts.firstWhere(
                  (account) => account.id == selectedSubAccountId,
                  orElse: () => filteredSubAccounts.first,
                );
                if (selectedAccount.id > 0) {
                  _subAccountController.text = selectedAccount.accountName;
                }
              }

              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fluent.InfoLabel(
                      label: 'المستودع',
                      child: fluent.AutoSuggestBox<int>.form(
                        controller: _warehouseController,
                        items: _warehouses.map((warehouse) {
                          return fluent.AutoSuggestBoxItem<int>(
                            value: warehouse.id,
                            label: warehouse.warehouseName,
                          );
                        }).toList(),
                        leadingIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.store_logo16),
                        ),
                        placeholder: 'حدد المستودع',
                        validator: (text) {
                          if (state.warehouseId <= 0) {
                            return 'الرجاء اختيار مستودع';
                          }
                          return null;
                        },
                        onSelected: (item) {
                          _warehouseController.text = item.label;
                          context.read<WarehouseValueFormBloc>().add(
                            WarehouseValueFormWarehouseIdChanged(item.value!),
                          );
                        },
                        noResultsFoundBuilder: (_) => const fluent.Text('لا توجد مستودعات'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'نوع القيمة',
                      child: fluent.AutoSuggestBox<WarehouseValueType>.form(
                        controller: _valueTypeController,
                        items: WarehouseValueType.values.map((type) {
                          return fluent.AutoSuggestBoxItem<WarehouseValueType>(
                            value: type,
                            label: type.displayName(),
                          );
                        }).toList(),
                        leadingIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.category_classification),
                        ),
                        placeholder: 'حدد نوع القيمة',
                        onSelected: (item) {
                          _valueTypeController.text = item.label;
                          context.read<WarehouseValueFormBloc>().add(
                            WarehouseValueFormTypeChanged(item.value!),
                          );
                        },
                        noResultsFoundBuilder: (_) => const fluent.Text('لا توجد قيم'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    fluent.InfoLabel(
                      label: 'الحساب الفرعي',
                      child: fluent.AutoSuggestBox<int>.form(
                        controller: _subAccountController,
                        items: filteredSubAccounts.map((account) {
                          return fluent.AutoSuggestBoxItem<int>(
                            value: account.id,
                            label: account.accountName,
                          );
                        }).toList(),
                        leadingIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(fluent.FluentIcons.accounts),
                        ),
                        placeholder: 'حدد الحساب الفرعي',
                        enabled: filteredSubAccounts.isNotEmpty,
                        onSelected: (item) {
                          _subAccountController.text = item.label;
                          context.read<WarehouseValueFormBloc>().add(
                            WarehouseValueFormValueChanged(
                              item.value.toString(),
                            ),
                          );
                        },
                        noResultsFoundBuilder: (_) => const fluent.Text('لا توجد حسابات فرعية'),
                      ),
                    ),
                    if (filteredSubAccounts.isEmpty) ...[
                      const SizedBox(height: 8),
                      fluent.Text(
                        'لا توجد حسابات فرعية لهذا النوع',
                        style: Theme.of(context).textTheme.bodySmall,
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
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                context.read<WarehouseValueFormBloc>().add(
                  WarehouseValueFormSubmitted(),
                );
              },
              child:
                  BlocBuilder<WarehouseValueFormBloc, WarehouseValueFormState>(
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
