---
name: إضافة تنفيذ مصدر بيانات (Data Source Implementation Development)
description: القواعد الصارمة والمعايير الهندسية لبناء تنفيذات مصادر البيانات في طبقة الـ Data بـ Clean Architecture.
---

# مهارة إضافة تنفيذ مصدر بيانات (Data Source Implementation Development)

تُهتم تنفيذات مصادر البيانات بالربط الفعلي بالخدمات الخارجية (نظام قواعد البيانات المحلي أو الـ APIs).

## 📂 الموقع والتسمية

* **المسار**: `lib/features/[feature_name]/data/datasources/`.
* **التصنيف**:
  * **محلي**: ينتهي بـ `_local_data_source_impl.dart`. (مثال: `auth_local_data_source_impl.dart`).
  * **بعيد**: ينتهي بـ `_remote_data_source_impl.dart`. (مثال: `auth_remote_data_source_impl.dart`).

## 🏗️ القواعد البرمجية الصارمة

### 1. الوراثة والارتباط

* يجب أن يقوم الكلاس بعمل **`implements`** للواجهة (Interface) المقابلة له.

### 2. الحقن (Injection)

* يتم حقن الخدمات المطلوبة (`DatabaseService`, `ApiService`) عبر الـ constructor كمتغيرات `final` و `private`.

### 3. معالجة الأخطاء (Error Handling)

* **⚠️ قاعدة صارمة**: يتم رمي استثناءات مخصصة (`Exceptions`) عند حدوث أخطاء، ولا يتم استخدام أنواع الفشل (`Failures`) هنا.
* إرجاع النتيجة المطلوبة في حالة النجاح.

### 4. التعامل مع البيانات (Data Handling)

* **SQLite3**: استخدم الجداول المركزية (Table Constants) لضمان صحة أسماء الحقول والجداول.
* **API**: استخدم الموديلات (`Models`) من طبقة الـ Data للتعامل مع البيانات القادمة من الـ API (Serialization).

### 5. المعالجة المكثفة (Heavy Processing)

* عند القيام بعمليات تحويل بيانات (`Serialization`) ضخمة، استخدم دالة `compute` لنقل العملية إلى Isolate منفصل وضمان سلاسة UI.

## 📝 النموذج التطبيقي (Template)

```dart
import 'package:furnigo_mgmt/core/services/database/database_service.dart';
import 'package:furnigo_mgmt/core/tables/example_table.dart';
import 'package:furnigo_mgmt/features/[feature_name]/data/models/example_model.dart';
import 'example_local_data_source.dart';

class ExampleLocalDataSourceImpl implements ExampleLocalDataSource {
  final DatabaseService _databaseService;

  const ExampleLocalDataSourceImpl(this._databaseService);

  @override
  Future<List<ExampleModel>> getAll() async {
    final t = ExampleTable();
    final results = await _databaseService.read(t.tableName);
    return results.map((e) => ExampleModel.fromMap(e)).toList();
  }

  @override
  Future<void> save(ExampleModel model) async {
    final t = ExampleTable();
    await _databaseService.insert(t.tableName, model.toMap());
  }
}
```

## ⚠️ مبادئ ذهبية

* **فنية بحتة**: الـ DataSource لا يعرف شيئاً عن منطق الأعمال، هو مجرد جسر تقني لمصادر البيانات.
* **دائماً**: استخدم المتغيرات الخاصة والـ constructor لضمان إمكانية عمل `Mocking` للاختبار.

---
> [!IMPORTANT]
> الالتزام بهذه الهيكلية يسهل عملية استبدال مصدر البيانات (مثلاً: التحول من SQLite إلى Hive) دون المساس ببقية أجزاء التطبيق.
