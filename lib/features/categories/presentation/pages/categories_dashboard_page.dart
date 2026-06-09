import 'dart:io';

import 'package:flowcash/features/categories/presentation/pages/categories/categories_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/main_category_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/subcategory_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_state.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_state.dart';
import 'package:flowcash/features/categories/presentation/pages/subcategories/subcategories_page.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class CategoriesDashboard extends StatefulWidget {
  const CategoriesDashboard({super.key});

  @override
  State<CategoriesDashboard> createState() => _CategoriesDashboardState();
}

class _CategoriesDashboardState extends State<CategoriesDashboard> {
  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesBloc>().add(LoadCategoriesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CategoriesPage();
  }
}

class CategoriesDashboardCategoriesTab extends StatefulWidget {
  const CategoriesDashboardCategoriesTab({super.key});

  @override
  State<CategoriesDashboardCategoriesTab> createState() =>
      _CategoriesDashboardCategoriesTabState();
}

class _CategoriesDashboardCategoriesTabState
    extends State<CategoriesDashboardCategoriesTab> {
  final searchController = TextEditingController();
  String _searchQuery = '';

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              prefixIcon: fluent.Icon(fluent.FluentIcons.search),
              hintText: 'ابحث عن صنف هنا',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<CategoriesBloc, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoadInProgress) {
                  return const Center(child: fluent.ProgressRing());
                }
                if (state is CategoriesLoadFailure) {
                  return Center(child: TextWidget(text: state.message));
                }
                if (state is CategoriesLoadSuccess) {
                  final categories = state.categories;
                  final filtered = _searchQuery.isEmpty
                      ? categories
                      : categories
                            .where(
                              (category) =>
                                  category.categoryName.contains(
                                    _searchQuery,
                                  ) ||
                                  category.categoryNumber.contains(
                                    _searchQuery,
                                  ) ||
                                  (category.barcode?.contains(_searchQuery) ??
                                      false),
                            )
                            .toList();
                  return _buildCategoriesList(context, filtered);
                }
                return const Center(child: fluent.ProgressRing());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    List<CategoryEntity> categories,
  ) {
    if (categories.isEmpty) {
      return const Center(child: TextWidget(text: 'لا يوجد أصناف مطابقة'));
    }
    final colors = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;

    final dataSource = _CategoryDataSource(categories, textTheme);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: SfDataGrid(
        source: dataSource,
        columnWidthMode: ColumnWidthMode.fill,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        selectionMode: SelectionMode.single,
        navigationMode: GridNavigationMode.cell,
        columns: [
          GridColumn(
            columnName: 'no',
            width: 40.0,
            label: _buildHeaderCell('No', textTheme, colors),
          ),
          GridColumn(
            columnName: 'number',
            width: 90.0,
            label: _buildHeaderCell('الرقم', textTheme, colors),
          ),
          GridColumn(
            columnName: 'name',
            label: _buildHeaderCell('الصنف', textTheme, colors),
          ),
          GridColumn(
            columnName: 'unit',
            width: 90.0,
            label: _buildHeaderCell('الوحدة', textTheme, colors),
          ),
          GridColumn(
            columnName: 'type',
            width: 120.0,
            label: _buildHeaderCell('نوع التعريف', textTheme, colors),
          ),
          GridColumn(
            columnName: 'barcode',
            width: 90.0,
            label: _buildHeaderCell('الباركود', textTheme, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    String text,
    TextTheme textTheme,
    ColorScheme colors,
  ) {
    return Container(
      color: colors.primaryContainer,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: fluent.Text(
        text,
        textAlign: TextAlign.center,
        style: textTheme.labelMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CategoryDataSource extends DataGridSource {
  _CategoryDataSource(List<CategoryEntity> categories, this.textTheme) {
    _dataGridRows = List.generate(categories.length, (index) {
      final category = categories[index];
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'no', value: '${index + 1}'),
          DataGridCell<String>(
            columnName: 'number',
            value: category.categoryNumber,
          ),
          DataGridCell<String>(
            columnName: 'name',
            value: category.categoryName,
          ),
          DataGridCell<String>(
            columnName: 'unit',
            value: category.categoryUnit?.unitName ?? 'غير معرف',
          ),
          DataGridCell<String>(
            columnName: 'type',
            value: category.categoryType.displayName(),
          ),
          DataGridCell<String>(
            columnName: 'barcode',
            value: category.barcode ?? 'غير معرف',
          ),
        ],
      );
    });
  }

  final TextTheme textTheme;
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        final val = dataGridCell.value?.toString() ?? '';
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: fluent.Text(val, style: textTheme.bodyMedium),
        );
      }).toList(),
    );
  }
}

class CategoriesDashboardSubcategoriesTab extends StatefulWidget {
  const CategoriesDashboardSubcategoriesTab({super.key});

  @override
  State<CategoriesDashboardSubcategoriesTab> createState() =>
      _CategoriesDashboardSubcategoriesTabState();
}

