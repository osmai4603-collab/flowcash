import 'dart:io';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_state.dart';
import 'package:flowcash/features/categories/presentation/pages/categories/category_form_page.dart';
import 'package:flowcash/core/constants/app_route_keys.dart';
import 'package:go_router/go_router.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final searchBarController = TextEditingController();

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesBloc>().add(LoadCategoriesEvent());
    });
  }

  Map<int, TableColumnWidth> getWidths() {
    return {
      0: FixedColumnWidth(isDesktop ? 45.0 : 40.0),
      1: FixedColumnWidth(isDesktop ? 70 : 55),
      2: const FlexColumnWidth(0.70),
      3: FixedColumnWidth(isDesktop ? 70 : 55),
      4: FixedColumnWidth(isDesktop ? 100 : 80),
      5: const FlexColumnWidth(0.30),
    };
  }

  Widget listView(List<CategoryEntity> categories) {
    final textTheme = TextTheme.of(context);
    final colors = ColorScheme.of(context);
    return Column(
      children: [
        Table(
          border: TableBorder.all(width: 0.50, color: colors.outline),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: getWidths(),
          children: [
            TableRow(
              children: [
                TextWidget(
                  text: 'No',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  padding: const EdgeInsets.all(4),
                  style: textTheme.bodyMedium,
                ),
                TextWidget(
                  text: 'الرقم',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(4),
                  style: textTheme.bodyMedium,
                ),
                TextWidget(
                  text: 'الصنف',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(4),
                  style: textTheme.bodyMedium,
                ),
                TextWidget(
                  text: 'الوحدة',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(2),
                  style: textTheme.bodyMedium,
                ),
                TextWidget(
                  text: 'نوع تعريف الصنف',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(2),
                  style: textTheme.bodyMedium,
                ),
                TextWidget(
                  text: 'الباركود',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(4),
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: searchBarController,
            builder: (_, edit, child) {
              final filtered = searchBarController.text.isEmpty
                  ? categories
                  : categories
                        .where(
                          (category) => category.categoryName.contains(
                            searchBarController.text,
                          ),
                        )
                        .toList();
              return buildListView(filtered);
            },
          ),
        ),
      ],
    );
  }

  Widget buildListView(List<CategoryEntity> categories) {
    final textTheme = TextTheme.of(context);
    final colors = ColorScheme.of(context);
    if (categories.isEmpty) {
      return Container(
        alignment: Alignment.center,
        child: Text('لا يوجد اصناف موجودة', style: textTheme.bodyLarge),
      );
    }
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () => _onUpdateCategoryPressed(category),
          onLongPress: () => _onDeleteCategoryPressed(category),
          child: Table(
            border: TableBorder.all(width: 0.50, color: colors.outline),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: getWidths(),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? colors.primaryContainer : null,
                ),
                children: [
                  TextWidget(
                    text: '${index + 1}',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8.0,
                    ),
                    style: textTheme.labelMedium,
                  ),
                  TextWidget(
                    text: category.categoryNumber,
                    textAlign: TextAlign.center,
                    padding: const EdgeInsets.all(4),
                    style: textTheme.labelMedium,
                  ),
                  TextWidget(
                    text: category.categoryName,
                    padding: const EdgeInsets.all(4),
                    style: textTheme.labelMedium,
                  ),
                  TextWidget(
                    text: category.categoryUnit?.unitName ?? 'غير معرف',
                    textAlign: TextAlign.center,
                    padding: const EdgeInsets.all(2),
                    style: textTheme.labelMedium,
                  ),
                  TextWidget(
                    text: category.categoryType.displayName(),
                    textAlign: TextAlign.center,
                    padding: const EdgeInsets.all(2),
                    style: textTheme.labelMedium,
                  ),
                  TextWidget(
                    text: category.barcode ?? 'غير معرف',
                    textAlign: TextAlign.end,
                    textDirection: TextDirection.ltr,
                    padding: const EdgeInsets.all(4),
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    return BlocListener<CategoriesBloc, CategoriesState>(
      listener: (context, state) {
        if (state is CategoriesLoadFailure) {
          error(context: context, toast: state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(isDesktop ? 'الأصناف' : '')),
              SizedBox(
                height: 40.0,
                width: isDesktop ? 400.0 : 250.0,
                child: SearchBar(
                  elevation: const WidgetStatePropertyAll(0.0),
                  backgroundColor: WidgetStatePropertyAll(
                    colors.secondary.withValues(alpha: 0.25),
                  ),
                  controller: searchBarController,
                  leading: const Icon(
                    Icons.search_outlined,
                    color: Colors.white70,
                  ),
                  hintText: 'ابحث عن صنف هنا',
                  textStyle: isDesktop
                      ? WidgetStatePropertyAll(
                          textTheme.titleMedium?.copyWith(color: Colors.white),
                        )
                      : WidgetStatePropertyAll(
                          textTheme.titleSmall?.copyWith(color: Colors.white),
                        ),
                  shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
                ),
              ),
              const Expanded(child: SizedBox(height: 20)),
            ],
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(35),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocBuilder<CategoriesBloc, CategoriesState>(
                      builder: (context, state) {
                        final categories = state is CategoriesLoadSuccess
                            ? state.categories
                            : <CategoryEntity>[];
                        final filtered = searchBarController.text.isEmpty
                            ? categories
                            : categories
                                  .where(
                                    (category) =>
                                        category.categoryName.contains(
                                          searchBarController.text,
                                        ) ||
                                        category.categoryNumber.contains(
                                          searchBarController.text,
                                        ),
                                  )
                                  .toList();
                        return Tooltip(
                          message: 'عدد الأصناف',
                          child: TextWidget(
                            text: filtered.length.toString(),
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: 'الاصناف الرئيسية',
                      icon: Icon(
                        Icons.add_box_outlined,
                        size: 26,
                        color: colors.onPrimary,
                      ),
                      onPressed: () {
                        context.go(AppRouteKeys.mainCategories);
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: 'إعادة تحميل الأصناف',
                      icon: Icon(
                        Icons.refresh,
                        size: 26,
                        color: colors.onPrimary,
                      ),
                      onPressed: () => context.read<CategoriesBloc>().add(
                        LoadCategoriesEvent(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: 'اضافة صنف جديد',
                      color: colors.onPrimary,
                      icon: const Icon(
                        Icons.add,
                        size: 26,
                        color: Colors.white,
                      ),
                      onPressed: _onAddNewCategoryPressed,
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      tooltip: 'طباعة بيانات الأصناف',
                      color: colors.onPrimary,
                      icon: Icon(
                        Icons.print,
                        size: 26,
                        color: colors.onPrimary,
                      ),
                      onPressed: () async {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 1000,
            padding: const EdgeInsets.all(2),
            child: BlocBuilder<CategoriesBloc, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CategoriesLoadSuccess) {
                  return listView(state.categories);
                }
                return const Center(child: Text('لا يوجد اصناف موجودة'));
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onDeleteCategoryPressed(CategoryEntity category) async {
    BuildContext context() => this.context;
    final sure = await makeSure(
      title: 'عملية التحقق من الحذف',
      content: 'هل تريد حذف هذا الصنف ${category.categoryName}',
      context: context(),
    );
    if (sure && context().mounted) {
      context().read<CategoriesBloc>().add(DeleteCategoryEvent(category));
    }
  }

  void _onAddNewCategoryPressed() async {
    BuildContext context() => this.context;
    final category = await showDialog<CategoryEntity>(
      context: context(),
      builder: (_) => const CategoryFormPage(),
    );
    print('Category Inserted: $category');
    if (category != null && context().mounted) {
      context().read<CategoriesBloc>().add(InjectCategoryEvent(category));
      showSnackBar(context(), 'تمت إضافة الصنف بنجاح');
    }
  }

  void showSnackBar(BuildContext context, String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s), duration: const Duration(seconds: 2)),
    );
  }

  void _onUpdateCategoryPressed(CategoryEntity category) async {
    BuildContext context() => this.context;
    final updatedCategory = await showDialog<CategoryEntity>(
      context: context(),
      builder: (_) => CategoryFormPage(category: category),
    );
    if (updatedCategory != null && context().mounted) {
      context().read<CategoriesBloc>().add(
        InjectCategoryEvent(updatedCategory),
      );
    }
  }
}
