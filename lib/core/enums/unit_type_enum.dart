import 'app_enum.dart';

sealed class UnitType extends AppEnum {
  final int serial;
  final String propertyData;
  final bool isVisible;
  final String unitName;
  final String fullUnitName;
  final String propertyName;
  final String typeName;
  final String symbolUnit;
  final bool isBasic;
  final bool isDefault;

  const UnitType({
    required this.typeName,
    required this.propertyName,
    required this.propertyData,
    this.serial = 0,
    this.unitName = '',
    this.fullUnitName = '',
    required this.symbolUnit,
    this.isVisible = true,
    this.isBasic = false,
    this.isDefault = false,
  });

  static const model = ModelUnitType._();
  static const piece = PieceUnitType._();
  static const weight = WeightUnitType._();
  static const linearMeter = LinearMeterUnitType._();
  static const squareMeter = SquareMeterUnitType._();
  static const squareMeterStatic = SquareMeterStaticUnitType._();
  static const squareMeterWidthStatic = SquareMeterWidthStaticUnitType._();
  static const cubitMeter = CubitMeterUnitType._();
  static const mainCategory = MainCategoryUnitType._();
  static const subCategory = SubCategoryUnitType._();
  static const modelColor = ModelColorUnitType._();

  static const List<UnitType> values = [
    model,
    piece,
    weight,
    linearMeter,
    squareMeter,
    squareMeterStatic,
    squareMeterWidthStatic,
    cubitMeter,
    mainCategory,
    subCategory,
    modelColor,
  ];

  static UnitType of(String name) {
    return values.firstWhere((e) => e.name == name, orElse: () => piece);
  }

  @override
  String displayName() => unitName;

  bool get isPiece => false;
  bool get isText => false;
  bool get isSquareMeter => false;
  bool get isSquareMeterStatic => false;
  bool get isSquareMeterWidthStatic => false;
  bool get isCubitMeter => false;
  bool get isLinearMeter => false;
  bool get isWeight => false;
  bool get isMainCategory => false;
  bool get isSubCategory => false;
  bool get isModelColor => false;
  bool get isMeasurable => isWeight || isMeterMeasurable;
  bool get hasSquareMeter =>
      isSquareMeter || isSquareMeterStatic || isSquareMeterWidthStatic;
  bool get isMeterMeasurable =>
      hasSquareMeter ||
      isLinearMeter ||
      isCubitMeter ||
      isSquareMeterWidthStatic;
  bool get canWriteUnitOnCategory => isMeterMeasurable || isText || isWeight || isMainCategory || isSubCategory || isModelColor;
}

final class ModelUnitType extends UnitType {
  const ModelUnitType._()
    : super(
        typeName: '',
        propertyName: '',
        propertyData: 'موديل',
        serial: 8,
        unitName: '',
        fullUnitName: '',
        symbolUnit: '',
      );

  @override
  String get name => 'model';

  @override
  int get index => 0;

  @override
  bool get isText => true;
}

final class PieceUnitType extends UnitType {
  const PieceUnitType._()
    : super(
        typeName: 'حبة',
        propertyName: 'وحدة',
        propertyData: 'عدد قطع',
        serial: 1,
        unitName: 'حبة',
        fullUnitName: 'حبة',
        symbolUnit: 'حبة',
        isVisible: true,
        isBasic: true,
        isDefault: true,
      );

  @override
  String get name => 'piece';

  @override
  int get index => 1;

  @override
  bool get isPiece => true;
}

final class WeightUnitType extends UnitType {
  const WeightUnitType._()
    : super(
        typeName: 'وزن',
        propertyName: 'وزن',
        propertyData: 'وزن',
        serial: 3,
        unitName: 'كيلو',
        fullUnitName: 'كيلو جرام',
        symbolUnit: 'كجم',
        isBasic: true,
      );

  @override
  String get name => 'weight';

  @override
  int get index => 2;
  @override
  bool get isWeight => true;
}

final class LinearMeterUnitType extends UnitType {
  const LinearMeterUnitType._()
    : super(
        typeName: 'متر طولي',
        propertyName: 'طول',
        propertyData: 'متر طولي',
        serial: 4,
        unitName: 'متر',
        fullUnitName: 'متر طولي',
        symbolUnit: 'م',
        isBasic: true,
      );

