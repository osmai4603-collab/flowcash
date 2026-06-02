import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';

// Enums
import 'package:flowcash/core/enums/main_account_group_enum.dart';
import 'package:flowcash/core/enums/main_account_type_enum.dart';

// Entities
import 'package:flowcash/features/accounts/domain/entities/main_account_entity.dart';

// Bloc
import 'package:flowcash/features/accounts/presentation/blocs/main_account_form/main_account_form_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/main_account_form/main_account_form_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/main_account_form/main_account_form_state.dart';

class MainAccountFormDialog extends StatefulWidget {
  final MainAccountEntity? mainAccount;

  const MainAccountFormDialog({super.key, this.mainAccount});

  @override
  State<MainAccountFormDialog> createState() => _MainAccountFormDialogState();
}

class _MainAccountFormDialogState extends State<MainAccountFormDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          GetIt.instance<MainAccountFormBloc>()
            ..add(InitMainAccountForm(editingAccount: widget.mainAccount)),
      child: BlocConsumer<MainAccountFormBloc, MainAccountFormState>(
        listener: (context, state) {
          if (state.status == MainAccountFormStatus.success) {
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
          if (state.editingAccount != null && _nameController.text.isEmpty) {
            _nameController.text = state.accountName;
          }
        },
        builder: (context, state) {
          final bloc = context.read<MainAccountFormBloc>();
          final isEditing = state.editingAccount != null;

          if (state.status == MainAccountFormStatus.loading) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note : Icons.add_business_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(isEditing ? 'جاري تحميل نموذج الحساب' : 'جاري إنشاء نموذج الحساب'),
                ],
              ),
              content: AppShimmer(
                child: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      ShimmerPlaceholder(height: 48),
                      SizedBox(height: 16),
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
              actions: [
                TextButton(onPressed: null, child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: null,
                  child: const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          }

          return ShimmerLoadingWidget(
            canShimmer: state.status == MainAccountFormStatus.loading,
            freezeScreen: state.status == MainAccountFormStatus.loading,
            period: const Duration(milliseconds: 900),
            child: AlertDialog(
              title: Row(
                children: [
                Icon(
                  isEditing ? Icons.edit_note : Icons.add_business_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(isEditing ? 'تعديل حساب رئيسي' : 'إضافة حساب رئيسي جديد'),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Account Name
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الحساب الرئيسي',
                        
                        prefixIcon: Icon(Icons.label_important_outline),
                      ),
                      onChanged: (val) => bloc.add(MainAccountNameChanged(val)),
                    ),
                    const SizedBox(height: 16),

                    // MainAccountGroup
                    DropdownButtonFormField<MainAccountGroup>(
                      initialValue: state.selectedGroup,
                      decoration: const InputDecoration(
                        labelText: 'مجموعة الحساب العامة',
                        
                        prefixIcon: Icon(Icons.folder_shared_outlined),
                      ),
                      // Disable changing group if editing to preserve account number hierarchy
                      items: isEditing
                          ? null
                          : MainAccountGroup.values.map((group) {
                              return DropdownMenuItem(
                                value: group,
                                child: Text(group.displayName()),
                              );
                            }).toList(),
                      onChanged: isEditing
                          ? null
                          : (group) {
                              if (group != null) {
                                bloc.add(MainAccountGroupChanged(group));
                              }
                            },
                    ),
                    const SizedBox(height: 16),

                    // MainAccountType
                    DropdownButtonFormField<MainAccountType>(
                      initialValue: state.selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الحساب الرئيسي',
                        
                        prefixIcon: Icon(Icons.account_tree_outlined),
                      ),
                      items: state.selectedGroup == null
                          ? []
                          : MainAccountType.whereMainAccount(
                              state.selectedGroup!,
                            ).map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName()),
                              );
                            }).toList(),
                      onChanged: (type) {
                        if (type != null) {
                          bloc.add(MainAccountTypeChanged(type));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Currency Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: state.selectedCurrencyId,
                      decoration: const InputDecoration(
                        labelText: 'العملة الافتراضية',
                        
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
                          bloc.add(MainAccountCurrencyChanged(currId));
                        }
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
                onPressed: state.status == MainAccountFormStatus.loading
                    ? null
                    : () => bloc.add(const SubmitMainAccountForm()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: state.status == MainAccountFormStatus.loading
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
