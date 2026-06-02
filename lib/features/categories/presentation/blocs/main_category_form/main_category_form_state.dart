import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:equatable/equatable.dart';

enum MainCategoryFormStatus { initial, ready, saving, saved, failure }

class MainCategoryFormState extends Equatable {
  final MainCategoryFormStatus status;
  final int id;
  final String name;
  final String unitName;
  final CategoryDefineType type;
  final List<CategoryPropertyEntity> properties;
  final UnitType unitType;

  final String? messageError;

  const MainCategoryFormState({
    this.status = MainCategoryFormStatus.initial,
    this.id = 0,
    this.name = '',
    this.unitName = '',
    this.type = CategoryDefineType.commodities,
    this.properties = const [],
    this.unitType = UnitType.piece,
    this.messageError,
  });

  MainCategoryEntity get entity => MainCategoryEntity(
    id: id,
    name: name,
    type: type,
    properties: properties,
    unitName: unitName,
    unitType: unitType,
  );

  MainCategoryFormState copyWith({
    MainCategoryFormStatus? status,
    int? id,
    String? name,
    String? unitName,
    CategoryDefineType? type,
    List<CategoryPropertyEntity>? properties,
    String? messageError,
    UnitType? unitType,
  }) {
    return MainCategoryFormState(
      status: status ?? this.status,
      id: id ?? this.id,
      name: name ?? this.name,
      unitName: unitName ?? this.unitName,
      type: type ?? this.type,
      properties: properties ?? this.properties,
      unitType: unitType ?? this.unitType,
      messageError: messageError ?? this.messageError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    id,
    name,
    unitName,
    type,
    properties,
    unitType,
    messageError,
  ];
}
