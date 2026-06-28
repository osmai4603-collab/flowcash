import 'package:sqlite3/sqlite3.dart';

abstract class SqliteMigration {
  int get version;
  void execute(Database db);
}
