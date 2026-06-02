import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryFormEvent extends Equatable {
  const CategoryFormEvent();

  @override
  List<Object?> get props => [];
}

class InitCategoryForm extends CategoryFormEvent {
  final CategoryEntity? category;
  const InitCategoryForm([this.category]);

  @override
  List<Object?> get props => [category];
}

class SaveCategoryEvent extends CategoryFormEvent {
  const SaveCategoryEvent();

  @override
  List<Object?> get props => [];
}

class ChangeCategoryUnitEvent extends CategoryFormEvent {
  final UnitEntity unit;
  const ChangeCategoryUnitEvent(this.unit);

  @override
  List<Object?> get props => [unit];
}

class ChangeCategoryTypeEvent extends CategoryFormEvent {
  final CategoryDefineType categoryType;
  const ChangeCategoryTypeEvent(this.categoryType);

  @override
  List<Object?> get props => [categoryType];
}

class ChangeBarcodeEvent extends CategoryFormEvent {
  final String? barcode;
  const ChangeBarcodeEvent(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class ChangeCategoryNameEvent extends CategoryFormEvent {
  final String categoryName;
  const ChangeCategoryNameEvent(this.categoryName);

  @override
  List<Object?> get props => [categoryName];
}

class ChangeCategoryNumberEvent extends CategoryFormEvent {
  final String? categoryNumber;
  const ChangeCategoryNumberEvent(this.categoryNumber);

  @override
  List<Object?> get props => [categoryNumber];
}
