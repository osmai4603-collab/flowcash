import 'package:flowcash/core/enums/sub_account_type_enum.dart';
import 'package:flowcash/core/theme/spacings.dart';
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
  List<WarehouseEntity> _warehouses = [];
  List<SubAccountEntity> _subAccounts = [];
  bool _isLoading = true;
  WarehouseEntity? warehouseSelected;
  SubAccountEntity? subAccountSelected;

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

    final initialWarehouseId = widget.initialValue?.warehouseId ?? 0;
    warehouseSelected =
        initialWarehouseId > 0 &&
            _warehouses.any((w) => w.id == initialWarehouseId)
        ? _warehouses.firstWhere((w) => w.id == initialWarehouseId)
        : null;

    final initialValueText = widget.initialValue?.value?.toString() ?? '';
    final initialValueType =
        widget.initialValue?.valueType ?? WarehouseValueType.values.first;
    final int? selectedSubAccountId = int.tryParse(initialValueText);
    final filteredSubAccounts = _filterSubAccounts(initialValueType);
    subAccountSelected =
        selectedSubAccountId != null &&
            filteredSubAccounts.any((a) => a.id == selectedSubAccountId)
        ? filteredSubAccounts.firstWhere((a) => a.id == selectedSubAccountId)
        : null;

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
      child: Builder(
        builder: (context) {
          return BlocListener<WarehouseValueFormBloc, WarehouseValueFormState>(
            listener: (context, state) {
              if (state.isSuccess && state.savedEntity != null) {
                Navigator.of(context).pop(state.savedEntity);
              }

              final newWarehouse =
                  state.warehouseId > 0 &&
                      _warehouses.any((w) => w.id == state.warehouseId)
                  ? _warehouses.firstWhere((w) => w.id == state.warehouseId)
                  : null;

              final int? selectedSubAccountId = int.tryParse(state.valueText);
              final filteredSubAccounts = _filterSubAccounts(state.valueType);
              final newSubAccount =
                  selectedSubAccountId != null &&
                      filteredSubAccounts.any(
                        (a) => a.id == selectedSubAccountId,
                      )
                  ? filteredSubAccounts.firstWhere(
                      (a) => a.id == selectedSubAccountId,
                    )
                  : null;

              if (newWarehouse != warehouseSelected ||
                  newSubAccount != subAccountSelected) {
                setState(() {
                  warehouseSelected = newWarehouse;
                  subAccountSelected = newSubAccount;
                });
              }
            },
            child: fluent.ContentDialog(
              constraints: const BoxConstraints(maxWidth: 400, minWidth: 400),
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

                  final filteredSubAccounts = _filterSubAccounts(
                    state.valueType,
                  );

                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        spacing: Spacings.small,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          fluent.InfoLabel(
                            label: 'المستودع',
                            child: fluent.ComboboxFormField<WarehouseEntity>(
                              value: warehouseSelected,
                              isExpanded: true,
                              items: _warehouses.map((warehouse) {
                                return fluent.ComboBoxItem<WarehouseEntity>(
                                  value: warehouse,
                                  child: fluent.Text(warehouse.warehouseName),
                                );
                              }).toList(),
                              placeholder: const fluent.Text('حدد المستودع'),
                              validator: (value) {
                                if (value == null) {
                                  return 'الرجاء اختيار مستودع';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    warehouseSelected = value;
                                  });
                                  context.read<WarehouseValueFormBloc>().add(
                                    WarehouseValueFormWarehouseIdChanged(
                                      value.id,
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          fluent.InfoLabel(
                            label: 'نوع القيمة',
                            child: fluent.ComboboxFormField<WarehouseValueType>(
                              value: state.valueType,
                              isExpanded: true,
                              items: WarehouseValueType.values.map((type) {
                                return fluent.ComboBoxItem<WarehouseValueType>(
                                  value: type,
                                  child: fluent.Text(type.displayName()),
                                );
                              }).toList(),
                              placeholder: const fluent.Text('حدد نوع القيمة'),
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<WarehouseValueFormBloc>().add(
                                    WarehouseValueFormTypeChanged(value),
                                  );
                                }
                              },
                            ),
                          ),
                          fluent.InfoLabel(
                            label: 'الحساب الفرعي',
                            child: fluent.ComboboxFormField<SubAccountEntity>(
                              value: subAccountSelected,
                              isExpanded: true,
                              items: filteredSubAccounts.map((account) {
                                return fluent.ComboBoxItem<SubAccountEntity>(
                                  value: account,
                                  child: fluent.Text(account.accountName),
                                );
                              }).toList(),
                              placeholder: const fluent.Text(
                                'حدد الحساب الفرعي',
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'الرجاء اختيار الحساب الفرعي';
                                }
                                return null;
                              },
                              onChanged: filteredSubAccounts.isEmpty
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        setState(() {
                                          subAccountSelected = value;
                                        });
                                        context
                                            .read<WarehouseValueFormBloc>()
                                            .add(
                                              WarehouseValueFormValueChanged(
                                                value.id.toString(),
                                              ),
                                            );
                                      }
                                    },
                            ),
                          ),
                          if (filteredSubAccounts.isEmpty)
                            fluent.Text(
                              'لا توجد حسابات فرعية لهذا النوع',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          if (state.errorMessage != null)
                            fluent.Text(
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
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    context.read<WarehouseValueFormBloc>().add(
                      WarehouseValueFormSubmitted(),
                    );
                  },
                  child:
                      BlocBuilder<
                        WarehouseValueFormBloc,
                        WarehouseValueFormState
                      >(
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
