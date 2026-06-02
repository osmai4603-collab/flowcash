---
description: كيفية إدارة نظام التنقل (Navigation Service) وإضافة مسارات جديدة (Routes)
---

# 🚀 إدارة نظام التنقل (Manage Navigation System)

يحدد هذا الدليل الخطوات الهندسية لبناء وإدارة نظام التنقل باستخدام `go_router` مع الالتزام بالمعايير المعتمدة في مشروع **Commodities**.

## 🏗️ 1. تعريف ثوابت المسارات (Route Keys)

**المسار:** `lib/core/constants/app_route_keys.dart`

قبل إضافة أي شاشة، يجب تعريف مسارها كثابت (Static Constant) في كلاس `AppRouteKeys`.

*   **القاعدة**: استخدم `sealed class` مع `private constructor`.
*   **التنظيم**: قم بتنظيم المسارات في مجموعات (مثل Auth, Dashboard, Features).
*   **التسمية**: ابدأ المسارات بـ `/dashboard/` إذا كانت داخل الـ Shell.

```dart
sealed class AppRouteKeys {
  const AppRouteKeys._();

  static const String myFeature = '/dashboard/my-feature';
  static const String myFeatureData = '/dashboard/my-feature/data';
}
```

## 🛠️ 2. بناء الـ Navigation Service

**المسار:** `lib/core/services/navigation_service.dart`

يتم تعريف كافة إعدادات التنقل داخل كلاس `NavigationService` بصيغة `sealed class`.

### **أ. هيكلية الـ Router الأساسية**
يجب أن تحتوي الخدمة على:
1.  `_rootNavigatorKey`: للمسارات خارج الـ Shell (مثل Login).
2.  `_shellNavigatorKey`: للمسارات داخل الـ Shell (التي تحتوي على Sidebar).
3.  `_authGuard`: دالة للتحكم في الوصول بناءً على حالة الـ Auth.

### **ب. إضافة ميزة جديدة (Feature Branch)**
**يمنع** كتابة المسارات المعقدة مباشرة داخل مصفوفة `routes`. بدلاً من ذلك، قم بتعريف الميزة كـ `static private field` من نوع `GoRoute`.

```dart
// ✅ الطريقة الصحيحة
static final GoRoute _myFeatureRoute = GoRoute(
  parentNavigatorKey: _shellNavigatorKey,
  path: AppRouteKeys.myFeature,
  builder: (context, state) => BlocProvider(
    create: (context) => sl<MyFeatureBloc>(),
    child: const MyFeaturePage(),
  ),
  routes: [
    GoRoute(
      path: 'data', // مسار فرعي نسبي
      builder: (context, state) => BlocProvider.value(
        value: sl<MyFeatureBloc>(),
        child: const MyFeatureDataPage(),
      ),
    ),
  ],
);
```

### **ج. ربط الميزة بالـ Shell**
أضف الحقل الجديد إلى مصفوفة `routes` الخاصة بـ `ShellRoute` لضمان ظهور الـ Sidebar.

```dart
static final ShellRoute _shellRoute = ShellRoute(
  navigatorKey: _shellNavigatorKey,
  builder: (context, state, child) => MainScreen(child: child),
  routes: [
    _dashboardRoute,
    _myFeatureRoute, // ← إضافة الميزة هنا
    // ...
  ],
);
```

## 🧪 3. قواعد إدارة الحالة (State Management)

*   استخدم `BlocProvider` عند الحاجة لإنشاء نسخة جديدة من الـ Bloc لصفحة معينة.
*   استخدم `BlocProvider.value` عندما تريد تمرير Bloc موجود مسبقاً لمسار فرعي.
*   استخدم `MultiBlocProvider` إذا كانت الصفحة تعتمد على أكثر من Bloc/Cubit.

## 📝 معايير توثيق المسارات (Documentation Standards)

يجب الالتزام بنظام التوثيق الموحد داخل `NavigationService` لضمان مقروئية الملف وسهولة تتبعه:

### **أ. مخطط هيكلية المسارات (Route Hierarchy Tree)**
يجب تحديث المخطط في بداية الكلاس عند إضافة أي مسار رئيسي أو فرعي جديد، مع استخدام التنسيق التالي:
```dart
/// **هيكلية المسارات:**
/// ```
/// /login                              ← Root Navigator (بدون Shell)
/// StatefulShellRoute                  ← MainScreen (Stateful Navigator)
///   ├── Branch: Dashboard             ← DashboardPage
///   ├── Branch: Products              ← ProductsPage
///   └── ...                           ← فروع أخرى مستقلة
/// ```
```

### **ب. الفواصل الجمالية (Decorative Headers)**
استخدم هذا التنسيق للفصل بين الأقسام الكبرى (مثل فترات الفروع):
```dart
  // ╔════════════════════════════════════════════════════════════════════╗
  // ║                          Branches                                ║
  // ╚════════════════════════════════════════════════════════════════════╝
