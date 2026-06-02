import 'app_enum.dart';

sealed class CategoryDefineType extends AppEnum {
  const CategoryDefineType();

  static const commodities = CommoditiesCategoryType._();
  static const rawMaterials = RawMaterialsCategoryType._();
  static const services = ServicesCategoryType._();

  static const List<CategoryDefineType> values = [
    commodities,
    rawMaterials,
    services,
  ];

  static CategoryDefineType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown CategoryType: $name'),
    );
  }
}

final class CommoditiesCategoryType extends CategoryDefineType {
  const CommoditiesCategoryType._();

  @override
  String get name => 'commodities';

  @override
  int get index => 0;

  @override
  String displayName() => 'بضائع';
}

final class RawMaterialsCategoryType extends CategoryDefineType {
  const RawMaterialsCategoryType._();

  @override
  String get name => 'raw_materials';

  @override
  int get index => 1;

  @override
  String displayName() => 'مواد خام';
}

final class ServicesCategoryType extends CategoryDefineType {
  const ServicesCategoryType._();

  @override
  String get name => 'services';

  @override
  int get index => 2;

  @override
  String displayName() => 'خدمات';
}
