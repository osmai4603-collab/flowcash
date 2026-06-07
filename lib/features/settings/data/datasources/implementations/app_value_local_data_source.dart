import 'package:flowcash/core/services/sqlite_service.dart';
import 'package:flowcash/core/tables/values_table.dart';
import 'package:flowcash/core/enums/app_value_type_enum.dart';
import '../../models/app_value_model.dart';
import '../interfaces/app_value_data_source.dart';

class AppValueLocalDataSourceImpl implements AppValueDataSource {
  final SqliteService _db;

  const AppValueLocalDataSourceImpl(this._db);

  @override
  Future<List<AppValueModel>> getAllValues() async {
    final rows = await _db.query(
      table: ValuesTable.tableName,
      orderBy: ValuesTable.id,
    );
    return rows.map(AppValueModel.fromMap).toList();
  }

  @override
  Future<AppValueModel> getValueByType(AppValueType type) async {
    final rows = await _db.query(
      table: ValuesTable.tableName,
      where: '${ValuesTable.valueType} = ?',
      whereArgs: [type.name],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw Exception('Value not found for ${type.name}');
    }
    return AppValueModel.fromMap(rows.first);
  }

  @override
  Future<bool> updateValue(AppValueModel value) async {
    final data = value.toMap();
    await _db.update(
      table: ValuesTable.tableName,
      data: data,
      where: {ValuesTable.id: value.id},
    );
    return true;
  }
}
