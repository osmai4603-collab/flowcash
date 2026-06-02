---
description: تهيئة الكلاس الأساسي للترقيم (AppEnum) في المشروع
---

# 🏗️ سير العمل: تهيئة الكلاس الأساسي (`AppEnum`)

يتم تنفيذ هذه الخطوة مرة واحدة فقط للمشروع لتوفير البنية الأساسية لجميع الترقيمات (Enums) المتقدمة.

## 🏗️ الخطوة 1: إنشاء ملف `lib/core/enums/app_enum.dart`

1. تأكد من وجود كلاس `AppEnum` مع استيراد ملف الترجمة المناسب:
```dart
import 'package:[app_name]/core/localization/app_localizations.dart';

abstract class AppEnum {
  const AppEnum();

  String get name;
  int get index;
  
  String displayName(AppLocalizations localization);

  @override
  String toString() {
    return name;
  }
}
```

## ⚠️ قواعد ذهبية
* يتم تنفيذ هذا السير مرة واحدة فقط في بداية المشروع.
* يضمن هذا الكلاس توحيد التعامل مع جميع الـ Enums في التطبيق.
