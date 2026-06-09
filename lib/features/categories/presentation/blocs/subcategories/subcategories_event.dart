import 'package:equatable/equatable.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';

abstract class SubcategoriesEvent extends Equatable {
  const SubcategoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubcategoriesEvent extends SubcategoriesEvent {
  final int? mainCategoryId;

  const LoadSubcategoriesEvent([this.mainCategoryId]);

  @override
  List<Object?> get props => [mainCategoryId];
}

class RefreshSubcategoriesEvent extends SubcategoriesEvent {
  final int? mainCategoryId;

  const RefreshSubcategoriesEvent([this.mainCategoryId]);

  @override
  List<Object?> get props => [mainCategoryId];
}

class SearchSubcategoriesEvent extends SubcategoriesEvent {
  final String query;

  const SearchSubcategoriesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddSubcategoryEvent extends SubcategoriesEvent {
  final SubcategoryEntity catalog;

  const AddSubcategoryEvent(this.catalog);

  @override
  List<Object?> get props => [catalog];
}

class DeleteSubcategoryEvent extends SubcategoriesEvent {
  final int catalogId;

  const DeleteSubcategoryEvent(this.catalogId);

  @override
  List<Object?> get props => [catalogId];
}

class GenerateSubcategoryCategoriesEvent extends SubcategoriesEvent {
  final int catalogId;

  const GenerateSubcategoryCategoriesEvent(this.catalogId);

  @override
  List<Object?> get props => [catalogId];
}

class ClearGeneratedCategoriesEvent extends SubcategoriesEvent {
  const ClearGeneratedCategoriesEvent();
}

class AddSubcategoryUnitEvent extends SubcategoriesEvent {
  final int catalogId;
  final int unitId;
  final int propertyId;

  const AddSubcategoryUnitEvent({
    required this.catalogId,
    required this.unitId,
    required this.propertyId,
  });

  @override
  List<Object?> get props => [catalogId, unitId, propertyId];
}

class DeleteSubcategoryUnitEvent extends SubcategoriesEvent {
  final int infoId;

  const DeleteSubcategoryUnitEvent(this.infoId);

  @override
  List<Object?> get props => [infoId];
}
