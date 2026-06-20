import 'package:equatable/equatable.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flutter/cupertino.dart';

enum CategoryFormStatus { initial, saving, saved, failure, ready }

class CategoryFormState extends Equatable {
  final int id;

  final CategoryFormStatus status;
  final List<UnitEntity> units;
  final UnitEntity? selectedUnit;
  final List<SubcategoryEntity> subcategories;
  final SubcategoryEntity? selectedSubcategory;
  final CategoryDefineType selectedCategoryType;
  final bool hasRequests;
  final String? messageError;
  final String categoryName;
  final String categoryNumber;
  final String? barcode;

  const CategoryFormState({
    this.id = 0,
    this.status = CategoryFormStatus.initial,
    this.units = const [],
    this.selectedUnit,
    this.subcategories = const [],
    this.selectedSubcategory,
    this.selectedCategoryType = CategoryDefineType.commodities,
    this.hasRequests = false,
    this.messageError,
    this.categoryName = '',
    this.categoryNumber = '',
    this.barcode,
  });

  CategoryFormState copyWith({
    int? id,
    CategoryFormStatus? status,
    CategoryEntity? initialCategory,
    List<UnitEntity>? units,
    UnitEntity? selectedUnit,
    List<SubcategoryEntity>? subcategories,
    SubcategoryEntity? selectedSubcategory,
    CategoryDefineType? selectedCategoryType,
    bool? hasRequests,
    String? messageError,
    String? categoryName,
    String? categoryNumber,
    String? barcode,
  }) {
    debugPrint(
      'CategoryFormState created with id: ${id ?? this.id}, status: ${status ?? this.status}, selectedUnit: ${selectedUnit?.unitName ?? this.selectedUnit?.unitName}, selectedCategoryType: ${selectedCategoryType?.name ?? this.selectedCategoryType}, hasRequests: ${hasRequests ?? this.hasRequests}, categoryName: ${categoryName ?? this.categoryName}, categoryNumber: ${categoryNumber ?? this.categoryNumber}, barcode: ${barcode ?? this.barcode}',
    );
    return CategoryFormState(
      id: id ?? this.id,
      status: status ?? this.status,
      units: units ?? this.units,
      categoryName: categoryName ?? this.categoryName,
      categoryNumber: categoryNumber ?? this.categoryNumber,
      barcode: barcode ?? this.barcode,
      selectedUnit: selectedUnit ?? this.selectedUnit,
      subcategories: subcategories ?? this.subcategories,
      selectedSubcategory: selectedSubcategory ?? this.selectedSubcategory,
      selectedCategoryType: selectedCategoryType ?? this.selectedCategoryType,
      hasRequests: hasRequests ?? this.hasRequests,
      messageError: messageError ?? this.messageError,
    );
  }

  CategoryFormState copyWithCategoryName({required String categoryName}) {
    return CategoryFormState(
      id: id,
      status: status,
      units: units,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode ?? barcode,
      selectedUnit: selectedUnit,
      subcategories: subcategories,
      selectedSubcategory: selectedSubcategory,
      selectedCategoryType: selectedCategoryType,
      hasRequests: hasRequests,
      messageError: messageError,
    );
  }

  CategoryFormState copyWithBarcode({required String? barcode}) {
    return CategoryFormState(
      id: id,
      status: status,
      units: units,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode ?? barcode,
      selectedUnit: selectedUnit,
      subcategories: subcategories,
      selectedSubcategory: selectedSubcategory,
      selectedCategoryType: selectedCategoryType,
      hasRequests: hasRequests,
      messageError: messageError,
    );
  }

  CategoryFormState copyWithCategoryNumber({required String categoryNumber}) {
    return CategoryFormState(
      id: id,
      status: status,
      units: units,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode ?? barcode,
      selectedUnit: selectedUnit,
      subcategories: subcategories,
      selectedSubcategory: selectedSubcategory,
      selectedCategoryType: selectedCategoryType,
      hasRequests: hasRequests,
      messageError: messageError,
    );
  }

  CategoryFormState copyWithStatus({required CategoryFormStatus status}) {
    return CategoryFormState(
      id: id,
      status: status,
      units: units,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode ?? barcode,
      selectedUnit: selectedUnit,
      subcategories: subcategories,
      selectedSubcategory: selectedSubcategory,
      selectedCategoryType: selectedCategoryType,
      hasRequests: hasRequests,
      messageError: messageError,
    );
  }

  CategoryFormState copyWithCategoryUnit({required UnitEntity unit}) {
    return CategoryFormState(
      id: id,
      status: status,
      units: units,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode ?? barcode,
      selectedUnit: unit,
      subcategories: subcategories,
      selectedSubcategory: selectedSubcategory,
      selectedCategoryType: selectedCategoryType,
      hasRequests: hasRequests,
      messageError: messageError,
    );
  }

  CategoryFormState copyWithSubcategory({required SubcategoryEntity? subcategory}) {
    return CategoryFormState(
      id: id,
      status: status,
      units: units,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode ?? barcode,
      selectedUnit: selectedUnit,
      subcategories: subcategories,
      selectedSubcategory: subcategory,
      selectedCategoryType: selectedCategoryType,
      hasRequests: hasRequests,
      messageError: messageError,
    );
  }

  CategoryFormState copyWithCategoryType({
    required CategoryDefineType categoryType,
  }) {
    return CategoryFormState(
      id: id,
      status: status,
      units: units,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode ?? barcode,
      selectedUnit: selectedUnit,
      subcategories: subcategories,
      selectedSubcategory: selectedSubcategory,
      selectedCategoryType: categoryType,
      hasRequests: hasRequests,
      messageError: messageError,
    );
  }

  CategoryFormState copyWithId({required int id}) {
    return CategoryFormState(
      id: id,
      status: status,
      units: units,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode ?? barcode,
      selectedUnit: selectedUnit,
      selectedCategoryType: selectedCategoryType,
      hasRequests: hasRequests,
      messageError: messageError,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryName,
    categoryNumber,
    barcode,
    status,
    selectedUnit,
    subcategories,
    selectedSubcategory,
    selectedCategoryType,
    hasRequests,
    messageError,
  ];

  CategoryEntity toEntity() {
    final entity = CategoryEntity(
      id: id,
      categoryType: selectedCategoryType,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode,
      categoryUnitId: selectedUnit?.id ?? 0,
      pricingUnitId: selectedUnit?.id ?? 0,
      inventoryUnitId: selectedUnit?.id ?? 0,
      subcategoryId: selectedSubcategory?.id,
      categoryUnit: selectedUnit,
      pricingUnit: selectedUnit,
      inventoryUnit: selectedUnit,
    );
    debugPrint(
      'Converted CategoryFormState to CategoryEntity: ${entity.toString()}',
    );

    return entity;
  }

  CategoryFormState copyWithError({required String messageError}) {
    return CategoryFormState(
      id: id,
      status: status,
      units: units,
      categoryName: categoryName,
      categoryNumber: categoryNumber,
      barcode: barcode ?? barcode,
      selectedUnit: selectedUnit,
      selectedCategoryType: selectedCategoryType,
      hasRequests: hasRequests,
      messageError: messageError,
    );
  }
}
