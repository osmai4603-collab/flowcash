import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/system/presentation/bloc/currencies/currencies_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/defaults/defaults_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/exchange_rates/exchange_rates_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/financial_periods/financial_periods_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/value_counters/value_counters_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouse_values/warehouse_values_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouses/warehouses_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/account_associations/account_associations_bloc.dart';
import 'package:flowcash/features/system/presentation/bloc/account_associations/account_associations_event.dart';
import '../pages/currencies/currencies_page.dart';
import '../pages/defaults/defaults_page.dart';
import '../pages/exchange_rates/exchange_rates_page.dart';
import '../pages/financial_periods/financial_periods_page.dart';
import '../pages/warehouse_values/warehouse_values_page.dart';
import '../pages/warehouses/warehouses_page.dart';
import '../pages/value_counters/value_counters_page.dart';
import '../pages/account_associations/account_associations_page.dart';

class SystemPage extends StatefulWidget {
  const SystemPage({super.key});

  @override
  State<SystemPage> createState() => _SystemPageState();
}

class _SystemPageState extends State<SystemPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(title: Text('إعدادات النظام')),
      content: NavigationView(
        pane: NavigationPane(
          selected: _selectedIndex,
          onChanged: (index) => setState(() => _selectedIndex = index),
          displayMode: PaneDisplayMode.top,
          items: [
            PaneItem(
              icon: const Icon(FluentIcons.money),
              title: const Text('العملات'),
              body: BlocProvider(
                create: (_) => sl<CurrenciesBloc>()..add(LoadCurrenciesEvent()),
                child: const CurrenciesPage(),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.chart),
              title: const Text('أسعار الصرف'),
              body: BlocProvider(
                create: (_) =>
                    sl<ExchangeRatesBloc>()..add(LoadExchangeRatesEvent()),
                child: const ExchangeRatesPage(),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.calendar),
              title: const Text('الفترات المالية'),
              body: BlocProvider(
                create: (_) =>
                    sl<FinancialPeriodsBloc>()
                      ..add(LoadFinancialPeriodsEvent()),
                child: const FinancialPeriodsPage(),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.shop),
              title: const Text('المستودعات'),
              body: BlocProvider(
                create: (_) => sl<WarehousesBloc>(),
                child: const WarehousesPage(),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.payment_card),
              title: const Text('قيم المستودعات'),
              body: BlocProvider(
                create: (_) =>
                    sl<WarehouseValuesBloc>()..add(LoadWarehouseValuesEvent()),
                child: const WarehouseValuesPage(),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.calculator),
              title: const Text('عدادات القيم'),
              body: BlocProvider(
                create: (_) =>
                    sl<ValueCountersBloc>()..add(LoadValueCountersEvent()),
                child: const ValueCountersPage(),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('القيم الافتراضية'),
              body: BlocProvider(
                create: (_) => sl<DefaultsBloc>()..add(LoadDefaultsEvent()),
                child: const DefaultsPage(),
              ),
            ),
            PaneItem(
              icon: const Icon(FluentIcons.all_apps),
              title: const Text('ارتباط الحسابات'),
              body: BlocProvider(
                create: (_) => sl<AccountAssociationsBloc>()..add(LoadAccountAssociationsEvent()),
                child: const AccountAssociationsPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
