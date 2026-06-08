enum DateType {
  day(10, 31, 'يوم', 0),
  month(7, 12, 'شهر', 3),
  year(4, 1000, 'سنة', 6),
  selected(-1, -1, 'تحديد تاريخ', -1);

  final int lengthDate;
  final int countReference;
  final String typeName;
  final int startIndex;

  const DateType(
    this.lengthDate,
    this.countReference,
    this.typeName,
    this.startIndex,
  );
}

enum DatabaseType {
  sqlite(symbol: '(Q)', isDefault: true),
  mysql(symbol: '(M)');

  final String symbol;
  final bool isDefault;

  const DatabaseType({required this.symbol, this.isDefault = false});

  bool get isSqlite {
    return name == sqlite.name;
  }

  bool get isMySql {
    return this == mysql;
  }

  bool get isSqlDatabase {
    return isMySql || isSqlite;
  }
}
