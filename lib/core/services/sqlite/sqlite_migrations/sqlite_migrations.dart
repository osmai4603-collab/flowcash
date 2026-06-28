import 'package:flowcash/core/services/sqlite/sqlite_migrations/sqlite_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v2_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v3_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v4_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v5_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v6_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v7_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v8_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v9_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v10_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v11_migration.dart';
import 'package:flowcash/core/services/sqlite/sqlite_migrations/v12_migration.dart';

final List<SqliteMigration> sqliteMigrations = [
  V2Migration(),
  V3Migration(),
  V4Migration(),
  V5Migration(),
  V6Migration(),
  V7Migration(),
  V8Migration(),
  V9Migration(),
  V10Migration(),
  V11Migration(),
  V12Migration(),
];
