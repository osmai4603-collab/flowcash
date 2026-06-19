import 'package:flowcash/core/datasources/datasource.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';

abstract interface class UnitLocalDataSource
    implements AppDataSource<int, UnitEntity, Map<String, dynamic>> {
  Future<List<UnitEntity>> whereBasic({bool printQuery = true});
  Future<UnitEntity?> getFirstWhereArgs({
    double? length,
    double? width,
    double? thickness,
    required int propertyId,
    required UnitType unitType,
    String? unitName,
  });
  Future<List<UnitEntity>> getByMainCategory(int mainCategoryId);
}
