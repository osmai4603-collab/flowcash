---
name: إدارة قاعدة البيانات (SQLite3 Management)
description: كيفية التعامل مع SQLite3، تعاريف الجداول، وإدارة إصدارات الهيكل (Versioning).
---

# مهارة إدارة قاعدة البيانات (SQLite3 Management)

استخدم هذه المهارة عند إضافة أو تعديل هيكل قاعدة البيانات المحلية باستخدام SQLite.

## 💡 متى وكيف تطلب استخدام هذه المهارة؟
*   **متى؟**:
    *   عند الحاجة لتخزين بيانات محلياً أو إضافة جداول جديدة.
    *   **عند الحاجة لتعديل إصدار قاعدة البيانات (Database Version Change)**.
    *   **عند إضافة مشغلات (Triggers) جديدة لقاعدة البيانات**.
*   **كيف؟**: اطلب "أضف جدولاً للمنتجات"، "حدث إصدار قاعدة البيانات"، أو "أضف Trigger لمراقبة التغييرات"، وسأقوم بإدارة ملفات الجداول والخدمات.

## 🎯 الحاجة لهذه المهارة
تضمن هذه المهارة توحيد هيكل البيانات، وتسهل عمليات الـ Migration (التحديث الزمني للهيكل)، وتعتمد على `SqliteService` كمدير أساسي لكل العمليات.

## ✅ مسؤوليات المهارة (Skill Responsibilities)
تشمل هذه المهارة القيام بالمهام التالية:
1.  **إدارة الجداول**: إنشاء جداول جديدة (`CREATE`) وتعديلها (`ALTER`) أو حذفها (`DROP`).
2.  **إدارة المشغلات (Triggers)**: إضافة وإدارة الـ Triggers لضمان تكامل البيانات وبرمجة ردود الفعل التلقائية.
3.  **إدارة إصدارات قاعدة البيانات (Migrations)**: التعامل مع التحديثات عبر زيادة `user_version` وتنفيذ الدوال البرمجية المناسبة لكل إصدار.
4.  **تجريد الوصول للبيانات**: توفير كلاسات الثوابت للجداول والأعمدة لمنع استخدام النصوص المباشرة في الكود.

## 📦 المكتبات المطلوبة (Required Libraries)
*   **المكتبات الأساسية**:
    *   `sqlite3`: المكتبة الأساسية للتعامل مع قاعدة البيانات.
    *   `sqlite3_flutter_libs`: ضرورية لدعم التشغيل على منصات الجوال (Android/iOS) لضمان توافر المحرك البرمجي.
    *   `path_provider` و `path`: لتحديد مسارات تخزين قاعدة البيانات بشكل صحيح وتوافقي مع كافة المنصات (Cross-platform).

*   **خطوات التنفيذ**:
    *   يجب تشغيل الأوامر التالية لإضافة المكتبات البرمجية:
        ```bash
        flutter pub add sqlite3 sqlite3_flutter_libs path_provider path
        ```
    *   > [!NOTE]
    *   > بعد إضافة المكتبات، يجب استدعاء الأمر `flutter pub get` للتأكد من تحديث كافة الاعتمادات.

## 🛠️ المتطلبات التقنية
تعتمد هذه المهارة بشكل أساسي على:
1.  **المكتبات المذكورة أعلاه**: يجب التأكد من وجودها في `pubspec.yaml`.
2.  **كلاس `SqliteService`**: الموجود في `lib/core/services/sqlite_service.dart`.
    *   [دليل بناء خدمة SQLite3](resources/sqlite3_service_implementation.md).
3.  **الثوابت (Tables)**: الموجودة في `lib/core/constants/tables/`.
4.  **مسار قاعدة البيانات**: يجب استدعاء المسار الخاص بالتطبيق الحالي (Application Documents Directory) لتخزين ملف قاعدة البيانات لضمان الوصول الصحيح والأمان.

> [!IMPORTANT]
> *   يجب أن يحتوي كل كلاس جدول على `List<String> get columns` يُرجع قائمة بجميع الحقول.
> *   **يمنع** استخدام prefix مثل `col` في تسمية الحقول (استخدم `id` بدلاً من `colId`).
> *   **يجب** توثيق كل حقل بتعليق يوضح دوره والقيود المفروضة عليه.

## 🔄 خطوات العمل الإجرائية
1.  **إضافة والتحقق من التبعات**:
    *   في حال عدم وجود المكتبات، قم بتشغيل: `flutter pub add sqlite3 sqlite3_flutter_libs path_provider path`
    *   تأكد دائماً من تشغيل `flutter pub get` بعد الإضافة.
    *   التحقق من وجود وجاهزية كلاس `SqliteService`.
2.  **تحديث الخدمة**:
    *   زيادة رقم الإصدار `user_version` في `SqliteService`.
    *   إضافة جملة `CREATE TABLE` أو `ALTER TABLE` أو `CREATE TRIGGER` في دالة `_onCreate()` أو الدوال المخصصة للـ Migration (`_onUpgrade`).
    *   **يمنع منعاً باتاً** كتابة أسماء الجداول أو الأعمدة كنصوص مباشرة (Hardcoded Strings) داخل `SqliteService`.
    *   يجب إنشاء instance من كلاس الجدول واستدعاء الحقول منه.
3.  **التكامل (Clean Architecture)**:
    *   يتم استدعاء `SqliteService` من خلال `DataSources`.
    *   يمنع استدعاء الأسماء النصية للجداول مباشرة؛ استخدم كلاس الثوابت (مثل `MyTable().tableName`).

## 📌 مثال استدعاء الجداول داخل `_onCreate`

```dart
void _onCreate(Database db) {
  final myTable = MyTable();

  db.execute('''
    CREATE TABLE IF NOT EXISTS ${myTable.tableName} (
      ${myTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      ${myTable.myColumn} TEXT NOT NULL
    )
  ''');
}
```

### ❌ الطريقة الخاطئة (Incorrect)
```dart
db.execute('CREATE TABLE IF NOT EXISTS my_table (id INTEGER ..., my_column TEXT ...)');
```

### ✅ الطريقة الصحيحة (Correct)
```dart
final myTable = MyTable();
db.execute('CREATE TABLE IF NOT EXISTS ${myTable.tableName} (${myTable.id} INTEGER ..., ${myTable.myColumn} TEXT ...)');
```
