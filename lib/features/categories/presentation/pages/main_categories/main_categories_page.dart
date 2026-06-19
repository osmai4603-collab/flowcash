import 'dart:io';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/presentation/pages/main_categories/main_category_form_page.dart';
import 'package:flowcash/features/categories/presentation/pages/units/main_category_unit_data_page.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_categories/main_categories_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flowcash/core/theme_fluent/app_colors.dart';

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

  Widget _buildHeaderCell(String text, AppStyle colors) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.surfaceContainerHigh),
      child: fluent.Text(
        text,
        textAlign: TextAlign.center,
        style: colors.body.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildColumn(
    BuildContext context,
    List<MainCategoryEntity> mainCategories,
  ) {
    final colors = AppStyle.of(context);
    if (mainCategories.isEmpty) {
      return const Center(
        child: TextWidget(text: 'لا يوجد اصاناف رئيسية معرفة'),
      );
    }
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant, width: 0.5),
        ),
        child: Table(
          columnWidths: getWidths(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(color: colors.outlineVariant, width: 0.5),
          children: [
            TableRow(
              children: [
                _buildHeaderCell('No', colors),
                _buildHeaderCell('اسم الصنف', colors),
                _buildHeaderCell('وحدة الصنف', colors),
                _buildHeaderCell('وحدة السعر', colors),
                _buildHeaderCell('وحدة الجرد', colors),
                _buildHeaderCell('نوع الصنف', colors),
                _buildHeaderCell('اسم الحاوية', colors),
              ],
            ),
            ...mainCategories.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return TableRow(
                decoration: BoxDecoration(
                  color: index.isEven
                      ? null
                      : colors.surfaceContainerHighest.withValues(alpha: 0.12),
                ),
                children: [
                  _buildCell('${index + 1}', colors, item),
                  _buildCell(item.name, colors, item),
                  _buildCell(item.unitName, colors, item),
                  _buildCell(item.unitType.fullUnitName, colors, item),
                  _buildCell(item.unitType.fullUnitName, colors, item),
                  _buildCell(item.type.displayName(), colors, item),
                  _buildCell(item.unitName, colors, item),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    String text,
    AppStyle colors,
    MainCategoryEntity category,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final result = await showDialog<MainCategoryEntity?>(
          context: context,
          builder: (_) => MainCategoryFormPage(id: category.id),
        );
        if (result != null && context.mounted) {
          context.read<MainCategoriesBloc>().add(
            RefreshMainCategoriesEvent(),
          );
        }
      },
      onDoubleTap: () async {
        final result = await showDialog<MainCategoryEntity?>(
          context: context,
          builder: (_) => MainCategoryUnitDataPage(mainCategory: category),
        );
        if (result != null && context.mounted) {
          context.read<MainCategoriesBloc>().add(
            RefreshMainCategoriesEvent(),
          );
        }
      },
      onLongPress: () => _onCategoryLongPressed(context, category),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(4.0),
        child: fluent.Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: colors.body,
        ),
      ),
    );
  }

  Widget buildListViewOfTable(
    BuildContext context,
    List<MainCategoryEntity> categories,
  ) {
    return const SizedBox.shrink();
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
        return buildColumn(context, categories);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    return fluent.ScaffoldPage(
      header: fluent.PageHeader(
        title: Row(
          spacing: Spacings.medium,
          children: [
            const Expanded(child: fluent.Text('الأصناف الرئيسية')),
            SizedBox(
              width: isDesktop ? 400.0 : 250.0,
              child: BlocBuilder<MainCategoriesBloc, MainCategoriesState>(
                builder: (context, state) {
                  return fluent.TextBox(
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: fluent.Icon(
                        fluent.FluentIcons.search,
                        color: colors.surfaceContainerHigh,
                      ),
                    ),
                    placeholder: 'ابحث عن نوع صنف هنا',
                    onChanged: (value) => context
                        .read<MainCategoriesBloc>()
                        .add(SearchMainCategoriesEvent(value)),
                  );
                },
              ),
            ),
            fluent.Tooltip(
              message: 'إعادة تحميل البيانات',
              child: fluent.IconButton(
                icon: const fluent.Icon(fluent.FluentIcons.refresh),
                onPressed: () => context.read<MainCategoriesBloc>().add(
                  RefreshMainCategoriesEvent(),
                ),
              ),
            ),
            fluent.FilledButton(
              child: Row(
                children: [
                  fluent.Icon(fluent.FluentIcons.add),
                  const fluent.Text('اضافة صنف رئيسي جديد'),
                ],
              ),
              onPressed: () => _onAddMainCategory(context),
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
        child: BlocBuilder<MainCategoriesBloc, MainCategoriesState>(
          builder: (context, state) {
            if (state is MainCategoriesLoadInProgress ||
                state is MainCategoriesInitial) {
              return const Center(child: fluent.ProgressRing());
            }
            if (state is MainCategoriesLoadSuccess) {
              return buildColumn(context, state.mainCategories);
            }
            if (state is MainCategoriesOperationFailure) {
              return Center(child: fluent.Text(state.message ?? 'حدث خطأ'));
            }
            return const SizedBox.shrink();
          },
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

  void _onAddMainCategory(BuildContext context) async {
    final mainCategory = await showDialog<MainCategoryEntity?>(
      context: context,
      builder: (_) => const MainCategoryFormPage(),
    );
    if (mainCategory != null && context.mounted) {
      context.read<MainCategoriesBloc>().add(RefreshMainCategoriesEvent());
    }
  }
}
