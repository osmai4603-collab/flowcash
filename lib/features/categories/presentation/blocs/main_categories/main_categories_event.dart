import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';

abstract class MainCategoriesEvent {}

class LoadMainCategoriesEvent extends MainCategoriesEvent {}

class RefreshMainCategoriesEvent extends MainCategoriesEvent {}

class AddMainCategoryEvent extends MainCategoriesEvent {
  final MainCategoryEntity category;
  AddMainCategoryEvent(this.category);
}

class DeleteMainCategoryEvent extends MainCategoriesEvent {
  final int id;
  DeleteMainCategoryEvent(this.id);
}

class SearchMainCategoriesEvent extends MainCategoriesEvent {
  final String query;
  SearchMainCategoriesEvent(this.query);
}

class OpenSubcategoriesEvent extends MainCategoriesEvent {}

class OpenMainCategoryUnitFormEvent extends MainCategoriesEvent {
  final int mainCategoryId;
  OpenMainCategoryUnitFormEvent(this.mainCategoryId);
}
