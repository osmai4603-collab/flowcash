import 'package:equatable/equatable.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';

abstract class SubcategoriesState extends Equatable {
  const SubcategoriesState();

  List<SubcategoryEntity> get catalogs => const [];
  List<SubcategoryUnitEntity> get infos => const [];
  List<CategoryPropertyEntity> get properties => const [];
  String get searchQuery => '';
  String? get statusMessage => null;
  List<String>? get generatedCategoryNames => null;

  @override
  List<Object?> get props => [];
}

class SubcategoriesInitial extends SubcategoriesState {
  const SubcategoriesInitial();
}

class SubcategoriesLoadInProgress extends SubcategoriesState {
  const SubcategoriesLoadInProgress();
}

class SubcategoriesLoadSuccess extends SubcategoriesState {
  final SubcategoriesController controller;
  @override
  final String searchQuery;

  @override
  final String? statusMessage;

  @override
  final List<String>? generatedCategoryNames;

  const SubcategoriesLoadSuccess({
    required this.controller,
    this.searchQuery = '',
    this.statusMessage,
    this.generatedCategoryNames,
  });

  SubcategoriesLoadSuccess copyWith({
    SubcategoriesController? controller,
    String? searchQuery,
    String? statusMessage,
    Object? generatedCategoryNames = _generatedCategoryNamesSentinel,
  }) {
    return SubcategoriesLoadSuccess(
      controller: controller ?? this.controller,
      searchQuery: searchQuery ?? this.searchQuery,
      statusMessage: statusMessage ?? this.statusMessage,
      generatedCategoryNames:
          identical(generatedCategoryNames, _generatedCategoryNamesSentinel)
          ? this.generatedCategoryNames
          : generatedCategoryNames as List<String>?,
    );
  }

  @override
  List<SubcategoryEntity> get catalogs => controller.catalogs;

  @override
  List<SubcategoryUnitEntity> get infos => controller.infos;

  @override
  List<CategoryPropertyEntity> get properties => controller.properties;

  @override
  List<Object?> get props => [
    controller.catalogs,
    controller.infos,
    controller.properties,
    searchQuery,
    statusMessage,
    generatedCategoryNames,
  ];
}

class SubcategoriesLoadFailure extends SubcategoriesState {
  final String message;

  const SubcategoriesLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

const _generatedCategoryNamesSentinel = Object();

class SubcategoriesController {
  final List<SubcategoryEntity> _catalogs;
  final List<SubcategoryUnitEntity> _infos;
  final List<CategoryPropertyEntity> _properties;

  SubcategoriesController(this._catalogs, this._infos, this._properties);

  List<SubcategoryEntity> get catalogs => List.of(_catalogs);
  List<SubcategoryUnitEntity> get infos => List.of(_infos);
  List<CategoryPropertyEntity> get properties => List.of(_properties);

  void addSubcategory(SubcategoryEntity catalog) {
    _catalogs.add(catalog);
    _sortCatalogs();
  }

  void removeSubcategory(int catalogId) {
    _catalogs.removeWhere((catalog) => catalog.id == catalogId);
    _infos.removeWhere((info) => info.subcategoryId == catalogId);
  }

  void addSubcategoryUnit(SubcategoryUnitEntity info) {
    _infos.add(info);
  }

  void removeSubcategoryUnit(int infoId) {
    _infos.removeWhere((info) => info.id == infoId);
  }

  void _sortCatalogs() {
    _catalogs.sort((a, b) => a.catalogName.compareTo(b.catalogName));
  }
}
