import 'package:flowcash/core/constants/app_route_keys.dart';
import 'package:flowcash/features/accounts/presentation/pages/accounts_page.dart';
import 'package:flowcash/features/auth/presentation/pages/login_page.dart';
import 'package:flowcash/features/categories/presentation/pages/categories/categories_page.dart';
import 'package:flowcash/features/categories/presentation/pages/main_categories/main_categories_page.dart';
import 'package:flowcash/features/home/presentation/pages/home_page.dart';
import 'package:flowcash/features/settings/presentation/pages/settings_page.dart';
import 'package:flowcash/features/inventory/presentation/pages/inventory_page.dart';
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
///   ├── Branch: Periods               ← PeriodsPage (قيد التطوير)
///   ├── Branch: Currencies            ← CurrenciesPage (قيد التطوير)
///   ├── Branch: DatabaseAdmin         ← DatabaseAdminPage (قيد التطوير)
///   ├── Branch: Accounts              ← AccountsPage
///   ├── Branch: Inventory             ← InventoryPage (قيد التطوير)
///   ├── Branch: Categories            ← CategoriesPage
///   │     └── /main-categories        ← MainCategoriesPage (مسار فرعي)
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
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.dashboard,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('لوحة المعلومات (قيد الإنشاء)')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.periods,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('الفترات المحاسبية (قيد الإنشاء)')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.currencies,
                builder: (context, state) => const Scaffold(
                  body: Center(
                    child: Text('العملات وأسعار الصرف (قيد الإنشاء)'),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.databaseAdmin,
                builder: (context, state) => const Scaffold(
                  body: Center(
                    child: Text('إدارة قاعدة البيانات (قيد الإنشاء)'),
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.accounts,
                builder: (context, state) => const AccountsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.inventory,
                builder: (context, state) => const InventoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteKeys.categories,
                builder: (context, state) => const CategoriesPage(),
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
  static void toPeriods(BuildContext context) =>
      context.go(AppRouteKeys.periods);
  static void toCurrencies(BuildContext context) =>
      context.go(AppRouteKeys.currencies);
  static void toDatabaseAdmin(BuildContext context) =>
      context.go(AppRouteKeys.databaseAdmin);
  static void toAccounts(BuildContext context) =>
      context.go(AppRouteKeys.accounts);
  static void toInventory(BuildContext context) =>
      context.go(AppRouteKeys.inventory);
  static void toCategories(BuildContext context) =>
      context.go(AppRouteKeys.categories);
  static void toSettings(BuildContext context) =>
      context.go(AppRouteKeys.settings);
  static void toMainCategories(BuildContext context) =>
      context.push(AppRouteKeys.mainCategories);
}
