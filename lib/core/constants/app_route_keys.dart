/// ثوابت مفاتيح مسارات التنقل في التطبيق.
///
/// يتم استدعاء هذه الثوابت من [NavigationService] و الـ UI
/// لضمان عدم تكرار النصوص (Hardcoded Strings).
sealed class AppRouteKeys {
  const AppRouteKeys._();

  // ── Auth Branch ──────────────────────────────────────────────────────────
  static const String login = '/login';

  // ── Dashboard Shell Branches ──────────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String periods = '/dashboard/periods';
  static const String currencies = '/dashboard/currencies';
  static const String databaseAdmin = '/dashboard/database-admin';
  static const String accounts = '/dashboard/accounts';
  static const String inventory = '/dashboard/inventory';
  static const String categories = '/dashboard/categories';
  static const String settings = '/dashboard/settings';

  // ── Categories Sub-Routes ────────────────────────────────────────────────
  static const String mainCategories = '/dashboard/categories/main-categories';
}
