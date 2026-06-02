import 'app_enum.dart';

sealed class MainCategoryType extends AppEnum {
  const MainCategoryType();

  static const standard = StandardMainCategoryType._();
  static const service = ServiceMainCategoryType._();

  static const List<MainCategoryType> values = [standard, service];

  static MainCategoryType of(String name) {
    return values.firstWhere(
      (e) => e.name == name,
      orElse: () => throw ArgumentError('Unknown MainCategoryType: $name'),
    );
  }
}

final class StandardMainCategoryType extends MainCategoryType {
  const StandardMainCategoryType._();

  @override
  String get name => 'standard';

  @override
  int get index => 0;

  @override
  String displayName() => 'قياسي';
}

final class ServiceMainCategoryType extends MainCategoryType {
  const ServiceMainCategoryType._();

  @override
  String get name => 'service';

  @override
  int get index => 1;

  @override
  String displayName() => 'Service';
}
