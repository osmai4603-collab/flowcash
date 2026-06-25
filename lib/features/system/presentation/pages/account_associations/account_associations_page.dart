import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/features/system/presentation/pages/account_associations/account_association_form_page.dart';
import 'package:flowcash/features/system/presentation/bloc/account_associations/account_associations_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/account_associations/account_associations_event.dart';
import 'package:flowcash/features/system/presentation/bloc/account_associations/account_associations_state.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/widgets/message.dart';

class AccountAssociationsPage extends StatefulWidget {
  const AccountAssociationsPage({super.key});

  @override
  State<AccountAssociationsPage> createState() => _AccountAssociationsPageState();
}

class _AccountAssociationsPageState extends State<AccountAssociationsPage> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<AccountAssociationsBloc>().add(
      SearchAccountAssociationsEvent(searchController.text),
    );
  }

  void _onRefreshPressed() {
    context.read<AccountAssociationsBloc>().add(LoadAccountAssociationsEvent());
  }

  void _onAddAssociationPressed() async {
    final bloc = context.read<AccountAssociationsBloc>();
    final newAssociation = await fluent.showDialog<PersonEntity>(
      context: context,
      builder: (_) => const AccountAssociationFormPage(),
    );
    if (newAssociation != null) {
      bloc.add(AddAccountAssociationEvent(newAssociation));
    }
  }

  void _onEditAssociation(PersonEntity person) async {
    final bloc = context.read<AccountAssociationsBloc>();
    final updatedAssociation = await fluent.showDialog<PersonEntity>(
      context: context,
      builder: (_) => AccountAssociationFormPage(person: person),
    );
    if (updatedAssociation != null) {
      bloc.add(UpdateAccountAssociationEvent(updatedAssociation));
    }
  }

  void _onDeleteAssociation(PersonEntity person) async {
    final sure = await makeSure(
      context: context,
      title: 'حذف ارتباط',
      content: 'هل أنت متأكد من حذف هذا الارتباط؟',
    );
    if (sure && mounted) {
      context.read<AccountAssociationsBloc>().add(DeleteAccountAssociationEvent(person.id));
    }
  }

  String _getAccountName(List<SubAccountEntity> subAccounts, int? id) {
    if (id == null) return '-';
    final acc = subAccounts.where((a) => a.id == id).firstOrNull;
    return acc != null ? '${acc.accountName} (${acc.accountNumber})' : '-';
  }

  Widget _buildTable(
    List<PersonEntity> persons,
    List<SubAccountEntity> subAccounts,
  ) {
    final colors = AppStyle.of(context);
    final borderColor = colors.outline;

    if (persons.isEmpty) {
      return Center(
        child: fluent.Text(
          searchController.text.trim().isEmpty
              ? 'لا يوجد ارتباطات مسجلة'
              : 'لا يوجد ارتباطات مطابقة للبحث',
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: fluent.Table(
        border: TableBorder.all(width: 0.5, color: borderColor),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FixedColumnWidth(40),
          1: FixedColumnWidth(180),
          2: FixedColumnWidth(130),
          3: FixedColumnWidth(130),
          4: FixedColumnWidth(180),
          5: FixedColumnWidth(180),
          6: FixedColumnWidth(100),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(color: colors.surfaceContainer),
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('No', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('الاسم', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('نوع الحساب', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('الهاتف', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('حساب المدين', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('حساب الدائن', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('العمليات', textAlign: TextAlign.center),
              ),
            ],
          ),
          ...persons.asMap().entries.map((entry) {
            final index = entry.key;
            final person = entry.value;
            final rowColor = index.isOdd ? colors.surfaceContainer : null;
            return TableRow(
              decoration: BoxDecoration(color: rowColor),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(
                    person.personName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(
                    person.personType.displayName(),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(
                    person.phoneNumber ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(
                    _getAccountName(subAccounts, person.receivableAccountId),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(
                    _getAccountName(subAccounts, person.payableAccountId),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      fluent.IconButton(
                        icon: const fluent.Icon(fluent.FluentIcons.edit),
                        onPressed: () => _onEditAssociation(person),
                      ),
                      const SizedBox(width: 8),
                      fluent.IconButton(
                        icon: const fluent.Icon(fluent.FluentIcons.delete),
                        onPressed: () => _onDeleteAssociation(person),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    return BlocListener<AccountAssociationsBloc, AccountAssociationsState>(
      listener: (context, state) {
        if (state is AccountAssociationsOperationFailure) {
          error(context: context, toast: state.message);
        }
      },
      child: fluent.ScaffoldPage(
        header: fluent.PageHeader(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: Spacings.large,
            children: [
              const Row(
                children: [
                  fluent.Icon(fluent.FluentIcons.all_apps, size: 30),
                  SizedBox(width: 10),
                  fluent.Text('ارتباط الحسابات'),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: fluent.TextBox(
                        controller: searchController,
                        prefix: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: fluent.Icon(fluent.FluentIcons.search),
                        ),
                        placeholder: 'ابحث عن ارتباط هنا',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        BlocBuilder<AccountAssociationsBloc, AccountAssociationsState>(
                          builder: (context, state) {
                            int count = 0;
                            if (state is AccountAssociationsLoadSuccess) {
                              count = state.persons.length;
                            }
                            return fluent.Text(
                              count.toString(),
                              style: colors.bodyStrong,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        fluent.Text('نتيجة', style: colors.bodyStrong),
                      ],
                    ),
                    const SizedBox(width: 12),
                    fluent.Tooltip(
                      message: 'إعادة تحميل',
                      child: fluent.IconButton(
                        icon: const fluent.Icon(fluent.FluentIcons.refresh),
                        onPressed: _onRefreshPressed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    fluent.FilledButton(
                      onPressed: _onAddAssociationPressed,
                      child: const Row(
                        children: [
                          fluent.Icon(fluent.FluentIcons.add),
                          SizedBox(width: 8),
                          fluent.Text('إضافة ارتباط جديد'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: Paddings.mediumAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<AccountAssociationsBloc, AccountAssociationsState>(
                  builder: (context, state) {
                    if (state is AccountAssociationsLoadInProgress ||
                        state is AccountAssociationsInitial) {
                      return const Center(child: fluent.ProgressRing());
                    }
                    if (state is AccountAssociationsLoadSuccess) {
                      return _buildTable(
                        state.persons,
                        state.subAccounts,
                      );
                    }
                    if (state is AccountAssociationsOperationFailure) {
                      return Center(child: fluent.Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
