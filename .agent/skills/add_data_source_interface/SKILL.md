---
name: إضافة واجهة مصدر بيانات (Data Source Interface Development)
description: القواعد الصارمة والمعايير الهندسية لبناء واجهات مصادر البيانات في طبقة الـ Data بـ Clean Architecture.
---

# مهارة إضافة واجهة مصدر بيانات (Data Source Interface Development)

تُلسم واجهات مصادر البيانات بتحديد العمليات والخصائص الفنية للربط بمصادر البيانات (محلية أو بعيدة).

## 📂 الموقع والتسمية

* **المسار**: `lib/features/[feature_name]/data/datasources/`.
* **التصنيف**:
  * **محلي**: ينتهي بـ `_local_data_source.dart`. (مثال: `auth_local_data_source.dart`).
  * **بعيد**: ينتهي بـ `_remote_data_source.dart`. (مثال: `auth_remote_data_source.dart`).

## 🏗️ القواعد البرمجية الصارمة

### 1. الوراثة والتعريف

* يجب تعريف الكلاس كـ **`abstract interface class`**.

### 2. أنواع الإرجاع (Return Types)

* يتم الإرجاع كـ **`Future<T>`** أو **`Future<Map<String, dynamic>>`** أو **`Future<List<Model>>`**.
* **يمنع** استخدام `Either` هنا؛ الأخطاء يتم معالجتها برمي استثناءات (Exceptions) صريحة (مثل `ServerException`, `LocalDatabaseException`).
* هذا يتيح للـ Repository التقاط الخطأ وتغليفه في `Failure`.

### 3. التوثيق (Documentation)

* يجب وضع تعليقات (Docstrings) لكل عملية لتسهيل التفعيل.

## 📝 النموذج التطبيقي (Template)

```dart
import 'package:furnigo_mgmt/features/[feature_name]/data/models/example_model.dart';

/// واجهة لمصدر البيانات المحلي لـ [Example].
abstract interface class ExampleLocalDataSource {
  /// جلب كافة البيانات المخزنة محلياً.
  Future<List<ExampleModel>> getAll();

  /// حفظ البيانات.
  Future<void> save(ExampleModel model);
}
```

## ⚠️ مبادئ ذهبية

* **بسيطة**: الواجهة يجب أن تكون بسيطة ومباشرة في تسمية العمليات.
* **تفصيلية**: افصل بين المحلي (Local) والبعيد (Remote) في ملفات واجهات مستقلة.

---
> [!TIP]
> تذكر أن الـ DataSource مهتم فقط بتمثيل البيانات التقني (المحلي والبعيد).
