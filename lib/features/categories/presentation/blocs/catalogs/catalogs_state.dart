import 'package:equatable/equatable.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';

enum SubcategoriesStatus { initial, loading, loaded, error }

class SubcategoriesState extends Equatable {
  final SubcategoriesStatus status;
  final List<SubcategoryEntity> catalogs;
  final List<SubcategoryUnitEntity> infos;
  final List<CategoryPropertyEntity> properties;
  final String searchQuery;
  final String? errorMessage;
  final String? statusMessage;

  const SubcategoriesState({
    this.status = SubcategoriesStatus.initial,
    this.catalogs = const [],
    this.infos = const [],
    this.properties = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.statusMessage,
  });

  SubcategoriesState copyWith({
    SubcategoriesStatus? status,
    List<SubcategoryEntity>? catalogs,
    List<SubcategoryUnitEntity>? infos,
    List<CategoryPropertyEntity>? properties,
    String? searchQuery,
    String? errorMessage,
    String? statusMessage,
  }) {
    return SubcategoriesState(
      status: status ?? this.status,
      catalogs: catalogs ?? this.catalogs,
      infos: infos ?? this.infos,
      properties: properties ?? this.properties,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    catalogs,
    infos,
    properties,
    searchQuery,
    errorMessage,
    statusMessage,
  ];
}
