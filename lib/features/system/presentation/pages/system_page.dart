import 'package:flutter/material.dart';

import '../pages/company/company_page.dart';
import '../pages/currencies/currencies_page.dart';
import '../pages/exchange_rates/exchange_rates_page.dart';
import '../pages/financial_periods/financial_periods_page.dart';
import '../pages/warehouse_values/warehouse_values_page.dart';
import '../pages/warehouses/warehouses_page.dart';
import '../pages/defaults/defaults_page.dart';
import '../pages/value_counters/value_counters_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/system/presentation/bloc/currencies/currencies_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/exchange_rates/exchange_rates_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/financial_periods/financial_periods_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouses/warehouses_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/warehouse_values/warehouse_values_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/value_counters/value_counters_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/defaults/defaults_cubit.dart';
import 'package:flowcash/features/system/presentation/bloc/company/company_cubit.dart';

class SystemPage extends StatelessWidget {
  const SystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[
      const Tab(text: 'العملات'),
      const Tab(text: 'أسعار الصرف'),
      const Tab(text: 'الفترات المالية'),
      const Tab(text: 'المستودعات'),
      const Tab(text: 'قيم المستودعات'),
      const Tab(text: 'عدادات القيم'),
      const Tab(text: 'القيم الافتراضية'),
      const Tab(text: 'بيانات الشركة'),
    ];

    final tabViews = <Widget>[
      BlocProvider(
        create: (_) => sl<CurrenciesBloc>()..add(LoadCurrenciesEvent()),
        child: const CurrenciesPage(),
      ),
      BlocProvider(
        create: (_) => sl<ExchangeRatesBloc>()..add(LoadExchangeRatesEvent()),
        child: const ExchangeRatesPage(),
      ),
      BlocProvider(
        create: (_) => sl<FinancialPeriodsBloc>()..add(LoadFinancialPeriodsEvent()),
        child: const FinancialPeriodsPage(),
      ),
      BlocProvider(
        create: (_) => sl<WarehousesBloc>(),
        child: const WarehousesPage(),
      ),
      BlocProvider(
        create: (_) => sl<WarehouseValuesBloc>()..add(LoadWarehouseValuesEvent()),
        child: const WarehouseValuesPage(),
      ),
      BlocProvider(
        create: (_) => sl<ValueCountersBloc>()..add(LoadValueCountersEvent()),
        child: const ValueCountersPage(),
      ),
      BlocProvider(
        create: (_) => sl<DefaultsBloc>()..add(LoadDefaultsEvent()),
        child: const DefaultsPage(),
      ),
      BlocProvider(
        create: (_) => sl<CompanyBloc>()..add(LoadCompanyEvent()),
        child: const CompanyPage(),
      ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إعدادات النظام'),
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs,
          ),
        ),
        body: TabBarView(children: tabViews),
      ),
    );
  }
}