class _CategoriesDashboardSubcategoriesTabState
    extends State<CategoriesDashboardSubcategoriesTab> {
  late Future<_SubcategoriesTabData> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchSubcategories();
  }

  Future<_SubcategoriesTabData> _fetchSubcategories() async {
    final subcategoriesResult = await sl<GetAllSubcategoriesUseCase>()();
    if (subcategoriesResult.isLeft()) {
      final failureMessage = subcategoriesResult.fold(
        (failure) => failure.message,
        (_) => 'فشل تحميل الأصناف الفرعية',
      );
      return _SubcategoriesTabData.failure(failureMessage);
    }

    final mainCategoriesResult = await sl<GetAllMainCategoriesUseCase>()();
    final mainCategoryMap = <int, String>{};
    if (mainCategoriesResult.isRight()) {
      for (final MainCategoryEntity mainCategory
          in mainCategoriesResult.getOrElse((_) => const [])) {
        mainCategoryMap[mainCategory.id] = mainCategory.name;
      }
    }

    return _SubcategoriesTabData.success(
      subcategoriesResult.getOrElse((_) => const []),
      mainCategoryMap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SubcategoriesTabData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: fluent.ProgressRing());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: TextWidget(text: 'حدث خطأ أثناء تحميل الأصناف الفرعية'),
          );
        }

        final data = snapshot.data!;
        if (data.failureMessage != null) {
          return Center(child: TextWidget(text: data.failureMessage!));
        }

        if (data.subcategories.isEmpty) {
          return const Center(child: TextWidget(text: 'لا يوجد أصناف فرعية'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: data.subcategories.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final subcategory = data.subcategories[index];
            final mainName =
                data.mainCategoryNames[subcategory.mainCategoryId] ??
                'غير معروف';
            return ListTile(
              title: fluent.Text(subcategory.catalogName),
              subtitle: fluent.Text('الصنف الرئيسي: $mainName'),
              trailing: fluent.Text(subcategory.catalogNumber ?? '-'),
            );
          },
        );
      },
    );
  }
}

class _SubcategoriesTabData {
  final List<SubcategoryEntity> subcategories;
  final Map<int, String> mainCategoryNames;
  final String? failureMessage;

  const _SubcategoriesTabData.success(
    this.subcategories,
    this.mainCategoryNames,
  ) : failureMessage = null;

  const _SubcategoriesTabData.failure(this.failureMessage)
    : subcategories = const [],
      mainCategoryNames = const {};
}

class CategoriesDashboardMainCategoriesTab extends StatefulWidget {
  const CategoriesDashboardMainCategoriesTab({super.key});

  @override
  State<CategoriesDashboardMainCategoriesTab> createState() =>
      _CategoriesDashboardMainCategoriesTabState();
}

class _CategoriesDashboardMainCategoriesTabState
    extends State<CategoriesDashboardMainCategoriesTab> {
  final searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainCategoriesBloc>(
      create: (_) => sl<MainCategoriesBloc>()..add(LoadMainCategoriesEvent()),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: fluent.Icon(fluent.FluentIcons.search),
                hintText: 'ابحث عن صنف رئيسي هنا',
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<MainCategoriesBloc, MainCategoriesState>(
                builder: (context, state) {
                  if (state is MainCategoriesLoadInProgress ||
                      state is MainCategoriesInitial) {
                    return const Center(child: fluent.ProgressRing());
                  }
                  if (state is MainCategoriesOperationFailure) {
                    return Center(
                      child: TextWidget(
                        text: state.message ?? 'فشل تحميل الأصناف الرئيسية',
                      ),
                    );
                  }
                  if (state is MainCategoriesLoadSuccess) {
                    final categories = _searchQuery.isEmpty
                        ? state.mainCategories
                        : state.mainCategories
                              .where(
                                (category) =>
                                    category.name.contains(_searchQuery),
                              )
                              .toList();
                    if (categories.isEmpty) {
                      return const Center(
                        child: TextWidget(text: 'لا يوجد أصناف رئيسية مطابقة'),
                      );
                    }
                    return ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          title: fluent.Text(category.name),
                          subtitle: fluent.Text(category.unitType.fullUnitName),
                          trailing: fluent.Text(category.type.displayName()),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SubcategoriesPage(),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(
                    child: TextWidget(text: 'لا يوجد بيانات'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoriesDashboardUnitsTab extends StatefulWidget {
  const CategoriesDashboardUnitsTab({super.key});

  @override
  State<CategoriesDashboardUnitsTab> createState() =>
      _CategoriesDashboardUnitsTabState();
}

class _CategoriesDashboardUnitsTabState
    extends State<CategoriesDashboardUnitsTab> {
  final searchController = TextEditingController();
  String _searchQuery = '';
  late Future<List<UnitEntity>> _unitsFuture;

  @override
  void initState() {
    super.initState();
    _unitsFuture = _loadUnits();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<UnitEntity>> _loadUnits() async {
    final unitsResult = await sl<GetUnitsUseCase>()();
    return unitsResult.getOrElse((_) => const []);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              prefixIcon: fluent.Icon(fluent.FluentIcons.search),
              hintText: 'ابحث عن وحدة هنا',
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<UnitEntity>>(
              future: _unitsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: fluent.ProgressRing());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: TextWidget(text: 'حدث خطأ أثناء تحميل الوحدات'),
                  );
                }
                final units = snapshot.data ?? const [];
                final filtered = _searchQuery.isEmpty
                    ? units
                    : units
                          .where((unit) => unit.unitName.contains(_searchQuery))
                          .toList();
                if (filtered.isEmpty) {
                  return const Center(
                    child: TextWidget(text: 'لا يوجد وحدات مطابقة'),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final unit = filtered[index];
                    return ListTile(
                      title: fluent.Text(unit.unitName),
                      subtitle: fluent.Text(unit.unitType.fullUnitName),
                      trailing: fluent.Text(
                        'أبعاد: ${unit.length}×${unit.width}×${unit.thickness}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
