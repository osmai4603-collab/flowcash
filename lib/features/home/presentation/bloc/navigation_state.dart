import 'package:equatable/equatable.dart';
import 'package:flowcash/core/enums/app_enum.dart';

sealed class HomeSection extends AppEnum {
  const HomeSection();

  static const dashboard = DashboardHomeSection._();
  static const system = SystemHomeSection._();
  static const databaseAdmin = DatabaseAdminHomeSection._();
  static const accounts = AccountsHomeSection._();
  static const inventory = InventoryHomeSection._();
  static const categories = CategoriesHomeSection._();
  static const transactions = TransactionsHomeSection._();
  static const settings = SettingsHomeSection._();

  static const List<HomeSection> values = [
    dashboard,
    system,
    databaseAdmin,
    accounts,
    inventory,
    categories,
    transactions,
    settings,
  ];

  static HomeSection of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown HomeSection: $name'),
    );
  }
}

final class DashboardHomeSection extends HomeSection {
  const DashboardHomeSection._();

  @override
  String get name => 'dashboard';

  @override
  int get index => 0;

  @override
  String displayName() => 'لوحة المعلومات';
}

final class SystemHomeSection extends HomeSection {
  const SystemHomeSection._();

  @override
  String get name => 'system';

  @override
  int get index => 1;

  @override
  String displayName() => 'النظام';
}

final class DatabaseAdminHomeSection extends HomeSection {
  const DatabaseAdminHomeSection._();

  @override
  String get name => 'databaseAdmin';

  @override
  int get index => 2;

  @override
  String displayName() => 'إدارة قاعدة البيانات';
}

final class AccountsHomeSection extends HomeSection {
  const AccountsHomeSection._();

  @override
  String get name => 'accounts';

  @override
  int get index => 3;

  @override
  String displayName() => 'إدارة الحسابات';
}

final class InventoryHomeSection extends HomeSection {
  const InventoryHomeSection._();

  @override
  String get name => 'inventory';

  @override
  int get index => 4;

  @override
  String displayName() => 'إدارة المخزون';
}

final class CategoriesHomeSection extends HomeSection {
  const CategoriesHomeSection._();

  @override
  String get name => 'categories';

  @override
  int get index => 5;

  @override
  String displayName() => 'إدارة الفئات';
}

final class TransactionsHomeSection extends HomeSection {
  const TransactionsHomeSection._();

  @override
  String get name => 'transactions';

  @override
  int get index => 6;

  @override
  String displayName() => 'المعاملات المالية';
}

class SettingsHomeSection extends HomeSection {
  const SettingsHomeSection._();

  @override
  String get name => 'settings';

  @override
  int get index => 7;

  @override
  String displayName() => 'الإعدادات';
}

class HomeNavigationState extends Equatable {
  final HomeSection selectedSection;

  const HomeNavigationState({this.selectedSection = HomeSection.dashboard});

  HomeNavigationState copyWith({HomeSection? selectedSection}) {
    return HomeNavigationState(
      selectedSection: selectedSection ?? this.selectedSection,
    );
  }

  @override
  List<Object?> get props => [selectedSection];
}
