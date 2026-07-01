abstract class TableInfo {
  const TableInfo();

  String get tableName;
  List<String> get columns;

  List<String> get fields => columns;

  @override
  String toString() {
    return tableName;
  }
}
