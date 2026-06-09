import 'package:flowcash/core/constants/app_route_keys.dart';
import 'package:flowcash/features/accounts/presentation/pages/accounts_dashboard.dart';
import 'package:flowcash/features/auth/presentation/pages/login_page.dart';
import 'package:flowcash/features/categories/presentation/pages/categories/categories_dashboard_page.dart';
import 'package:flowcash/features/categories/presentation/pages/main_categories/main_categories_page.dart';
import 'package:flowcash/features/home/presentation/pages/dashboard_view.dart';
import 'package:flowcash/features/home/presentation/widgets/home_navigation_view.dart';
import 'package:flowcash/features/inventory/presentation/pages/inventory_dashboard.dart';
import 'package:flowcash/features/settings/presentation/pages/settings_page.dart';
import 'package:flowcash/features/system/presentation/pages/system_page.dart';
import 'package:flowcash/features/transactions/presentation/pages/transactions_dashboard.dart';
import 'package:flowcash/features/sales/presentation/pages/sales_dashboard.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/user_session.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// ثوابت ومنافذ نظام التنقل.
///
/// **هيكلية المسارات:**
/// ```
/// /login                              ← Root Navigator (صفحة تسجيل الدخول)
/// StatefulShellRoute                  ← MainScreen (Stateful Shell)
///   ├── Branch: Dashboard             ← DashboardPage
///   ├── Branch: System                ← SystemPage
///   ├── Branch: Accounts              ← AccountsPage
///   ├── Branch: Inventory             ← InventoryPage (قيد الإنشاء)
///   ├── Branch: Categories            ← CategoriesPage
///   │     └── /main-categories        ← MainCategoriesPage (مسار فرعي)
///   ├── Branch: Transactions          ← TransactionsPage
///   └── Branch: Settings              ← SettingsPage
/// ```
sealed class NavigationService {
  const NavigationService._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  // ╔════════════════════════════════════════════════════════════════════╗
  // ║                         Router Config                              ║
  // ╚════════════════════════════════════════════════════════════════════╝

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRouteKeys.dashboard,
    refreshListenable: sl<UserSession>(),
    redirect: (context, state) {
      final session = sl<UserSession>();
      final isAuthenticated = session.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppRouteKeys.login;

      if (!isAuthenticated && !isLoggingIn) {
        return AppRouteKeys.login;
      }
      if (isAuthenticated && isLoggingIn) {
        return AppRouteKeys.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRouteKeys.login,
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeNavigationView(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.dashboard,
                builder: (context, state) => DashboardView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.system,
                builder: (context, state) => const SystemPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.accounts,
                builder: (context, state) => AccountsDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.inventory,
                builder: (context, state) => const InventoryDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.categories,
                builder: (context, state) => const CategoriesDashboardPage(),
                routes: [
                  GoRoute(
                    path: 'main-categories',
                    builder: (context, state) => const MainCategoriesPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.transactions,
                builder: (context, state) => const TransactionsDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.sales,
                builder: (context, state) => const SalesDashboard(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.settings,
                builder: (context, state) => SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // ╔════════════════════════════════════════════════════════════════════╗
  // ║                         Navigation Helpers                         ║
  // ╚════════════════════════════════════════════════════════════════════╝

  static void toDashboard(BuildContext context) =>
      context.go(AppRouteKeys.dashboard);
  static void toSystem(BuildContext context) => context.go(AppRouteKeys.system);
  static void toAccounts(BuildContext context) =>
      context.go(AppRouteKeys.accounts);
  static void toInventory(BuildContext context) =>
      context.go(AppRouteKeys.inventory);
  static void toCategories(BuildContext context) =>
      context.go(AppRouteKeys.categories);
  static void toTransactions(BuildContext context) =>
      context.go(AppRouteKeys.transactions);
  static void toSales(BuildContext context) =>
      context.go(AppRouteKeys.sales);
  static void toSettings(BuildContext context) =>
      context.go(AppRouteKeys.settings);
  static void toMainCategories(BuildContext context) =>
      context.push(AppRouteKeys.mainCategories);
}
