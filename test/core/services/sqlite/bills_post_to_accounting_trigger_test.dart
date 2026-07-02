import 'dart:ffi';

import 'package:flowcash/core/services/sqlite/sqlite_triggers/bills_post_to_accounting_trigger.dart';
import 'package:flowcash/core/tables/bills_table.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  open.overrideFor(OperatingSystem.linux, () {
    return DynamicLibrary.open('/usr/lib/x86_64-linux-gnu/libsqlite3.so.0');
  });

  group('BillsPostToAccountingTrigger', () {
    test('fires when journalEntryId is set for the first time', () {
      final db = sqlite3.openInMemory();
      addTearDown(db.dispose);

      final billsTable = BillsTable();

      db.execute('''
        CREATE TABLE ${billsTable.tableName} (
          ${billsTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${billsTable.journalEntryId} INTEGER
        )
      ''');

      var wasCalled = false;
      db.createFunction(
        functionName: 'post_bill_to_accounting',
        function: (arguments) {
          wasCalled = true;
          return 1;
        },
        argumentCount: const AllowedArgumentCount(1),
        deterministic: true,
        directOnly: false,
      );

      BillsPostToAccountingTrigger.call(db);

      db.execute('INSERT INTO ${billsTable.tableName} (${billsTable.journalEntryId}) VALUES (NULL)');
      db.execute('UPDATE ${billsTable.tableName} SET ${billsTable.journalEntryId} = 7 WHERE ${billsTable.id} = 1');

      expect(wasCalled, isTrue);
    });
  });
}
