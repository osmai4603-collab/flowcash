---
name: إضافة تنفيذ مستودع (Repository Implementation Development)
description: القواعد الصارمة والمعايير الهندسية لبناء تنفيذات المستودعات (Implementations) في طبقة الـ Data بـ Clean Architecture.
---

# مهارة إضافة تنفيذ مستودع (Repository Implementation Development)

تُهتم تنفيذات المستودعات بالربط الفعلي بين طبقة الـ Domain والـ Data. وهي المسؤولة عن معالجة الاستثناءات (Exceptions) وتحويلها إلى فشل (Failures).

## 📂 الموقع والتسمية

* **المسار**: `lib/features/[feature_name]/data/repositories/`.
* **اسم الملف**: `snake_case` ينتهي بـ `_repository_impl.dart` (مثال: `auth_repository_impl.dart`).
* **اسم الكلاس**: `PascalCase` ينتهي بـ `RepositoryImpl` (مثال: `AuthRepositoryImpl`).

## 🏗️ القواعد البرمجية الصارمة

### 1. الوراثة والارتباط

* يجب أن يقوم الكلاس بعمل **`implements`** للواجهة (Interface) المقابلة له في طبقة الـ Domain.

### 2. الحقن (Injection)

* يتم حقن مصادر البيانات (Data Sources) المطلوبة عبر الـ constructor كمتغيرات `final` و `private`.

### 3. معالجة الأخطاء (Error Handling)

* **⚠️ قاعدة صارمة**: يجب استخدام نمط `try-catch` في كل دالة تتعامل مع مصادر خارجية.
* التقاط الاستثناءات (Exceptions) من طبقة الـ Data وتحويلها إلى الكلاس المناسب لـ `Failure` (مثل `ServerFailure`, `LocalDatabaseFailure`).
* إرجاع النتيجة ملفوفة في **`right(data)`** عند النجاح، وفي **`left(failure)`** عند القصور.

### 4. تحويل البيانات (Data Transformations)

* المصادر (DataSources) ترجع عادة `Models`.
* يجب التأكد من تحويل هذه الـ `Models` (كائنات برمجية تقنية) إلى `Entities` (كائنات برمجية نظيفة) قبل إرسالها للأعلى.

## 📝 النموذج التطبيقي (Template)

```dart
import 'package:fpdart/fpdart.dart';
import 'package:furnigo_mgmt/core/errors/exceptions.dart';
import 'package:furnigo_mgmt/core/errors/failure.dart';
import 'package:furnigo_mgmt/features/[feature_name]/domain/entities/example_entity.dart';
import 'package:furnigo_mgmt/features/[feature_name]/domain/repositories/example_repository.dart';
import 'package:furnigo_mgmt/features/[feature_name]/data/datasources/example_local_data_source.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleLocalDataSource _localDataSource;

  const ExampleRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, ExampleEntity>> getExample(int id) async {
    try {
      final model = await _localDataSource.getById(id);
      return right(model); // الموديل يرث من الكائن النظيف (Entity)
    } on LocalDatabaseException catch (e) {
      return left(LocalDatabaseFailure(e.message));
    } catch (e) {
      return left(LocalDatabaseFailure(e.toString()));
    }
  }
}
```

## ⚠️ محظورات (Strict Prohibitions)

* **يمنع**: نسيان استخدام `try-catch`.
* **يمنع**: إرجاع الـ Models مباشرة لطبقة الـ Domain؛ دائماً عاملها كـ Entities.

---
> [!IMPORTANT]
> الالتزام بمعالجة كافة الاستثناءات هنا يمنع التطبيق من التوقف المفاجئ (App Crashing) عند حدوث خطأ في الاتصال أو قاعدة البيانات.
