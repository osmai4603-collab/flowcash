import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

enum CategoriesStatus { initial, loading, success, failure }

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final List<CategoryEntity> categories;
  final String? message;

  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.message,
  });

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<CategoryEntity>? categories,
    String? message,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      message: message ?? this.message,
    );
  }

  CategoriesState injectCategory(CategoryEntity category) {
    final categories = List<CategoryEntity>.from(this.categories);
    final index = categories.indexWhere((item) => item.id == category.id);

    if (index > -1) {
      categories[index] = category;
    } else {
      categories.add(category);
    }

    categories.sort((a, b) => a.categoryName.compareTo(b.categoryName));

    return copyWith(categories: categories, message: null, status: CategoriesStatus.success);
  }

  @override
  List<Object?> get props => [status, categories, message];
}
