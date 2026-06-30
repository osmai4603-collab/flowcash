import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:equatable/equatable.dart';

enum MainCategoryFormStatus { initial, ready, saving, saved, failure }

class MainCategoryFormState extends Equatable {
  final MainCategoryFormStatus status;
  final int id;
  final String name;
  final int categoryUnitId;
  final CategoryDefineType type;
  final UnitEntity? selectedUnit;
  final String? messageError;

  const MainCategoryFormState({
    this.status = MainCategoryFormStatus.initial,
    this.id = 0,
    this.name = '',
    this.categoryUnitId = 1,
    this.type = CategoryDefineType.commodities,
    this.selectedUnit,
    this.messageError,
  });

  MainCategoryEntity toEntity({
    required List<CategoryPropertyEntity> properties,
  }) => MainCategoryEntity(
    id: id,
    name: name,
    type: type,
    properties: properties,
    categoryUnitId: selectedUnit?.id ?? categoryUnitId,
    categoryUnit: selectedUnit,
  );

  MainCategoryFormState copyWith({
    MainCategoryFormStatus? status,
    int? id,
    String? name,
    int? categoryUnitId,
    CategoryDefineType? type,
    UnitEntity? selectedUnit,
    String? messageError,
  }) {
    return MainCategoryFormState(
      status: status ?? this.status,
      id: id ?? this.id,
      name: name ?? this.name,
      categoryUnitId: categoryUnitId ?? this.categoryUnitId,
      type: type ?? this.type,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      messageError: messageError ?? this.messageError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    id,
    name,
    categoryUnitId,
    type,
    selectedUnit,
    messageError,
  ];
}
