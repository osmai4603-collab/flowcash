import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';

abstract class SubcategoriesEvent {}

class LoadSubcategoriesEvent extends SubcategoriesEvent {
  final int mainCategoryId;

  LoadSubcategoriesEvent(this.mainCategoryId);
}

class RefreshSubcategoriesEvent extends SubcategoriesEvent {
  final int mainCategoryId;

  RefreshSubcategoriesEvent(this.mainCategoryId);
}

class SearchSubcategoriesEvent extends SubcategoriesEvent {
  final String query;

  SearchSubcategoriesEvent(this.query);
}

class AddSubcategoryEvent extends SubcategoriesEvent {
  final SubcategoryEntity catalog;

  AddSubcategoryEvent(this.catalog);
}

class DeleteSubcategoryEvent extends SubcategoriesEvent {
  final int catalogId;

  DeleteSubcategoryEvent(this.catalogId);
}

class GenerateSubcategoryCategoriesEvent extends SubcategoriesEvent {
  final int catalogId;

  GenerateSubcategoryCategoriesEvent(this.catalogId);
}

class AddSubcategoryUnitEvent extends SubcategoriesEvent {
  final int catalogId;
  final int unitId;
  final int propertyId;

  AddSubcategoryUnitEvent({required this.catalogId, required this.unitId, required this.propertyId});
}

class DeleteSubcategoryUnitEvent extends SubcategoriesEvent {
  final int infoId;

  DeleteSubcategoryUnitEvent(this.infoId);
}
