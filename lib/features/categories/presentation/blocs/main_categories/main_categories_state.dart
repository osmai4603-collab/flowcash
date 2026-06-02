import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';

abstract class MainCategoriesState {}

class MainCategoriesInitial extends MainCategoriesState {}

class MainCategoriesLoadInProgress extends MainCategoriesState {}

class MainCategoriesLoadSuccess extends MainCategoriesState {
  final List<MainCategoryEntity> mainCategories;
  MainCategoriesLoadSuccess(this.mainCategories);
}

class MainCategoriesOperationFailure extends MainCategoriesState {
  final String? message;
  MainCategoriesOperationFailure([this.message]);
}
