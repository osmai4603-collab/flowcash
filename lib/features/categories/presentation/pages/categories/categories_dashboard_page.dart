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

import 'package:fluent_ui/fluent_ui.dart' as fluent;
class CategoriesDashboardPage extends StatefulWidget {
  const CategoriesDashboardPage({super.key});

  @override
  State<CategoriesDashboardPage> createState() => _CategoriesDashboardPageState();
}

class _CategoriesDashboardPageState extends State<CategoriesDashboardPage> {
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
    return CategoriesPage();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: fluent.Text(isDesktop ? 'لوحة إدارة التصنيفات' : 'التصنيفات'),
          centerTitle: true,
          bottom:  TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'الأصناف'),
              Tab(text: 'الأصناف الفرعية'),
              Tab(text: 'الأصناف الرئيسية'),
              Tab(text: 'الوحدات'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            CategoriesPage(),
            CategoriesDashboardSubcategoriesTab(),
            CategoriesDashboardMainCategoriesTab(),
            CategoriesDashboardUnitsTab(),
          ],
        ),
      ),
    );
  }
}

class CategoriesDashboardCategoriesTab extends StatefulWidget {
  const CategoriesDashboardCategoriesTab({super.key});

  @override
  State<CategoriesDashboardCategoriesTab> createState() => _CategoriesDashboardCategoriesTabState();
}

class _CategoriesDashboardCategoriesTabState extends State<CategoriesDashboardCategoriesTab> {
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
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              prefixIcon: Icon(fluent.FluentIcons.search),
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
                          .where((category) =>
                              category.categoryName.contains(_searchQuery) ||
                              category.categoryNumber.contains(_searchQuery) ||
                              (category.barcode?.contains(_searchQuery) ?? false))
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

  Widget _buildCategoriesList(BuildContext context, List<CategoryEntity> categories) {
    if (categories.isEmpty) {
      return const Center(child: TextWidget(text: 'لا يوجد أصناف مطابقة')); 
    }
    final colors = ColorScheme.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Table(
          border: TableBorder.all(width: 0.5, color: colors.outline),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FixedColumnWidth(40),
            1: FixedColumnWidth(90),
            2: FlexColumnWidth(),
            3: FixedColumnWidth(90),
            4: FixedColumnWidth(120),
            5: FixedColumnWidth(90),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: colors.primary.withAlpha((0.10 * 255).round())),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: fluent.Text('No', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: fluent.Text('الرقم', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: fluent.Text('الصنف', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: fluent.Text('الوحدة', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: fluent.Text('نوع التعريف', textAlign: TextAlign.center),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: fluent.Text('الباركود', textAlign: TextAlign.center),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Table(
                border: TableBorder.all(width: 0.5, color: colors.outline),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(40),
                  1: FixedColumnWidth(90),
                  2: FlexColumnWidth(),
                  3: FixedColumnWidth(90),
                  4: FixedColumnWidth(120),
                  5: FixedColumnWidth(90),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: index.isEven ? colors.primaryContainer : null,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: fluent.Text('${index + 1}', textAlign: TextAlign.center, style: textTheme.bodyMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: fluent.Text(category.categoryNumber, textAlign: TextAlign.center, style: textTheme.bodyMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: fluent.Text(category.categoryName, style: textTheme.bodyMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: fluent.Text(category.categoryUnit?.unitName ?? 'غير معرف', textAlign: TextAlign.center, style: textTheme.bodyMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: fluent.Text(category.categoryType.displayName(), textAlign: TextAlign.center, style: textTheme.bodyMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: fluent.Text(category.barcode ?? 'غير معرف', textAlign: TextAlign.center, style: textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoriesDashboardSubcategoriesTab extends StatefulWidget {
  const CategoriesDashboardSubcategoriesTab({super.key});

  @override
  State<CategoriesDashboardSubcategoriesTab> createState() => _CategoriesDashboardSubcategoriesTabState();
}

class _CategoriesDashboardSubcategoriesTabState extends State<CategoriesDashboardSubcategoriesTab> {
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
      for (final MainCategoryEntity mainCategory in mainCategoriesResult.getOrElse((_) => const [])) {
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
          return const Center(child: TextWidget(text: 'حدث خطأ أثناء تحميل الأصناف الفرعية'));
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
            final mainName = data.mainCategoryNames[subcategory.mainCategoryId] ?? 'غير معروف';
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

  const _SubcategoriesTabData.success(this.subcategories, this.mainCategoryNames)
      : failureMessage = null;

  const _SubcategoriesTabData.failure(this.failureMessage)
      : subcategories = const [],
        mainCategoryNames = const {};
}

class CategoriesDashboardMainCategoriesTab extends StatefulWidget {
  const CategoriesDashboardMainCategoriesTab({super.key});

  @override
  State<CategoriesDashboardMainCategoriesTab> createState() => _CategoriesDashboardMainCategoriesTabState();
}

class _CategoriesDashboardMainCategoriesTabState extends State<CategoriesDashboardMainCategoriesTab> {
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
                prefixIcon: Icon(fluent.FluentIcons.search),
                hintText: 'ابحث عن صنف رئيسي هنا',
                
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<MainCategoriesBloc, MainCategoriesState>(
                builder: (context, state) {
                  if (state is MainCategoriesLoadInProgress || state is MainCategoriesInitial) {
                    return const Center(child: fluent.ProgressRing());
                  }
                  if (state is MainCategoriesOperationFailure) {
                    return Center(child: TextWidget(text: state.message ?? 'فشل تحميل الأصناف الرئيسية'));
                  }
                  if (state is MainCategoriesLoadSuccess) {
                    final categories = _searchQuery.isEmpty
                        ? state.mainCategories
                        : state.mainCategories
                            .where((category) => category.name.contains(_searchQuery))
                            .toList();
                    if (categories.isEmpty) {
                      return const Center(child: TextWidget(text: 'لا يوجد أصناف رئيسية مطابقة'));
                    }
                    return ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
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
                                builder: (_) => SubcategoriesPage(mainCategory: category),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: TextWidget(text: 'لا يوجد بيانات')); 
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
  State<CategoriesDashboardUnitsTab> createState() => _CategoriesDashboardUnitsTabState();
}

class _CategoriesDashboardUnitsTabState extends State<CategoriesDashboardUnitsTab> {
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
              prefixIcon: Icon(fluent.FluentIcons.search),
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
                  return const Center(child: TextWidget(text: 'حدث خطأ أثناء تحميل الوحدات'));
                }
                final units = snapshot.data ?? const [];
                final filtered = _searchQuery.isEmpty
                    ? units
                    : units.where((unit) => unit.unitName.contains(_searchQuery)).toList();
                if (filtered.isEmpty) {
                  return const Center(child: TextWidget(text: 'لا يوجد وحدات مطابقة'));
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final unit = filtered[index];
                    return ListTile(
                      title: fluent.Text(unit.unitName),
                      subtitle: fluent.Text(unit.unitType.fullUnitName),
                      trailing: fluent.Text('أبعاد: ${unit.length}×${unit.width}×${unit.thickness}'),
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
