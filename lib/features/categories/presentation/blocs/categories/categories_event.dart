import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategoriesEvent extends CategoriesEvent {}

class InjectCategoryEvent extends CategoriesEvent {
  final CategoryEntity category;
  const InjectCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends CategoriesEvent {
  final CategoryEntity category;
  const DeleteCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}
