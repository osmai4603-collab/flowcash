---
name: تطوير الموديلات (Model Development)
description: القواعد الصارمة والمعايير الهندسية لبناء الموديلات (Models) في طبقة الـ Data بـ Clean Architecture.
---

# مهارة تطوير الموديلات (Model Development)

تُهتم الموديلات بتمثيل البيانات التقني (المحلي والبعيد). يجب أن تكون مرتبطة بـ Entity الخاص بها وتتعامل مع قواعد البيانات (مثل `fromMap` و `toMap`) بذكاء.

## 📂 الموقع والتسمية

* **المسار**: `lib/features/[feature_name]/data/models/`.
* **اسم الملف**: `snake_case` ينتهي بـ `_model.dart` (مثال: `product_model.dart`).
* **اسم الكلاس**: `PascalCase` ينتهي بـ `Model` (مثال: `ProductModel`).

## 🏗️ القواعد البرمجية الصارمة

### 1. الوراثة والتعريف

* يجب أن يكون الكلاس **`final class`** دائمًا.
* يجب أن يرث من الـ **Entity** المقابل له.
  * *مثال*: `final class ProductModel extends ProductEntity`.

### 2. الباني (Constructor)

* يجب استخدام باني **`const`** واستدعاء باني الأب (`super(...)`).

### 3. تحويل البيانات (Data Transformations)

* **`fromMap`**: دالة Factory لتحويل البيانات من الـ Database أو الـ API.
  * **⚠️ قاعدة صارمة**: يمنع منعاً باتاً استخدام النصوص المباشرة للمفاتيح. يجب استخدام كلاسات الجداول المركزية من `lib/core/tables/`.
  * **التحويل الفطري**: النوع `String`, `int`, `double`, `bool` القادمة من الـ Map لا تحتاج لـ `as` (تستخدم بشكل مباشر أو مع `??` للقيم الافتراضية).
  * **التحويل القسري**: يستخدم `as` فقط مع الـ `List` أو الكائنات المركبة.
  * **المصفوفات**: استخدم `List<T>.of(map[t.fieldName] as List<dynamic>? ?? [])` لضمان صحة الأنواع.

### 4. الـ `override` والإلزاميات

* **`toMap()`**: يجب عمل `override` لها واستخدام مفاتيح الجداول المركزية.
* **`copyWith()`**: يجب تنفيذ الدالة لترجع نوع الـ `Model` (مع استخدام `cast` للقوائم أو الحقول التي تم تغيير نوعها من Entity إلى Model).
* **`fromMap()`**: يجب تنفيذ الدالة كـ factory واستخدام مفاتيح الجداول المركزية.

## 📝 النموذج التطبيقي (Template)

```dart
import 'package:furnigo_mgmt/core/tables/example_table.dart';
import 'package:furnigo_mgmt/features/[feature_name]/domain/entities/example_entity.dart';

final class ExampleModel extends ExampleEntity {
  const ExampleModel({
    required super.id,
    required super.name,
    required super.price,
    super.tags,
  });

  factory ExampleModel.fromMap(Map<String, dynamic> map) {
    final t = ExampleTable(); // استخدام كلاس الجدول
    
    return ExampleModel(
      id: map[t.id],
      name: map[t.name] ?? '',
      price: (map[t.price] ?? 0.0).toDouble(),
      tags: (map[t.tags] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final t = ExampleTable();
    
    return {
      t.id: id,
      t.name: name,
      t.price: price,
      t.tags: tags,
    };
  }

  @override
  ExampleModel copyWith({
    int? id,
    String? name,
    double? price,
    List<String>? tags,
  }) {
    return ExampleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      tags: tags ?? this.tags,
    );
  }
}
```

## ⚠️ محظورات (Strict Prohibitions)

* **يمنع**: استخدام نصوص مثل `'id'` أو `'name'` داخل `fromMap` أو `toMap`. الالتزام بكلاسات الجداول إلزامي.
* **يمنع**: إضافة أي منطق اختيار أو شرطي معقد داخل دالة التحويل.

---
> [!IMPORTANT]
> استقلالية الـ Model عن الـ Entity تكمن في قدرته على التعامل مع "تمثيل البيانات" (Data Representation) بينما الـ Entity يهتم بـ "نموذج البيانات" (Data Model).
