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
2.  **كلاس `SqliteService`**: الموجود في `lib/core/services/sqlite/sqlite_service.dart`.
    *   [دليل بناء خدمة SQLite3](resources/sqlite3_service_implementation.md).
3.  **كلاس `TableInfo`**: الفئة الأساسية لتعريف الجداول في `lib/core/services/sqlite/table_info.dart`.
4.  **كلاس `SqliteTable`**: الفئة الأساسية لإنشاء الجداول في `lib/core/services/sqlite/sqlite_tables/sqlite_table.dart`.
5.  **الثوابت والجداول (Tables)**: الموجودة في `lib/core/tables/`. يجب أن ترث من `TableInfo` وتطبق نمط الـ Singleton.
6.  **جداول SQLite**: الموجودة في `lib/core/services/sqlite/sqlite_tables/`. وتكون كلاسات ترث من كلاس الجدول الأصلي وتنفذ `SqliteTable` (أيضاً بنمط الـ Singleton).
7.  **مسار قاعدة البيانات**: يجب استدعاء المسار الخاص بالتطبيق الحالي (Application Documents Directory) لتخزين ملف قاعدة البيانات لضمان الوصول الصحيح والأمان.

> [!IMPORTANT]
> *   يجب أن يحتوي كل كلاس جدول على `List<String> get columns` يُرجع قائمة بجميع الحقول.
> *   **يمنع** استخدام الحقول الثابتة `static final/const` على مستوى الجدول؛ يجب أن تكون حقول نهائية `final` ويتم إنشاؤها عبر كائن مفرد (Singleton).
> *   **يمنع** استخدام prefix مثل `col` في تسمية الحقول (استخدم `id` بدلاً من `colId`).
> *   **يجب** توثيق كل حقل بتعليق يوضح دوره والقيود المفروضة عليه.

## 🔄 خطوات العمل الإجرائية
1.  **إضافة والتحقق من التبعات**:
    *   في حال عدم وجود المكتبات، قم بتشغيل: `flutter pub add sqlite3 sqlite3_flutter_libs path_provider path`
    *   تأكد دائماً من تشغيل `flutter pub get` بعد الإضافة.
    *   التحقق من وجود وجاهزية كلاس `SqliteService`.
2.  **تحديث الخدمة وإجراء Migrations**:
    *   زيادة رقم الإصدار `currentVersion` في `SqliteSchemaManager`.
    *   إنشاء كلاس مستقل للـ Migration يرث من `SqliteMigration` داخل مجلد `lib/core/services/sqlite/sqlite_migrations/` (مثال: `V10Migration`).
    *   تسجيل الـ instance الخاص بالـ Migration الجديد في قائمة `sqliteMigrations` داخل ملف `lib/core/services/sqlite/sqlite_migrations/sqlite_migrations.dart`.
    *   **يمنع منعاً باتاً** كتابة أسماء الجداول أو الأعمدة كنصوص مباشرة (Hardcoded Strings) داخل كلاس الـ Migration؛ يجب استدعاؤها من كائن الجدول المفرد (مثل `MyTable().tableName`).
3.  **إنشاء جدول جديد**:
    *   أنشئ كلاس الجدول في `lib/core/tables/` يرث من `TableInfo` وبنمط الـ Singleton.
    *   أنشئ كلاس الـ Sqlite المقابل في `lib/core/services/sqlite/sqlite_tables/` ينتهي بـ `Sqlite` ويرث من جدول البيانات وينفذ `SqliteTable`.
    *   سجل الجدول الجديد في قائمة الجداول في `SqliteSchemaManager._createAllTables`.
4.  **التكامل (Clean Architecture)**:
    *   يتم استدعاء `SqliteService` من خلال `DataSources`.
    *   استخدم كائن الجدول المفرد (مثل `MyTable().tableName`) بدلاً من النصوص المباشرة.

## 📌 مثال استدعاء الجداول وتصميمها

### تصميم كلاس جدول البيانات (مثال: `MyTable` في `lib/core/tables/my_table.dart`):
```dart
import 'package:flowcash/core/services/sqlite/table_info.dart';

class MyTable extends TableInfo {
  static final MyTable _instance = MyTable._internal();
  factory MyTable() => _instance;
  MyTable._internal();

  @override
  final String tableName = 'my_table';

  final String id = 'id';
  final String myColumn = 'my_column';

  @override
  List<String> get columns => [id, myColumn];
}
```

### تصميم كلاس إنشاء الجدول (مثال: `MyTableSqlite` في `lib/core/services/sqlite/sqlite_tables/my_table_sqlite.dart`):
```dart
import 'package:flowcash/core/services/sqlite/sqlite_tables/sqlite_table.dart';
import 'package:flowcash/core/tables/my_table.dart';

class MyTableSqlite extends MyTable implements SqliteTable {
  static final MyTableSqlite _instance = MyTableSqlite._internal();
  factory MyTableSqlite() => _instance;
  MyTableSqlite._internal();

  @override
  String get queryCreateTable => '''
    CREATE TABLE IF NOT EXISTS $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      $myColumn TEXT NOT NULL
    )
  ''';
}
```