  @override
  String get name => 'linear_meter';

  @override
  int get index => 3;
  @override
  bool get isLinearMeter => true;
}

final class SquareMeterUnitType extends UnitType {
  const SquareMeterUnitType._()
    : super(
        typeName: 'متر مربع',
        propertyName: 'مقاس',
        propertyData: 'متر مربع (طول x عرض)',
        serial: 5,
        unitName: 'متر مربع',
        fullUnitName: 'متر مربع',
        symbolUnit: 'م²',
        isBasic: true,
      );

  @override
  String get name => 'square_meter';

  @override
  int get index => 4;
  @override
  bool get isSquareMeter => true;
}

final class SquareMeterStaticUnitType extends UnitType {
  const SquareMeterStaticUnitType._()
    : super(
        typeName: 'متر مربع',
        propertyName: 'مقاس',
        propertyData: 'حبة (طول x عرض) ثابت',
        serial: 5,
        unitName: 'متر مربع',
        fullUnitName: 'متر مربع (ثابث)',
        symbolUnit: 'م²',
      );

  @override
  String get name => 'square_meter_static';

  @override
  int get index => 5;
  @override
  bool get isSquareMeterStatic => true;
}

final class SquareMeterWidthStaticUnitType extends UnitType {
  const SquareMeterWidthStaticUnitType._()
    : super(
        typeName: 'متر',
        propertyName: 'مقاس',
        propertyData: 'حبة (طول x عرض ثابت)',
        serial: 5,
        unitName: 'متر مربع',
        fullUnitName: 'متر مربع (عرض)',
        symbolUnit: 'م²',
      );

  @override
  String get name => 'square_meter_width_static';

  @override
  int get index => 6;
  @override
  bool get isSquareMeterWidthStatic => true;
}

final class CubitMeterUnitType extends UnitType {
  const CubitMeterUnitType._()
    : super(
        typeName: 'متر مكعب',
        propertyName: 'مقاس',
        propertyData: 'متر مكعب (طول x عرض x سمك) ثابت',
        serial: 5,
        unitName: 'متر مكعب',
        fullUnitName: 'متر مكعب',
        symbolUnit: 'م³',
        isBasic: true,
      );

  @override
  String get name => 'cubit_meter';

  @override
  int get index => 7;
  @override
  bool get isCubitMeter => true;
}

final class MainCategoryUnitType extends UnitType {
  const MainCategoryUnitType._()
    : super(
        typeName: 'نوع صنف رئيسي',
        propertyName: 'صنف رئيسي',
        propertyData: 'نوع صنف رئيسي',
        serial: 9,
        unitName: 'صنف رئيسي',
        fullUnitName: 'صنف رئيسي',
        symbolUnit: 'صنف رئيسي',
      );

  @override
  String get name => 'main_category';

  @override
  int get index => 8;

  @override
  bool get isMainCategory => true;

  @override
  bool get isText => true;
}

final class SubCategoryUnitType extends UnitType {
  const SubCategoryUnitType._()
    : super(
        typeName: 'نوع صنف فرعي',
        propertyName: 'صنف فرعي',
        propertyData: 'نوع صنف فرعي',
        serial: 10,
        unitName: 'صنف فرعي',
        fullUnitName: 'صنف فرعي',
        symbolUnit: 'صنف فرعي',
      );

  @override
  String get name => 'sub_category';

  @override
  int get index => 9;

  @override
  bool get isSubCategory => true;

  @override
  bool get isText => true;
}

final class ModelColorUnitType extends UnitType {
  const ModelColorUnitType._()
    : super(
        typeName: 'لون الموديل',
        propertyName: 'لون الموديل',
        propertyData: 'لون الموديل',
        serial: 11,
        unitName: 'لون الموديل',
        fullUnitName: 'لون الموديل',
        symbolUnit: 'لون الموديل',
      );

  @override
  String get name => 'model_color';

  @override
  int get index => 10;

  @override
  bool get isModelColor => true;

  @override
  bool get isText => true;
}
