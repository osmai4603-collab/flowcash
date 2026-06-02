import 'package:equatable/equatable.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';

enum UnitFormStatus { initial, loading, ready, saving, saved, failure }

class UnitFormState extends Equatable {
  final UnitFormStatus status;
  final CategoryPropertyEntity? property;
  final UnitEntity? existingUnit;
  final MainCategoryEntity? category;
  final List<UnitEntity> units;
  final UnitEntity? saved;
  final String? messageError;

  final List<String> measuresUnits;
  final String measureUnitSelected;

  final double initialWeight;
  final double initialLength;
  final double initialWidth;
  final double initialThickness;
  final String initialName;

  const UnitFormState({
    this.status = UnitFormStatus.initial,
    this.property,
    this.existingUnit,
    this.category,
    this.units = const [],
    this.saved,
    this.messageError,
    this.measuresUnits = const [],
    this.measureUnitSelected = '',
    this.initialWeight = 0.0,
    this.initialLength = 0.0,
    this.initialWidth = 0.0,
    this.initialThickness = 1.0,
    this.initialName = '',
  });

  UnitFormState copyWith({
    UnitFormStatus? status,
    CategoryPropertyEntity? property,
    UnitEntity? existingUnit,
    MainCategoryEntity? category,
    List<UnitEntity>? units,
    UnitEntity? saved,
    String? messageError,
    List<String>? measuresUnits,
    String? measureUnitSelected,
    double? initialWeight,
    double? initialLength,
    double? initialWidth,
    double? initialThickness,
    String? initialName,
  }) {
    return UnitFormState(
      status: status ?? this.status,
      property: property ?? this.property,
      existingUnit: existingUnit ?? this.existingUnit,
      category: category ?? this.category,
      units: units ?? this.units,
      saved: saved ?? this.saved,
      messageError: messageError ?? this.messageError,
      measuresUnits: measuresUnits ?? this.measuresUnits,
      measureUnitSelected: measureUnitSelected ?? this.measureUnitSelected,
      initialWeight: initialWeight ?? this.initialWeight,
      initialLength: initialLength ?? this.initialLength,
      initialWidth: initialWidth ?? this.initialWidth,
      initialThickness: initialThickness ?? this.initialThickness,
      initialName: initialName ?? this.initialName,
    );
  }

  @override
  List<Object?> get props => [
        status,
        property,
        existingUnit,
        category,
        units,
        saved,
        messageError,
        measuresUnits,
        measureUnitSelected,
        initialWeight,
        initialLength,
        initialWidth,
        initialThickness,
        initialName,
      ];
}

