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
        child: AlertDialog(
          title: Text(
            widget.initialValue == null
                ? 'إضافة قيمة مستودع'
                : 'تعديل قيمة مستودع',
          ),
          scrollable: true,
          content: BlocBuilder<WarehouseValueFormBloc, WarehouseValueFormState>(
            builder: (context, state) {
              if (_isLoading) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final filteredSubAccounts = _filterSubAccounts(state.valueType);
              final int? selectedSubAccountId = int.tryParse(state.valueText);

              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: state.warehouseId > 0 ? state.warehouseId : null,
                      decoration: const InputDecoration(
                        labelText: 'المستودع',
                        
                        prefixIcon: Icon(Icons.store),
                      ),
                      items: _warehouses.map((warehouse) {
                        return DropdownMenuItem(
                          value: warehouse.id,
                          child: Text(warehouse.warehouseName),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value <= 0) {
                          return 'الرجاء اختيار مستودع';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value == null) return;
                        context.read<WarehouseValueFormBloc>().add(
                          WarehouseValueFormWarehouseIdChanged(value),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<WarehouseValueType>(
                      value: state.valueType,
                      decoration: const InputDecoration(
                        labelText: 'نوع القيمة',
                        
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: WarehouseValueType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        context.read<WarehouseValueFormBloc>().add(
                          WarehouseValueFormTypeChanged(value),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value:
                          selectedSubAccountId != null &&
                              filteredSubAccounts.any(
                                (a) => a.id == selectedSubAccountId,
                              )
                          ? selectedSubAccountId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'الحساب الفرعي',
                        
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                      items: filteredSubAccounts.map((account) {
                        return DropdownMenuItem(
                          value: account.id,
                          child: Text(account.accountName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        context.read<WarehouseValueFormBloc>().add(
                          WarehouseValueFormValueChanged(
                            value?.toString() ?? '',
                          ),
                        );
                      },
                    ),
                    if (filteredSubAccounts.isEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'لا توجد حسابات فرعية لهذا النوع',
                        style: Theme.of(context).textTheme.bodySmall,
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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
