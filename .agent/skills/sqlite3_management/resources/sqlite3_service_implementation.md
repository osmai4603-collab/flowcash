# بناء خدمة SQLite3 (SQLite3 Service Implementation)

توضح هذه الصفحة الهيكل المعياري لخدمة `SqliteService` المسؤولة عن إدارة قاعدة البيانات المحلية.

## 🏗️ هيكلية الكلاس (Class Structure)
يجب أن يتم بناء الـ `SqliteService` ككلاس مركزي لإدارة تفاعلات قاعدة البيانات.

### **يجب أن يبنى هذا الكلاس بهذه الهيكلية بالضبط:**

```dart
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
// استيراد كلاسات الجداول المطلوبة
import 'package:[app_name]/core/constants/tables/my_table.dart';

final class SqliteService {
  static SqliteService? _instance;
  static SqliteService get instance => _instance ??= const SqliteService._();
  const SqliteService._();
  factory SqliteService() => instance;

  static Database? _database;
  static const int _version = 1;
  static const String _dbName = 'app_database.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = join(dbFolder.path, _dbName);

    debugPrint('DATABASE PATH: $path');

    final db = sqlite3.open(path);

    // تفعيل المفاتيح الخارجية لضمان التكامل المرجعي.
    db.execute('PRAGMA foreign_keys = ON');

    final currentVersion = db.userVersion;

    if (currentVersion == 0) {
      _onCreate(db);
      db.userVersion = _version;
    } else if (currentVersion < _version) {
      _onUpgrade(db, currentVersion, _version);
      db.userVersion = _version;
    }

    return db;
  }

  /// إنشاء جميع الجداول - يمنع استخدام النصوص المباشرة.
  void _onCreate(Database db) {
    final myTable = MyTable();

    db.execute('''
      CREATE TABLE IF NOT EXISTS ${myTable.tableName} (
        ${myTable.id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        ${myTable.myColumn} TEXT NOT NULL
      )
    ''');
  }

  /// ترقية قاعدة البيانات بين الإصدارات.
  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // منطق التحديث (Migration) هنا
  }

  Future<int> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    final columns = data.keys.join(', ');
    final placeholders = List.filled(data.length, '?').join(', ');
    final stmt = db.prepare('INSERT INTO $table ($columns) VALUES ($placeholders)');
    stmt.execute(data.values.toList());
    final lastInsertId = db.lastInsertRowId;
    stmt.dispose();
    return lastInsertId;
  }

  Future<void> insertAll({
    required String table,
    required List<Map<String, dynamic>> dataList,
  }) async {
    if (dataList.isEmpty) return;
    final db = await database;
    final columns = dataList.first.keys.join(', ');
    final placeholders = List.filled(dataList.first.length, '?').join(', ');
    final stmt = db.prepare('INSERT INTO $table ($columns) VALUES ($placeholders)');
    
    for (final data in dataList) {
      stmt.execute(data.values.toList());
    }
    stmt.dispose();
  }

  Future<void> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> where,
  }) async {
    final db = await database;
    final setClause = data.keys.map((k) => '$k = ?').join(', ');
    final whereClause = where.keys.map((k) => '$k = ?').join(' AND ');
    final stmt = db.prepare('UPDATE $table SET $setClause WHERE $whereClause');
    stmt.execute([...data.values, ...where.values]);
    stmt.dispose();
  }

  Future<void> deleteById({
    required String table,
    required int id,
  }) async {
    final db = await database;
    final stmt = db.prepare('DELETE FROM $table WHERE id = ?');
    stmt.execute([id]);
    stmt.dispose();
  }

  Future<void> deleteWhere({
    required String table,
    required Map<String, dynamic> where,
  }) async {
    final db = await database;
    if (where.isEmpty) {
      db.execute('DELETE FROM $table');
      return;
    }
    final whereClause = where.keys.map((k) => '$k = ?').join(' AND ');
    final stmt = db.prepare('DELETE FROM $table WHERE $whereClause');
    stmt.execute(where.values.toList());
    stmt.dispose();
  }
}
```

## ⚠️ قواعد هامة
1. **استخدام الثوابت**: يجب استخدام كلاسات الجداول المعرفة في `lib/core/constants/tables/` لبناء جمل الـ SQL. **يمنع منعاً باتاً** كتابة أسماء الجداول أو الأعمدة كنصوص مباشرة.
2. **PRAGMA foreign_keys**: يجب تفعيل `PRAGMA foreign_keys = ON` عند فتح قاعدة البيانات لضمان التكامل المرجعي.
3. **إدارة الأخطاء**: يجب معالجة الأخطاء بشكل موحد لضمان استقرار التطبيق.
4. **الاستقلالية**: يجب أن تكون الخدمة مستقلة عن منطق الأعمال (Feature-Independent).
