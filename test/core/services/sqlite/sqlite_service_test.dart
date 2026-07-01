import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:flowcash/core/services/sqlite/sqlite_service.dart';
import 'package:flowcash/core/services/sqlite/table_by_id.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () {
    return DynamicLibrary.open('/usr/lib/x86_64-linux-gnu/libsqlite3.so.0');
  });

  late Database db;
  late SqliteDatabase service;

  setUp(() {
    db = sqlite3.openInMemory();
    db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount INTEGER NOT NULL,
        active INTEGER NOT NULL
      )
    ''');
    service = SqliteDatabase(db);
  });

  tearDown(() {
    db.dispose();
  });

  group('SqliteService', () {
    test('insert, query, update and deleteWhere work together', () async {
      final insertedId = await service.insert(
        table: 'items',
        data: {'name': 'Coffee', 'amount': 15, 'active': 1},
      );

      expect(insertedId, 1);

      final rows = await service.query(table: 'items');
      expect(rows, hasLength(1));
      expect(rows.single['name'], 'Coffee');
      expect(rows.single['amount'], 15);

      await service.update(
        table: 'items',
        data: {'amount': 20},
        where: {'id': insertedId},
      );

      final updatedRows = await service.query(table: 'items');
      expect(updatedRows.single['amount'], 20);

      await service.deleteWhere(table: 'items', where: {'id': insertedId});

      final afterDelete = await service.query(table: 'items');
      expect(afterDelete, isEmpty);
    });

    test('insertAll and getById/getByIds/deleteById/deleteByIds work', () async {
      await service.insertAll(
        table: 'items',
        dataList: [
          {'name': 'Milk', 'amount': 10, 'active': 1},
          {'name': 'Bread', 'amount': 5, 'active': 0},
          {'name': 'Tea', 'amount': 7, 'active': 1},
        ],
      );

      final byId = await service.getById(table: const _TestTable(), id: 2);
      expect(byId, isNotNull);
      expect(byId!['name'], 'Bread');

      final byIds = await service.getByIds(table: const _TestTable(), ids: [1, 3]);
      expect(byIds, hasLength(2));
      expect(byIds.map((row) => row['name']).toSet(), {'Milk', 'Tea'});

      final deletedById = await service.deleteById(table: const _TestTable(), id: 2);
      expect(deletedById, isTrue);

      final remainingRows = await service.query(table: 'items');
      expect(remainingRows, hasLength(2));

      final deletedByIds = await service.deleteByIds(
        table: const _TestTable(),
        ids: [1, 3],
      );
      expect(deletedByIds, isTrue);

      final afterBulkDelete = await service.query(table: 'items');
      expect(afterBulkDelete, isEmpty);
    });

    test('transaction rolls back changes on exception', () async {
      await expectLater(
        service.transaction(() async {
          await service.insert(
            table: 'items',
            data: {'name': 'Sugar', 'amount': 3, 'active': 1},
          );
          throw Exception('boom');
        }),
        throwsException,
      );

      final rows = await service.query(table: 'items');
      expect(rows, isEmpty);
    });

    test('fetchFirst, rawQuery and execute work correctly', () async {
      await service.insertAll(
        table: 'items',
        dataList: [
          {'name': 'Milk', 'amount': 10, 'active': 1},
          {'name': 'Bread', 'amount': 5, 'active': 0},
        ],
      );

      final first = await service.fetchFirst(
        tableName: 'items',
        where: 'active = ?',
        whereArgs: [1],
      );
      expect(first, isNotNull);
      expect(first!['name'], 'Milk');

      final rawRows = await service.rawQuery(
        'SELECT name FROM items WHERE amount > ? ORDER BY amount DESC',
        [5],
      );
      expect(rawRows.map((row) => row['name']).toList(), ['Milk']);

      await service.execute('UPDATE items SET amount = 12 WHERE name = "Milk"');
      final afterExecute = await service.fetchFirst(
        tableName: 'items',
        where: 'name = ?',
        whereArgs: ['Milk'],
      );
      expect(afterExecute!['amount'], 12);
    });

    test('deleteWhere with empty where and empty id lists are safe', () async {
      await service.insertAll(
        table: 'items',
        dataList: [
          {'name': 'Milk', 'amount': 10, 'active': 1},
          {'name': 'Bread', 'amount': 5, 'active': 0},
        ],
      );

      await service.deleteWhere(table: 'items', where: {});
      expect(await service.query(table: 'items'), isEmpty);

      await service.insertAll(
        table: 'items',
        dataList: [
          {'name': 'Tea', 'amount': 7, 'active': 1},
        ],
      );

      final emptyByIds = await service.getByIds(table: const _TestTable(), ids: const []);
      expect(emptyByIds, isEmpty);

      final emptyDeleteByIds = await service.deleteByIds(
        table: const _TestTable(),
        ids: const [],
      );
      expect(emptyDeleteByIds, isTrue);
    });
  });
}

class _TestTable extends TableById {
  const _TestTable();

  @override
  String get tableName => 'items';

  @override
  List<String> get columns => const ['id', 'name', 'amount', 'active'];

  @override
  String get id => 'id';
}
