import 'package:flowcash/core/theme/spacings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/features/sales/presentation/bloc/customer_form/customer_form_bloc.dart';
import 'package:flowcash/features/sales/presentation/bloc/customer_form/customer_form_event.dart';
import 'package:flowcash/features/sales/presentation/bloc/customer_form/customer_form_state.dart';

class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key, this.person});

  final PersonEntity? person;

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _receivableAccountController = TextEditingController();
  final _payableAccountController = TextEditingController();

  late final CustomerFormBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CustomerFormBloc(initialPerson: widget.person);

    if (widget.person != null) {
      _nameController.text = widget.person!.personName;
      _phoneController.text = widget.person!.phoneNumber ?? '';
      _addressController.text = widget.person!.address ?? '';
      _emailController.text = widget.person!.email ?? '';
      _receivableAccountController.text = widget.person!.receivableAccountId?.toString() ?? '';
      _payableAccountController.text = widget.person!.payableAccountId?.toString() ?? '';
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
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    _bloc.add(const SaveCustomerEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustomerFormBloc>.value(
      value: _bloc,
      child: BlocListener<CustomerFormBloc, CustomerFormState>(
        listener: (context, state) {
          if (state.status == CustomerFormStatus.saved) {
            Navigator.of(context).pop(state.toEntity());
          }

          if (state.status == CustomerFormStatus.failure && state.messageError != null) {
            fluent.showDialog<void>(
              context: context,
              builder: (_) => fluent.ContentDialog(
                title: const fluent.Text('خطأ'),
                content: fluent.Text(state.messageError!),
                actions: [
                  fluent.Button(
                    child: const fluent.Text('حسناً'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          }
        },
        child: fluent.ContentDialog(
          title: const fluent.Text('إضافة عميل جديد'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                spacing: Spacings.small,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  fluent.InfoLabel(
                    label: 'اسم العميل',
                    child: fluent.TextFormBox(
                      controller: _nameController,
                      prefix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const fluent.Icon(fluent.FluentIcons.people, size: 16),
                      ),
                      placeholder: 'أدخل اسم العميل',
                      onChanged: (value) => _bloc.add(ChangePersonNameEvent(value)),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الاسم مطلوب';
                        }
                        return null;
                      },
                    ),
                  ),
                  fluent.InfoLabel(
                    label: 'الهاتف',
                    child: fluent.TextFormBox(
                      textDirection: TextDirection.ltr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const fluent.Icon(fluent.FluentIcons.phone, size: 16),
                      ),
                      controller: _phoneController,
                      placeholder: 'أدخل رقم الهاتف',
                      onChanged: (value) => _bloc.add(ChangePhoneNumberEvent(value)),
                    ),
                  ),
                  fluent.InfoLabel(
                    label: 'العنوان',
                    child: fluent.TextFormBox(
                      prefix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const fluent.Icon(fluent.FluentIcons.location, size: 16),
                      ),
                      controller: _addressController,
                      placeholder: 'أدخل العنوان',
                      onChanged: (value) => _bloc.add(ChangeAddressEvent(value)),
                    ),
                  ),
                  fluent.InfoLabel(
                    label: 'البريد الإلكتروني',
                    child: fluent.TextFormBox(
                      textDirection: TextDirection.ltr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const fluent.Icon(fluent.FluentIcons.mail, size: 16),
                      ),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      placeholder: 'أدخل البريد الإلكتروني',
                      onChanged: (value) => _bloc.add(ChangeEmailEvent(value)),
                    ),
                  ),
                  fluent.InfoLabel(
                    label: 'حساب الذمم المدينة',
                    child: fluent.TextFormBox(
                      textDirection: TextDirection.ltr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const fluent.Icon(fluent.FluentIcons.bank, size: 16),
                      ),
                      controller: _receivableAccountController,
                      placeholder: 'أدخل رقم حساب الذمم المدينة',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsed = int.tryParse(value.trim());
                        _bloc.add(ChangeReceivableAccountIdEvent(parsed));
                      },
                    ),
                  ),
                  fluent.InfoLabel(
                    label: 'حساب الذمم الدائنة',
                    child: fluent.TextFormBox(
                      textDirection: TextDirection.ltr,
                      prefix: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const fluent.Icon(fluent.FluentIcons.bank, size: 16),
                      ),
                      controller: _payableAccountController,
                      placeholder: 'أدخل رقم حساب الذمم الدائنة',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsed = int.tryParse(value.trim());
                        _bloc.add(ChangePayableAccountIdEvent(parsed));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            fluent.Button(
              child: const fluent.Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            BlocBuilder<CustomerFormBloc, CustomerFormState>(
              builder: (context, state) {
                return fluent.FilledButton(
                  onPressed: state.status == CustomerFormStatus.saving ? null : _saveCustomer,
                  child: const fluent.Text('حفظ'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
