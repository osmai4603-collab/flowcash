import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/features/sales/presentation/pages/customers/customer_form_page.dart';
import 'package:flowcash/features/sales/presentation/bloc/customers_page/customers_page_bloc.dart';
import 'package:flowcash/features/sales/presentation/bloc/customers_page/customers_page_event.dart';
import 'package:flowcash/features/sales/presentation/bloc/customers_page/customers_page_state.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/widgets/message.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustomersPageBloc>(
      create: (_) => CustomersPageBloc()..add(LoadCustomersPageEvent()),
      child: const _CustomersPageView(),
    );
  }
}

class _CustomersPageView extends StatefulWidget {
  const _CustomersPageView();

  @override
  State<_CustomersPageView> createState() => _CustomersPageViewState();
}

class _CustomersPageViewState extends State<_CustomersPageView> {
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
    context.read<CustomersPageBloc>().add(
      SearchCustomersPageEvent(searchController.text),
    );
  }

  void _onRefreshPressed() {
    context.read<CustomersPageBloc>().add(LoadCustomersPageEvent());
  }

  void _onAddCustomerPressed() async {
    final bloc = context.read<CustomersPageBloc>();
    final newCustomer = await fluent.showDialog<PersonEntity>(
      context: context,
      builder: (_) => const CustomerFormPage(),
    );
    if (newCustomer != null) {
      bloc.add(AddCustomerEvent(newCustomer));
    }
  }

  String _getAccountName(List<SubAccountEntity> subAccounts, int? id) {
    if (id == null) return '-';
    final acc = subAccounts.where((a) => a.id == id).firstOrNull;
    return acc != null ? '${acc.accountName} (${acc.accountNumber})' : '-';
  }

  Widget _buildCustomerTable(
    List<PersonEntity> persons,
    List<SubAccountEntity> subAccounts,
  ) {
    final colors = AppStyle.of(context);
    final borderColor = colors.outline;

    if (persons.isEmpty) {
      return Center(
        child: fluent.Text(
          searchController.text.trim().isEmpty
              ? 'لا يوجد عملاء مسجلين'
              : 'لا يوجد عملاء مطابقين للبحث',
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
          3: FixedColumnWidth(220),
          4: FixedColumnWidth(180),
          5: FixedColumnWidth(180),
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
                child: fluent.Text('اسم العميل', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('الهاتف', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('العنوان', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('حساب المدين', textAlign: TextAlign.center),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: fluent.Text('حساب الدائن', textAlign: TextAlign.center),
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
                    person.phoneNumber ?? '-',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(
                    person.address ?? '-',
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
    return BlocListener<CustomersPageBloc, CustomersPageState>(
      listener: (context, state) {
        if (state is CustomersPageOperationFailure) {
          error(context: context, toast: state.message);
        }
      },
      child: fluent.ScaffoldPage(
        header: fluent.PageHeader(
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: Spacings.large,
            children: [
              Row(
                children: [
                  fluent.Icon(fluent.FluentIcons.people, size: 30),
                  const SizedBox(width: 10),
                  const fluent.Text('العملاء'),
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
                        placeholder: 'ابحث عن عميل هنا',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        BlocBuilder<CustomersPageBloc, CustomersPageState>(
                          builder: (context, state) {
                            int count = 0;
                            if (state is CustomersPageLoadSuccess) {
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
                      message: 'إعادة تحميل العملاء',
                      child: fluent.IconButton(
                        icon: const fluent.Icon(fluent.FluentIcons.refresh),
                        onPressed: _onRefreshPressed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    fluent.FilledButton(
                      onPressed: _onAddCustomerPressed,
                      child: const Row(
                        children: [
                          fluent.Icon(fluent.FluentIcons.add),
                          SizedBox(width: 8),
                          fluent.Text('إضافة عميل جديد'),
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
                child: BlocBuilder<CustomersPageBloc, CustomersPageState>(
                  builder: (context, state) {
                    if (state is CustomersPageLoadInProgress ||
                        state is CustomersPageInitial) {
                      return const Center(child: fluent.ProgressRing());
                    }
                    if (state is CustomersPageLoadSuccess) {
                      return _buildCustomerTable(
                        state.persons,
                        state.subAccounts,
                      );
                    }
                    if (state is CustomersPageOperationFailure) {
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
