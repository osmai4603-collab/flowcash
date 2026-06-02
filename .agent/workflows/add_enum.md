---
description: كيفية إنشاء ترقيم متقدم (Class-based Enum) يتبع معايير المشروع
---

# 📖 سير العمل: إنشاء ترقيم جديد (Create New Enum)

يتبع هذا المشروع نمط الترقيم المتقدم المعتمِد على الـ `sealed class` لضمان الأمان والمرونة. اتبع الخطوات التالية بدقة:

## 🛠️ خطوات إنشاء الترقيم الجديد

### 1. تحديد موقع الملف وتسميته
*   أنشئ ملفاً جديداً في `lib/core/enums/` أو داخل المجلد الفرعي للميزة.
*   اسم الملف يجب أن يكون `snake_case` وينتهي بـ `_enum.dart` (مثال: `order_status_enum.dart`).

### 2. تعريف الكلاس الأساسي (Sealed Class)
*   استخدم `sealed class` لضمان تغطية جميع الحالات في جمل الـ `switch`.
*   يجب أن يرث مباشرة من `AppEnum`.
*   **هام**: لا تنسَ استيراد `app_enum.dart` و `app_localizations.dart`.

```dart
import 'app_enum.dart';
import 'package:[app_name]/core/localization/app_localizations.dart';

sealed class OrderStatusEnum extends AppEnum {
  // الحالات الثابتة ستُعرف هنا لاحقاً
  static const pending = PendingOrderStatus._();
  static const delivered = DeliveredOrderStatus._();

  static List<OrderStatusEnum> get values => [pending, delivered];

  static OrderStatusEnum of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown OrderStatusEnum: $name'),
    );
  }
}
```

### 3. تعريف الكلاسات الفرعية (Sub-classes)
*   اجعل كل حالة عبارة عن `final class`.
*   استخدم باني خاص `const PendingOrderStatus._();`.
*   قم بعمل `override` للخصائص المطلوبة.

```dart
final class PendingOrderStatus extends OrderStatusEnum {
  const PendingOrderStatus._();

  @override
  String get name => 'pending';

  @override
  int get index => 0;

  @override
  String displayName(AppLocalizations localization) => localization.statusPending;
}
```

### 4. تسجيل الحالات في الكلاس الأساسي
*   تأكد من إضافة `static const` instances لكل كلاس فرعي داخل الكلاس الأساسي.
*   تأكد من إضافة الحالة إلى قائمة `values`.

## ⚠️ قواعد ذهبية
*   **دائماً** استورد `AppLocalizations` لاستخدامها في `displayName`.
*   **لا تستخدم** `enum` Dart العادية.
*   **دائماً** استخدم دالة `of()` للتحويل من String إلى Enum.
*   **استقبل** باراميتر الترجمة باسم `localization` (وليس `l10n`).
*   **تأكد** من وجود ملف `init_app_enum.md` لتهيئة `AppEnum` إذا لم يكن المشروع مهيأً.
