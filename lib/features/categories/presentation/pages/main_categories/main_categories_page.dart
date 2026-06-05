import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/presentation/pages/main_categories/main_category_form_page.dart';
import 'package:flowcash/features/categories/presentation/pages/units/main_category_unit_data_page.dart';
import 'package:flowcash/features/categories/presentation/pages/subcategories/subcategories_page.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_state.dart';

import 'package:fluent_ui/fluent_ui.dart' show CommandBar, CommandBarButton, FluentIcons, PageHeader, ProgressRing, ScaffoldPage, TextBox;
class MainCategoriesPage extends StatelessWidget {
  const MainCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MainCategoriesBloc>(
      create: (_) => sl<MainCategoriesBloc>()..add(LoadMainCategoriesEvent()),
      child: const _MainCategoriesView(),
    );
  }
}

class _MainCategoriesView extends StatefulWidget {
  const _MainCategoriesView();

  @override
  State<_MainCategoriesView> createState() => _MainCategoriesPageState();
}

class _MainCategoriesPageState extends State<_MainCategoriesView> {
  final searchBarController = TextEditingController();

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  Map<int, TableColumnWidth> getWidths() {
    return {
      0: const FlexColumnWidth(0.05),
      1: const FlexColumnWidth(0.30),
      2: const FlexColumnWidth(0.15),
      3: const FlexColumnWidth(0.15),
      4: const FlexColumnWidth(0.15),
      5: const FlexColumnWidth(0.15),
      6: const FlexColumnWidth(0.15),
    };
  }

  Widget buildColumn(
    BuildContext context,
    List<MainCategoryEntity> mainCategories,
  ) {
    final colors = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    if (mainCategories.isEmpty) {
      return const Center(
        child: TextWidget(text: 'لا يوجد اصاناف رئيسية معرفة'),
      );
    }
    return Column(
      children: [
        Table(
          border: TableBorder.all(width: 0.5, color: colors.outlineVariant),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: getWidths(),
          children: [
            TableRow(
              children: [
                TextWidget(
                  text: 'No',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                    padding: Paddings.xsmallAll,
                  style: textTheme.labelMedium,
                ),
                TextWidget(
                  text: 'اسم الصنف',
                  textAlign: TextAlign.center,
                    padding: Paddings.xsmallAll,
                  style: textTheme.labelMedium,
                ),
                TextWidget(
                  text: 'وحدة الصنف',
                  textAlign: TextAlign.center,
                    padding: Paddings.xsmallAll,
                  style: textTheme.labelMedium,
                ),
                TextWidget(
                  text: 'وحدة السعر',
                  textAlign: TextAlign.center,
                    padding: Paddings.xsmallAll,
                  style: textTheme.labelMedium,
                ),
                TextWidget(
                  text: 'وحدة الجرد',
                  textAlign: TextAlign.center,
                    padding: Paddings.xsmallAll,
                  style: textTheme.labelMedium,
                ),
                TextWidget(
                  text: 'نوع الصنف',
                  textAlign: TextAlign.center,
                    padding: Paddings.xsmallAll,
                  style: textTheme.labelMedium,
                ),
                TextWidget(
                  text: 'اسم الحاوية',
                  textAlign: TextAlign.center,
                    padding: Paddings.xsmallAll,
                  style: textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
        Expanded(child: listView(context, mainCategories)),
      ],
    );
  }

  Widget buildListViewOfTable(
    BuildContext context,
    List<MainCategoryEntity> categories,
  ) {
    if (categories.isEmpty) {
      return const Center(
        child: TextWidget(
          text: 'لا يوجد اصناف رئيسية موجود لهذا المدخل',
          alignment: Alignment.center,
        ),
      );
    }
    final colors = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (_, index) {
        final category = categories[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubcategoriesPage(mainCategory: category),
              ),
            );
          },
          onLongPress: () => _onCategoryLongPressed(context, category),
          onDoubleTap: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) => MainCategoryUnitDataPage(mainCategory: category),
            );
            if (result == true && context.mounted) {
              context.read<MainCategoriesBloc>().add(
                RefreshMainCategoriesEvent(),
              );
            }
          },
          child: Table(
            border: TableBorder.all(width: 0.5, color: colors.outlineVariant),
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
                    style: textTheme.labelMedium,
                  ),
                  TextWidget(
                    text: category.name,
                    padding: Paddings.xsmallAll,
                    style: textTheme.bodySmall,
                  ),
                  TextWidget(
                    text: category.unitName,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                  TextWidget(
                    text: category.unitType.fullUnitName,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                  TextWidget(
                    text: category.unitType.fullUnitName,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                  TextWidget(
                    text: category.type.displayName(),
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                  TextWidget(
                    text: category.unitName,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget listView(
    BuildContext context,
    List<MainCategoryEntity> mainCategories,
  ) {
    return ValueListenableBuilder(
      valueListenable: searchBarController,
      builder: (_, value, child) {
        final categories = searchBarController.text.isEmpty
            ? mainCategories
            : mainCategories
                  .where(
                    (category) =>
                        category.name.contains(searchBarController.text),
                  )
                  .toList();
        return buildListViewOfTable(context, categories);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('الأصناف الرئيسية'),
        commandBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 300,
              child: TextBox(
                controller: searchBarController,
                placeholder: 'ابحث عن صنف هنا...',
                prefix: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(FluentIcons.search),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            CommandBar(
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.add),
                  label: const Text('إضافة صنف رئيسي'),
                  onPressed: () async {
                    final mainCategory =
                        await showDialog<MainCategoryEntity?>(
                          context: context,
                          builder: (_) => const MainCategoryFormPage(),
                        );
                    if (mainCategory != null && context.mounted) {
                      context.read<MainCategoriesBloc>().add(
                        RefreshMainCategoriesEvent(),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      content: BlocListener<MainCategoriesBloc, MainCategoriesState>(
        listener: (context, state) {
          if (state is MainCategoriesOperationFailure) {
            error(context: context, toast: state.message ?? 'حدث خطأ');
          }
          if (state is MainCategoriesLoadSuccess) {
            // optionally show success toast on operations
          }
        },
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 800,
            child: BlocBuilder<MainCategoriesBloc, MainCategoriesState>(
              builder: (context, state) {
                if (state is MainCategoriesLoadInProgress ||
                    state is MainCategoriesInitial) {
                  return const Center(child: ProgressRing());
                }
                if (state is MainCategoriesLoadSuccess) {
                  return buildColumn(context, state.mainCategories);
                }
                if (state is MainCategoriesOperationFailure) {
                  return Center(child: Text(state.message ?? 'حدث خطأ'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onCategoryLongPressed(
    BuildContext context,
    MainCategoryEntity category,
  ) async {
    final sure = await makeSure(
      title: 'حذف صنف رئيسي',
      content: 'هل تريد حذف هذا الصنف ${category.name}',
      context: context,
    );
    if (!sure) return;
    if (context.mounted) {
      context.read<MainCategoriesBloc>().add(
        DeleteMainCategoryEvent(category.id),
      );
    }
  }
}
