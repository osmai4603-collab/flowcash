import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CategoriesState extends Equatable {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();

  @override
  List<Object?> get props => [];
}

class CategoriesLoadInProgress extends CategoriesState {
  const CategoriesLoadInProgress();

  @override
  List<Object?> get props => [];
}

class CategoriesLoadSuccess extends CategoriesState {
  final List<CategoryEntity> categories;

  const CategoriesLoadSuccess({this.categories = const []});

  CategoriesLoadSuccess copyWith({List<CategoryEntity>? categories}) {
    return CategoriesLoadSuccess(categories: categories ?? this.categories);
  }

  @override
  List<Object?> get props => [categories];
}

class CategoriesLoadFailure extends CategoriesState {
  final String message;

  const CategoriesLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoriesController {
  final List<CategoryEntity> _categories;
  List<CategoryEntity> get categories => List.of(_categories);

  CategoriesController(this._categories);

  void replace(CategoryEntity category) {
    final index = _categories.indexWhere((item) => item.id == category.id);
    index > -1 ? _categories[index] = category : _categories.add(category);
    _categories.sort((a, b) => a.categoryName.compareTo(b.categoryName));
  }

  List<CategoryEntity> call() => _categories;

  void remove(CategoryEntity category) {
    _categories.removeWhere((item) => item.id == category.id);
  }
}
