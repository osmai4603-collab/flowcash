




enum WarehouseValueType {
  defaultSalesAccount(
    typeName: 'حساب المبيعات الافتراضي',
    dataType: DataType.integer,
  ),
  defaultBuysAccount(
    typeName: 'حساب المشتريات الافتراضي',
    dataType: DataType.integer,
  ),
  defaultBackSalesAccount(
    typeName: 'حساب مرتجع المبيعات الافتراضي',
    dataType: DataType.integer,
  ),
  defaultBackBuysAccount(
    typeName: 'حساب مرتجع المشتريات الافتراضي',
    dataType: DataType.integer,
  );

  const WarehouseValueType({required this.typeName, required this.dataType});
  final String typeName;
  final DataType dataType;

  @override
  String toString() {
    return name;
  }

  static WarehouseValueType of(String map) {
    return values.firstWhere((type) => type.name == map);
  }
}


enum DataType {
  integer, real, text, boolean;
}