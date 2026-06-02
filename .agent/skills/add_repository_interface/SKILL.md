---
name: إضافة واجهة مستودع (Repository Interface Development)
description: القواعد الصارمة والمعايير الهندسية لبناء المستودعات (Interfaces) في طبقة الـ Domain بـ Clean Architecture.
---

# مهارة إضافة واجهة مستودع (Repository Interface Development)

تُعرف واجهات المستودعات (Interfaces) في طبقة الـ Domain لتحديد العمليات المطلوبة للميزة دون الدخول في تفاصيل التفعيل.

## 📂 الموقع والتسمية

* **المسار**: `lib/features/[feature_name]/domain/repositories/`.
* **اسم الملف**: `snake_case` ينتهي بـ `_repository.dart` (مثال: `auth_repository.dart`).
* **اسم الكلاس**: `PascalCase` ينتهي بـ `Repository` (مثال: `AuthRepository`).

## 🏗️ القواعد البرمجية الصارمة

### 1. الوراثة والتعريف

* يجب تعريف الكلاس كـ **`abstract interface class`** لضمان استخدامه كعقد (Contract) فقط.
* **يمنع** استخدام أي Models في الواجهة. يجب استخدام الـ **Entities** و **الأنواع الأساسية**.

### 2. أنواع الإرجاع (Return Types)

* يجب أن ترجع جميع الدوال **`Future<Either<Failure, T>>`** لضمان توحيد معالجة الأخطاء.
* استخدم `unit` من `fpdart` لتمثيل النجاح في العمليات التي لا ترجع بيانات (مثل الحفظ أو الحذف).

### 3. التوثيق (Documentation)

* يجب كتابة تعليقات واضحة (Docstrings) فوق كل دالة تشرح الغرض منها.

## 📝 النموذج التطبيقي (Template)

```dart
import 'package:fpdart/fpdart.dart';
import 'package:furnigo_mgmt/core/errors/failure.dart';
import 'package:furnigo_mgmt/features/[feature_name]/domain/entities/example_entity.dart';

/// واجهة لمستودع الـ [Example].
abstract interface class ExampleRepository {
  /// جلب تفاصيل عنصر معين بواسطة المعرف.
  Future<Either<Failure, ExampleEntity>> getExample(int id);

  /// حفظ عنصر جديد.
  Future<Either<Failure, unit>> saveExample(ExampleEntity example);
}
```

## ⚠️ محظورات (Strict Prohibitions)

* **يمنع**: استيراد أي Model أو DataSource داخل ملف الواجهة.
* **يمنع**: إضافة أي Business Logic داخل الواجهة؛ وظيفتها هي "التعريف" فقط.

---
> [!TIP]
> تذكر أن طبقة الـ Domain لا تهتم بمصدر البيانات (SQL, API, Local Storage)، بل تهتم فقط بالعمليات المتاحة.
