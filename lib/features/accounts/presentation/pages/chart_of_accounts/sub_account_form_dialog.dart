import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';

// Enums
import 'package:flowcash/core/enums/sub_account_type_enum.dart';

// Entities
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';

// Bloc
import 'package:flowcash/features/accounts/presentation/blocs/sub_account_form/sub_account_form_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/sub_account_form/sub_account_form_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/sub_account_form/sub_account_form_state.dart';

class SubAccountFormDialog extends StatefulWidget {
  final int mainAccountId;
  final SubAccountEntity? subAccount;

  const SubAccountFormDialog({
    super.key,
    required this.mainAccountId,
    this.subAccount,
  });

  @override
  State<SubAccountFormDialog> createState() => _SubAccountFormDialogState();
}

class _SubAccountFormDialogState extends State<SubAccountFormDialog> {
  final _nameController = TextEditingController();
  final _maxBalanceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _maxBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) => GetIt.instance<SubAccountFormBloc>()
        ..add(
          InitSubAccountForm(
            mainAccountId: widget.mainAccountId,
            editingSubAccount: widget.subAccount,
          ),
        ),
      child: BlocConsumer<SubAccountFormBloc, SubAccountFormState>(
        listener: (context, state) {
          if (state.status == SubAccountFormStatus.success) {
            Navigator.of(context).pop(true);
          }
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.editingSubAccount != null && _nameController.text.isEmpty) {
            _nameController.text = state.accountName;
            if (state.balanceMax != null) {
              _maxBalanceController.text = state.balanceMax.toString();
            }
          }
        },
        builder: (context, state) {
          final bloc = context.read<SubAccountFormBloc>();
          final isEditing = state.editingSubAccount != null;

          if (state.status == SubAccountFormStatus.loading &&
              state.parentMainAccount == null) {
            return _SubaccountShimmer();
          }

          return ShimmerLoadingWidget(
            canShimmer: state.status == SubAccountFormStatus.loading,
            freezeScreen: state.status == SubAccountFormStatus.loading,
            period: const Duration(milliseconds: 900),
            child: AlertDialog(
            title: Row(
              children: [
                Icon(
                  isEditing ? Icons.edit_note : Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(isEditing ? 'تعديل حساب فرعي' : 'إضافة حساب فرعي جديد'),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Parent Main Account Name (Read Only)
                    if (state.parentMainAccount != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withAlpha(
                            100,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'الحساب الرئيسي: ${state.parentMainAccount!.accountName} (${state.parentMainAccount!.accountNumber})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),

                    // Account Name
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الحساب الفرعي',
                        
                        prefixIcon: Icon(Icons.label_important_outline),
                      ),
                      onChanged: (val) => bloc.add(SubAccountNameChanged(val)),
                    ),
                    const SizedBox(height: 16),

                    // SubAccountType
                    DropdownButtonFormField<SubAccountType>(
                      value: state.selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الحساب الفرعي',
                        
                        prefixIcon: Icon(Icons.account_tree_outlined),
                      ),
                      items: state.parentMainAccount == null
                          ? []
                          : SubAccountType.whereMainAccountType(
                              state.parentMainAccount!.mainAccountType,
                            ).map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName()),
                              );
                            }).toList(),
                      onChanged: (type) {
                        if (type != null) {
                          bloc.add(SubAccountTypeChanged(type));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Currency Dropdown
                    DropdownButtonFormField<String>(
                      value: state.selectedCurrencyId,
                      decoration: const InputDecoration(
                        labelText: 'العملة',
                        
                        prefixIcon: Icon(Icons.monetization_on_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('ريال يمني')),
                        DropdownMenuItem(value: '2', child: Text('ريال سعودي')),
                        DropdownMenuItem(
                          value: '3',
                          child: Text('دولار أمريكي'),
                        ),
                      ],
                      onChanged: (currId) {
                        if (currId != null) {
                          bloc.add(SubAccountCurrencyChanged(currId));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Max Balance Limit
                    TextField(
                      controller: _maxBalanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'الحد الأقصى للرصيد (اختياري)',
                        
                        prefixIcon: Icon(Icons.warning_amber_outlined),
                      ),
                      onChanged: (val) {
                        final numVal = double.tryParse(val);
                        bloc.add(SubAccountBalanceMaxChanged(numVal));
                      },
                    ),
                    const SizedBox(height: 20),

                    // Auto-generated Account Number Info
                    if (state.accountNumber.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.colorScheme.primary.withAlpha(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'رقم الحساب المتولد تلقائياً:',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              state.accountNumber,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: state.status == SubAccountFormStatus.loading
                    ? null
                    : () => bloc.add(const SubmitSubAccountForm()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: state.status == SubAccountFormStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('حفظ'),
              ),
            ],
            ),
          );
        },
      ),
    );
  }
}

class _SubaccountShimmer extends StatelessWidget {
  const _SubaccountShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: AppShimmer(
        child: SizedBox(
          width: 450,
          height: 260,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: const [
              ShimmerPlaceholder(height: 48),
              SizedBox(height: 16),
              ShimmerPlaceholder(height: 48),
              SizedBox(height: 16),
              ShimmerPlaceholder(height: 48),
              SizedBox(height: 16),
              ShimmerPlaceholder(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
