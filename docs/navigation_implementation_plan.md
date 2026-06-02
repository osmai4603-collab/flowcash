# إعادة هيكلة نظام التنقل باستخدام go_router

## الوصف

التطبيق حالياً يعتمد على نظام تنقل يدوي باستخدام `MaterialApp(home:)` مع `HomeNavigationBloc` للتبديل بين الأقسام الرئيسية، و `AccountsNavigationBloc` مع `TabController` لإدارة تبويبات الحسابات. هذا النظام لا يدعم:
- **Deep Linking** (روابط مباشرة)
- **URL-based Routing** (مسارات URL واضحة)
- **حفظ حالة التنقل** عند التبديل بين الفروع (Stateful Navigation)

الهدف هو الانتقال إلى `go_router` مع `StatefulShellRoute.indexedStack` لبناء نظام تنقل متكامل يتبع معايير [manage_navigation.md](file:///home/osmsoftwareengineering/flutter_projects/flowcash/.agent/workflows/manage_navigation.md).

---

## تحليل النظام الحالي

### هيكلية التنقل الحالية:
```
MaterialApp (home: conditional)
├── LoginPage                           ← عند عدم المصادقة
└── HomePage                            ← عند المصادقة (HomeNavigationBloc)
    ├── Dashboard                       ← Container فارغ
    ├── Periods                         ← Container فارغ
    ├── Currencies                      ← Container فارغ
    ├── DatabaseAdmin                   ← Container فارغ
    ├── Accounts                        ← AccountsNavigationBloc + TabController
    │   ├── ChartOfAccountsPage
    │   ├── JournalEntriesPage
    │   ├── AccountStatementPage
    │   ├── TrialBalancePage
    │   ├── GroupBalancesReportPage
    │   └── AccountTypesManagementPage
    ├── Inventory                       ← Container فارغ
    ├── Categories                      ← CategoriesPage (مع Navigator.push داخلي)
    └── Settings                        ← SettingsPage
```

### الملفات المتأثرة:

| الملف | الدور الحالي |
|-------|-------------|
| [application.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/app/presentation/pages/application.dart) | `MaterialApp(home:)` مع تبديل شرطي |
| [home_page.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/home/presentation/pages/home_page.dart) | Drawer/Sidebar + `_HomeBody` switch |
| [navigation_bloc.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/home/presentation/bloc/navigation_bloc.dart) | BLoC تنقل الأقسام الرئيسية |
| [navigation_state.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/home/presentation/bloc/navigation_state.dart) | State + HomeSection enum |
| [navigation_event.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/home/presentation/bloc/navigation_event.dart) | أحداث التنقل |
| [accounts_page.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/presentation/pages/accounts_page.dart) | TabController + 6 تبويبات |
| [accounts_navigation_bloc.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/presentation/blocs/accounts_navigation/accounts_navigation_bloc.dart) | BLoC تنقل التبويبات |
| [accounts_navigation_state.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/presentation/blocs/accounts_navigation/accounts_navigation_state.dart) | State التبويبات |
| [accounts_navigation_event.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/presentation/blocs/accounts_navigation/accounts_navigation_event.dart) | أحداث التبويبات |
| [accounts_injection.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/accounts_injection.dart) | تسجيل AccountsNavigationBloc |

---

## User Review Required

> [!IMPORTANT]
> **تغيير جذري في هيكلية التنقل**: سيتم استبدال `MaterialApp(home:)` بـ `MaterialApp.router` مما يعني أن كل الصفحات ستُعرَّف كمسارات في `NavigationService`.

> [!WARNING]
> **حذف Blocs التنقل**: سيتم حذف `HomeNavigationBloc` و `AccountsNavigationBloc` بالكامل لأن `go_router` سيتولى إدارة حالة التنقل. هل توافق على ذلك؟

> [!IMPORTANT]
> **الصفحات الفارغة (Placeholder)**: الأقسام التالية حالياً `Container()` فارغ: Dashboard، Periods، Currencies، DatabaseAdmin، Inventory. سأعرّفها كمسارات مع صفحات Placeholder بسيطة. هل تريد تضمينها كلها أم استبعاد بعضها؟

---

## Open Questions

> [!IMPORTANT]
> **1. تبويبات الحسابات**: حالياً الحسابات تستخدم `TabBar` + `TabBarView` مع 6 تبويبات. هل تريد:
> - **خيار أ**: تحويل كل تبويب إلى مسار فرعي مستقل (مثل `/dashboard/accounts/chart`, `/dashboard/accounts/journal`) مع إبقاء TabBar كـ UI فقط؟
> - **خيار ب**: إبقاء TabBar كما هو داخلياً دون تحويل التبويبات إلى مسارات فرعية (أبسط)؟

> [!IMPORTANT]
> **2. HomeSection enum**: كلاس `HomeSection` في [navigation_state.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/home/presentation/bloc/navigation_state.dart) يُستخدم أيضاً في الـ Drawer. هل تريد الاحتفاظ به كـ enum مستقل للـ Sidebar أم استبداله بقائمة في `HomePage` مباشرة؟

> [!IMPORTANT]
> **3. الـ Categories Feature**: حالياً `CategoriesPage` تستخدم `Navigator.push` داخلياً للتنقل بين الصفحات الفرعية. هل تريد تحويلها أيضاً إلى مسارات go_router أم تأجيل ذلك لاحقاً؟

---

## هيكلية المسارات المقترحة

```
/login                                    ← Root Navigator (بدون Shell)
StatefulShellRoute.indexedStack           ← MainScreen (Stateful Navigator)
  ├── Branch 0: Dashboard                ← /dashboard
  ├── Branch 1: Periods                  ← /dashboard/periods
  ├── Branch 2: Currencies              ← /dashboard/currencies
  ├── Branch 3: DatabaseAdmin            ← /dashboard/database-admin
  ├── Branch 4: Accounts                 ← /dashboard/accounts
  │   ├── /dashboard/accounts/chart      ← دليل الحسابات
  │   ├── /dashboard/accounts/journal    ← قيود اليومية
  │   ├── /dashboard/accounts/statement  ← كشف حساب
  │   ├── /dashboard/accounts/trial-balance ← ميزان المراجعة
  │   ├── /dashboard/accounts/group-balances ← تقرير الأرصدة
  │   └── /dashboard/accounts/types      ← أنواع الحسابات
  ├── Branch 5: Inventory                ← /dashboard/inventory
  ├── Branch 6: Categories               ← /dashboard/categories
  └── Branch 7: Settings                 ← /dashboard/settings
```

---

## Proposed Changes

### المرحلة 1: البنية التحتية (Infrastructure)

---

#### [MODIFY] [pubspec.yaml](file:///home/osmsoftwareengineering/flutter_projects/flowcash/pubspec.yaml)
- إضافة `go_router` كاعتمادية جديدة

---

#### [NEW] app_route_keys.dart
**المسار:** `lib/core/constants/app_route_keys.dart`

```dart
/// ثوابت مفاتيح مسارات التنقل في التطبيق.
///
/// يتم استدعاء هذه الثوابت من [NavigationService] و الـ UI
/// لضمان عدم تكرار النصوص (Hardcoded Strings).
sealed class AppRouteKeys {
  const AppRouteKeys._();

  // ── Auth ─────────────────────────────────────
  static const String login = '/login';

  // ── Dashboard Branch ─────────────────────────
  static const String dashboard = '/dashboard';

  // ── Periods Branch ───────────────────────────
  static const String periods = '/dashboard/periods';

  // ── Currencies Branch ────────────────────────
  static const String currencies = '/dashboard/currencies';

  // ── Database Admin Branch ────────────────────
  static const String databaseAdmin = '/dashboard/database-admin';

  // ── Accounts Branch ──────────────────────────
  static const String accounts = '/dashboard/accounts';
  static const String accountsChart = '/dashboard/accounts/chart';
  static const String accountsJournal = '/dashboard/accounts/journal';
  static const String accountsStatement = '/dashboard/accounts/statement';
  static const String accountsTrialBalance = '/dashboard/accounts/trial-balance';
  static const String accountsGroupBalances = '/dashboard/accounts/group-balances';
  static const String accountsTypes = '/dashboard/accounts/types';

  // ── Inventory Branch ─────────────────────────
  static const String inventory = '/dashboard/inventory';

  // ── Categories Branch ────────────────────────
  static const String categories = '/dashboard/categories';

  // ── Settings Branch ──────────────────────────
  static const String settings = '/dashboard/settings';
}
```

---

#### [NEW] navigation_service.dart
**المسار:** `lib/core/services/navigation_service.dart`

سيتضمن:
- `_rootNavigatorKey` و `_shellNavigatorKey`
- `_authGuard` يعتمد على `UserSession.isAuthenticated`
- `StatefulShellRoute.indexedStack` مع 8 فروع
- تعريف كل فرع كـ `static final StatefulShellBranch`
- حقن الـ Blocs في `builder` كل مسار
- مخطط هيكلية المسارات في بداية الكلاس
- الفواصل الجمالية حسب معايير التوثيق

---

### المرحلة 2: تعديل Application

---

#### [MODIFY] [application.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/app/presentation/pages/application.dart)
- تحويل `MaterialApp` إلى `MaterialApp.router`
- استخدام `routerConfig: NavigationService.router`
- حذف `home:` property
- الاحتفاظ بجميع الـ `BlocProvider` و `MultiProvider` الحالية
- الاحتفاظ بالـ Localization و Theme

---

### المرحلة 3: إعادة هيكلة HomePage (MainScreen)

---

#### [MODIFY] [home_page.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/home/presentation/pages/home_page.dart)
- تحويل `HomePage` إلى `MainScreen` يستقبل `StatefulNavigationShell navigationShell`
- الـ Drawer/Sidebar يستخدم `navigationShell.goBranch(index)` بدلاً من BLoC
- حذف `_HomeBody` (switch) بالكامل - go_router يتولى عرض المحتوى عبر `navigationShell`
- الاحتفاظ بتصميم الـ Drawer الحالي مع تحديث `onTap`
- تحديث `BottomNavigationBar` لاستخدام `navigationShell.currentIndex`

---

#### [DELETE] [navigation_bloc.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/home/presentation/bloc/navigation_bloc.dart)
#### [DELETE] [navigation_event.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/home/presentation/bloc/navigation_event.dart)

> [!NOTE]
> سيتم الاحتفاظ بـ `HomeSection` enum من [navigation_state.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/home/presentation/bloc/navigation_state.dart) أو نقله لمكان مناسب (حسب الإجابة على السؤال المفتوح #2).

---

### المرحلة 4: إعادة هيكلة Accounts

---

#### [MODIFY] [accounts_page.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/presentation/pages/accounts_page.dart)
- إذا تم اختيار **خيار أ**: تحويل `AccountsPage` لتستقبل `child` من go_router وتعرض TabBar كـ UI فقط مع `context.go()` عند التبديل
- إذا تم اختيار **خيار ب**: الإبقاء عليها كما هي مع حذف `AccountsNavigationBloc` فقط

---

#### [DELETE] [accounts_navigation_bloc.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/presentation/blocs/accounts_navigation/accounts_navigation_bloc.dart)
#### [DELETE] [accounts_navigation_state.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/presentation/blocs/accounts_navigation/accounts_navigation_state.dart)
#### [DELETE] [accounts_navigation_event.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/presentation/blocs/accounts_navigation/accounts_navigation_event.dart)

---

#### [MODIFY] [accounts_injection.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/accounts/accounts_injection.dart)
- حذف تسجيل `AccountsNavigationBloc` (السطر 28)

---

### المرحلة 5: التنظيف والتحقق

---

#### [MODIFY] [injection_container.dart](file:///home/osmsoftwareengineering/flutter_projects/flowcash/lib/features/injection_container.dart)
- لا تغييرات مباشرة متوقعة (الـ Blocs المحذوفة مسجلة في ملفات الـ injection الخاصة بالميزات)

---

## ملخص الملفات

| العملية | الملف |
|---------|-------|
| ✅ جديد | `lib/core/constants/app_route_keys.dart` |
| ✅ جديد | `lib/core/services/navigation_service.dart` |
| ✏️ تعديل | `pubspec.yaml` |
| ✏️ تعديل | `lib/features/app/presentation/pages/application.dart` |
| ✏️ تعديل | `lib/features/home/presentation/pages/home_page.dart` |
| ✏️ تعديل | `lib/features/accounts/presentation/pages/accounts_page.dart` |
| ✏️ تعديل | `lib/features/accounts/accounts_injection.dart` |
| ❌ حذف | `lib/features/home/presentation/bloc/navigation_bloc.dart` |
| ❌ حذف | `lib/features/home/presentation/bloc/navigation_event.dart` |
| ❌ حذف | `lib/features/accounts/presentation/blocs/accounts_navigation/accounts_navigation_bloc.dart` |
| ❌ حذف | `lib/features/accounts/presentation/blocs/accounts_navigation/accounts_navigation_state.dart` |
| ❌ حذف | `lib/features/accounts/presentation/blocs/accounts_navigation/accounts_navigation_event.dart` |

---

## ما لن يتغير

- **`showDialog` calls**: جميع الـ dialogs (مثل `JournalEntryFormDialog`, `SubAccountFormDialog`, `MainAccountFormDialog`) ستبقى كما هي - هي overlays وليست مسارات
- **`Navigator.pop` في الـ dialogs**: ستبقى كما هي لإغلاق الـ dialogs
- **`Navigator.push` في Categories**: ستبقى مؤقتاً (حسب الإجابة على السؤال #3)
- **جميع الـ Blocs الأخرى**: (ChartOfAccountsBloc, JournalEntriesBloc, etc.) لن تتأثر

---

## Verification Plan

### Automated Tests
```bash
# التحقق من عدم وجود أخطاء تحليل
dart analyze lib/

# التحقق من البناء
flutter build apk --debug
```

### Manual Verification
- التنقل بين جميع الأقسام الـ 8 في الـ Sidebar
- التحقق من حفظ حالة كل فرع عند التبديل (Stateful Navigation)
- التنقل بين تبويبات الحسابات
- التحقق من Auth Guard (عدم المصادقة → Login)
- فتح/إغلاق الـ Dialogs (showDialog) بشكل طبيعي
- التحقق من عمل الـ Drawer في وضع الموبايل
- التحقق من عمل الـ BottomNavigationBar
