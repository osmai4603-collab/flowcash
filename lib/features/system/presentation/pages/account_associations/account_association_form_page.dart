import 'package:flowcash/core/theme/spacings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/person_type_enum.dart';
import 'package:flowcash/features/system/presentation/bloc/account_association_form/account_association_form_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/account_association_form/account_association_form_event.dart';
import 'package:flowcash/features/system/presentation/bloc/account_association_form/account_association_form_state.dart';
import 'package:flowcash/widgets/combo_box_form.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/message.dart';

class AccountAssociationFormPage extends StatefulWidget {
  const AccountAssociationFormPage({super.key, this.person});

  final PersonEntity? person;

  @override
  State<AccountAssociationFormPage> createState() => _AccountAssociationFormPageState();
}

class _AccountAssociationFormPageState extends State<AccountAssociationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _receivableAccountController = TextEditingController();
  final _payableAccountController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _receivableAccountFocusNode = FocusNode();
  final _payableAccountFocusNode = FocusNode();

  late final AccountAssociationFormBloc _bloc;
  bool _isDataChanged = false;

  @override
  void initState() {
    super.initState();
    _bloc = AccountAssociationFormBloc(initialPerson: widget.person);

    if (widget.person != null) {
      _nameController.text = widget.person!.personName;
      _phoneController.text = widget.person!.phoneNumber ?? '';
      _addressController.text = widget.person!.address ?? '';
      _emailController.text = widget.person!.email ?? '';
    }
    _loadInitialAccounts();
  }

  void _markChanged() {
    if (!_isDataChanged) {
      setState(() => _isDataChanged = true);
    }
  }

  void _onBackPressed() async {
    if (!_isDataChanged) {
      if (context.mounted) Navigator.pop(context);
      return;
    }
    final sure = await makeSure(
      context: context,
      title: 'تأكيد الخروج',
      content: 'هل تريد الخروج؟ سيتم فقدان البيانات غير المحفوظة',
    );
    if (sure && context.mounted) {
      setState(() => _isDataChanged = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> _loadInitialAccounts() async {
    if (widget.person != null) {
      final ids = [
        widget.person!.receivableAccountId,
        widget.person!.payableAccountId,
      ].whereType<int>().toList();
      if (ids.isEmpty) return;

      try {
        final res = await sl<GetSubAccountsUseCase>().call(ids: ids);
        res.fold((failure) {}, (list) {
          if (mounted) {
            setState(() {
              final recAcc = list
                  .where((a) => a.id == widget.person!.receivableAccountId)
                  .firstOrNull;
              _receivableAccountController.text = recAcc != null
                  ? '${recAcc.accountName} (${recAcc.accountNumber})'
                  : '';

              final payAcc = list
                  .where((a) => a.id == widget.person!.payableAccountId)
                  .firstOrNull;
              _payableAccountController.text = payAcc != null
                  ? '${payAcc.accountName} (${payAcc.accountNumber})'
                  : '';
            });
          }
        });
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _receivableAccountController.dispose();
    _payableAccountController.dispose();

    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _addressFocusNode.dispose();
    _emailFocusNode.dispose();
    _receivableAccountFocusNode.dispose();
    _payableAccountFocusNode.dispose();
    super.dispose();
  }

  void _saveAssociation() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    _bloc.add(const SaveAccountAssociationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountAssociationFormBloc>.value(
      value: _bloc,
      child: BlocListener<AccountAssociationFormBloc, AccountAssociationFormState>(
        listener: (context, state) {
          if (state.status == AccountAssociationFormStatus.saved) {
            Navigator.of(context).pop(state.toEntity());
          }
        },
        child: PopScope(
          canPop: !_isDataChanged,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onBackPressed();
          },
          child: fluent.ContentDialog(
            title: fluent.Text(widget.person == null ? 'إضافة ارتباط جديد' : 'تعديل ارتباط'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  spacing: Spacings.small,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    fluent.InfoLabel(
                      label: 'نوع الحساب',
                      child: BlocBuilder<AccountAssociationFormBloc, AccountAssociationFormState>(
                        buildWhen: (p, c) => p.personType != c.personType,
                        builder: (context, state) {
                          return fluent.ComboBox<PersonType>(
                            value: state.personType,
                            items: PersonType.values.map((type) {
                              return fluent.ComboBoxItem<PersonType>(
                                value: type,
                                child: fluent.Text(type.displayName()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _bloc.add(ChangePersonTypeEvent(value));
                                _markChanged();
                              }
                            },
                          );
                        },
                      ),
                    ),
                    fluent.InfoLabel(
                      label: 'الاسم',
                      child: fluent.TextFormBox(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => _phoneFocusNode.requestFocus(),
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(
                            fluent.FluentIcons.contact,
                            size: 16,
                          ),
                        ),
                        placeholder: 'أدخل الاسم',
                        onChanged: (value) {
                          _bloc.add(ChangePersonNameEvent(value));
                          _markChanged();
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الاسم مطلوب';
                          }
                          return null;
                        },
                      ),
                    ),
                    BlocBuilder<AccountAssociationFormBloc, AccountAssociationFormState>(
                      builder: (context, state) {
                        if (!state.personType.isPerson) return const SizedBox.shrink();
                        return Column(
                          spacing: Spacings.small,
                          children: [
                            fluent.InfoLabel(
                              label: 'الهاتف',
                              child: fluent.TextFormBox(
                                textDirection: TextDirection.ltr,
                                focusNode: _phoneFocusNode,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => _addressFocusNode.requestFocus(),
                                prefix: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: fluent.Icon(
                                    fluent.FluentIcons.phone,
                                    size: 16,
                                  ),
                                ),
                                controller: _phoneController,
                                placeholder: 'أدخل رقم الهاتف',
                                onChanged: (value) {
                                  _bloc.add(ChangePhoneNumberEvent(value));
                                  _markChanged();
                                },
                              ),
                            ),
                            fluent.InfoLabel(
                              label: 'العنوان',
                              child: fluent.TextFormBox(
                                focusNode: _addressFocusNode,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => _emailFocusNode.requestFocus(),
                                prefix: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: fluent.Icon(
                                    fluent.FluentIcons.location,
                                    size: 16,
                                  ),
                                ),
                                controller: _addressController,
                                placeholder: 'أدخل العنوان',
                                onChanged: (value) {
                                  _bloc.add(ChangeAddressEvent(value));
                                  _markChanged();
                                },
                              ),
                            ),
                            fluent.InfoLabel(
                              label: 'البريد الإلكتروني',
                              child: fluent.TextFormBox(
                                textDirection: TextDirection.ltr,
                                focusNode: _emailFocusNode,
                                textInputAction: TextInputAction.next,
                                onEditingComplete: () => _receivableAccountFocusNode.requestFocus(),
                                prefix: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: fluent.Icon(
                                    fluent.FluentIcons.mail,
                                    size: 16,
                                  ),
                                ),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                placeholder: 'أدخل البريد الإلكتروني',
                                onChanged: (value) {
                                  _bloc.add(ChangeEmailEvent(value));
                                  _markChanged();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    fluent.InfoLabel(
                      label: 'حساب الذمم المدينة',
                      child: ComboBoxForm<SubAccountEntity>(
                        controller: _receivableAccountController,
                        focusNode: _receivableAccountFocusNode,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => _payableAccountFocusNode.requestFocus(),
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(
                            fluent.FluentIcons.bank,
                            size: 16,
                          ),
                        ),
                        placeHolder: 'ابحث عن حساب الذمم المدينة...',
                        labelMenu: (a) => '${a.accountName} (${a.accountNumber})',
                        labelString: (a) => '${a.accountName} (${a.accountNumber})',
                        itemsBuilder: (value) async {
                          final res = await sl<SearchSubAccountsUseCase>().call(value);
                          return res.fold((l) => [], (r) => r);
                        },
                        onSelectedItem: (a) {
                          _bloc.add(ChangeReceivableAccountIdEvent(a.id));
                          _payableAccountFocusNode.requestFocus();
                          _markChanged();
                        },
                        onChanged: (value) {
                          if (value.trim().isEmpty) {
                            _bloc.add(const ChangeReceivableAccountIdEvent(null));
                          }
                          _markChanged();
                        },
                      ),
                    ),
                    fluent.InfoLabel(
                      label: 'حساب الذمم الدائنة',
                      child: ComboBoxForm<SubAccountEntity>(
                        controller: _payableAccountController,
                        focusNode: _payableAccountFocusNode,
                        textInputAction: TextInputAction.done,
                        onEditingComplete: _saveAssociation,
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: fluent.Icon(
                            fluent.FluentIcons.bank,
                            size: 16,
                          ),
                        ),
                        placeHolder: 'ابحث عن حساب الذمم الدائنة...',
                        labelMenu: (a) => '${a.accountName} (${a.accountNumber})',
                        labelString: (a) => '${a.accountName} (${a.accountNumber})',
                        itemsBuilder: (value) async {
                          final res = await sl<SearchSubAccountsUseCase>().call(value);
                          return res.fold((l) => [], (r) => r);
                        },
                        onSelectedItem: (a) {
                          _bloc.add(ChangePayableAccountIdEvent(a.id));
                          _saveAssociation();
                          _markChanged();
                        },
                        onChanged: (value) {
                          if (value.trim().isEmpty) {
                            _bloc.add(const ChangePayableAccountIdEvent(null));
                          }
                          _markChanged();
                        },
                      ),
                    ),
                    BlocBuilder<AccountAssociationFormBloc, AccountAssociationFormState>(
                      builder: (context, state) {
                        if (state.status == AccountAssociationFormStatus.failure &&
                            state.messageError != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: fluent.InfoBar(
                              title: const fluent.Text('خطأ'),
                              content: fluent.Text(state.messageError!),
                              severity: fluent.InfoBarSeverity.error,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              fluent.Button(
                onPressed: _onBackPressed,
                child: const fluent.Text('إلغاء'),
              ),
              BlocBuilder<AccountAssociationFormBloc, AccountAssociationFormState>(
                builder: (context, state) {
                  return fluent.FilledButton(
                    onPressed: state.status == AccountAssociationFormStatus.saving ? null : _saveAssociation,
                    child: const fluent.Text('حفظ'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