```

## 🚀 خطوات إضافة مسار تنقل جديد (How to Add a New Route)

عند إضافة شاشة أو ميزة جديدة، اتبع هذه الخطوات بالترتيب لضمان التوافق مع المعمارية الـ Stateful:

### **1. تعريف مفتاح المسار (Route Key)**
توجه إلى `lib/core/constants/app_route_keys.dart` وأضف الثابت الجديد:
```dart
static const String myNewFeature = '/dashboard/my-feature';
```

### **2. تعريف المسار في الـ Service**
قم بتعريف الـ `GoRoute` الخاص بالميزة كـ `static field` (بدون الحاجة لـ `parentNavigatorKey` إلا في حالات نادرة جداً):
```dart
static final GoRoute _myFeatureRoute = GoRoute(
  path: AppRouteKeys.myNewFeature,
  builder: (context, state) => const MyFeaturePage(),
);
```

### **3. تسجيل الفرع (Registering the Branch)**
إذا كانت الميزة قسماً رئيسياً (في الـ Sidebar)، قم بإنشاء `StatefulShellBranch`:
```dart
static final StatefulShellBranch _myFeatureBranch = StatefulShellBranch(
  routes: [_myFeatureRoute],
);
```

### **4. تسجيل الفرع في الـ StatefulShellRoute**
أضف الفرع الجديد إلى مصفوفة `branches` داخل الـ `_statefulShellRoute`:
```dart
static final StatefulShellRoute _statefulShellRoute = StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => MainScreen(navigationShell: navigationShell),
  branches: [
    _dashboardBranch,
    _myFeatureBranch, // ← إضافة الفرع هنا
  ],
);
```

### **4. تحديث التوثيق (Documentation)**
قم بتحديث "مخطط هيكلية المسارات" في رأس ملف `NavigationService.dart` ليعكس الميزة الجديدة.

### **5. تنفيذ التنقل (Navigation)**
استخدم الـ `context` للتنقل في الـ UI:
```dart
context.go(AppRouteKeys.myNewPage);
```

## 📝 معايير توثيق المسارات (Documentation Standards)

يجب الالتزام بنظام التوثيق الموحد داخل `NavigationService` لضمان مقروئية الملف وسهولة تتبعه:

### **أ. مخطط هيكلية المسارات (Route Hierarchy Tree)**
يجب تحديث المخطط في بداية الكلاس عند إضافة أي مسار رئيسي أو فرعي جديد، مع استخدام التنسيق التالي:
```dart
/// **هيكلية المسارات:**
/// ```
/// /path                              ← الوصف (Navigator النوع)
///   ├── /sub-path                    ← وصف المسار الفرعي
///   └── /another-path                ← وصف مسار آخر
/// ```
```

### **ب. الفواصل الجمالية (Decorative Headers)**
استخدم هذا التنسيق للفصل بين الأقسام الكبرى (مثل فروع الميزات):
```dart
  // ╔════════════════════════════════════════════════════════════════════╗
  // ║                     [اسم القسم بالإنجليزية]                             ║
  // ╚════════════════════════════════════════════════════════════════════╝
```

### **ج. فواصل الميزات الفرعية (Feature Branch Headers)**
استخدم هذا التنسيق البسيط داخل مصفوفة المسارات أو قبل تعريف الـ `static field`:
```dart
// ── [اسم الميزة] ────────────────────────────────────────
```

## 📝 معايير توثيق مفاتيح المسارات (AppRouteKeys Standards)

يجب الالتزام بالتوثيق والترتيب التالي في ملف `lib/core/constants/app_route_keys.dart`:

### **أ. التعليق الرئيسي (Main Docstring)**
يجب أن يبدأ الملف دائماً بهذا التعليق:
```dart
/// ثوابت مفاتيح مسارات التنقل في التطبيق.
///
/// يتم استدعاء هذه الثوابت من [NavigationService] و الـ UI
/// لضمان عدم تكرار النصوص (Hardcoded Strings).
```

### **ب. تقسيم المسارات (Route Segmentation)**
يتم تقسيم المسارات باستخدام فواصل نصية واضحة لكل ميزة:
```dart
  // ── [اسم الميزة بالإنجليزية] Branch ───────────────────────────────────
  static const String myRoute = '/dashboard/my-route';
```

## 💡 ملاحظات عامة (General Notes)
*مستنبطة من ملف `NavigationService.dart`*

*   **Navigator Keys**:
    *   `_rootNavigatorKey`: يُستخدم للمسارات الجذرية التي لا تتبع الـ Shell (مثل صفحة الـ Login).
    *   `_shellNavigatorKey`: يُستخدم لكافة المسارات التي يجب أن تظهر داخل إطار التطبيق الرئيسي (MainScreen).
*   **Initial Location**: يجب أن يكون `initialLocation` دائماً موارياً لـ `AppRouteKeys.dashboard` لضمان بدء التطبيق من لوحة التحكم (مع مراعاة الـ Auth Guard).
*   **Dependency Injection**: يتم حقن الـ Blocs/Cubits مباشرة في الـ `builder` الخاص بكل مسار لضمان توفرها عند الحاجة.

## ⚠️ محاذير وقواعد ذهبية

1.  **Documentation First**: لا تضف مساراً دون تحديث مخطط الهيكلية في رأس ملف الـ Service.
2.  **Typo Safety**: لا تكتب الـ Paths كنصوص مباشرة (Strings) أبداً؛ استخدم دائماً `AppRouteKeys`.
3.  **Hierarchy Alignment**: تأكد من أن المسار في `AppRouteKeys` يتطابق تماماً مع المسار المعرف في الـ Service.
4.  **Auth Guard Execution**: يتم تنفيذ الـ Auth Guard تلقائياً لضمان أمان التطبيق.
