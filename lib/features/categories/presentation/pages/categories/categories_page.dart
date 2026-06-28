import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_state.dart';
import 'package:flowcash/features/categories/presentation/pages/categories/category_form_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flowcash/widgets/message.dart';

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
      0: const FlexColumnWidth(0.06), // No
      1: const FlexColumnWidth(0.08), // الرقم
      2: const FlexColumnWidth(0.40), // الصنف
      3: const FlexColumnWidth(0.14), // الصنف الفرعي
      4: const FlexColumnWidth(0.10), // الوحدة
      5: const FlexColumnWidth(0.10), // نوع تعريف الصنف
      6: const FlexColumnWidth(0.12), // الباركود
    };
  }

  Widget _buildCell(String text, AppStyle style, Alignment alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(6.0),
      child: fluent.Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: style.body,
      ),
    );
  }

  Widget listView(List<CategoryEntity> categories) {
    final style = AppStyle.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: searchBarController,
      builder: (_, edit, child) {
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

        if (filtered.isEmpty) {
          return Center(
            child: fluent.Text('لا يوجد اصناف موجودة', style: style.bodyLarge),
          );
        }

        return Column(
          mainAxisAlignment: .start,
          crossAxisAlignment: .stretch,
          children: [
            Table(
              columnWidths: getWidths(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: TableBorder(
                top: BorderSide(color: style.outlineVariant, width: 0.5),
                left: BorderSide(color: style.outlineVariant, width: 0.5),
                right: BorderSide(color: style.outlineVariant, width: 0.5),
                bottom: BorderSide(color: style.outlineVariant, width: 0.5),
                verticalInside: BorderSide(
                  color: style.outlineVariant,
                  width: 0.5,
                ),
              ),
              children: [
                TableRow(
                  children: [
                    _buildHeaderCell('No', style),
                    _buildHeaderCell('الرقم', style),
                    _buildHeaderCell('الصنف', style),
                    _buildHeaderCell('الصنف الفرعي', style),
                    _buildHeaderCell('الوحدة', style),
                    _buildHeaderCell('نوع الصنف', style),
                    _buildHeaderCell('الباركود', style),
                  ],
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final category = filtered[index];
                  return fluent.HoverButton(
                    onPressed: () => _onUpdateCategoryPressed(category),
                    builder: (context, states) {
                      final isHovered = states.contains(
                        fluent.WidgetState.hovered,
                      );
                      return GestureDetector(
                        onLongPress: () => _onDeleteCategoryPressed(category),
                        child: Table(
                          columnWidths: getWidths(),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          border: TableBorder(
                            left: BorderSide(
                              color: style.outlineVariant,
                              width: 0.5,
                            ),
                            right: BorderSide(
                              color: style.outlineVariant,
                              width: 0.5,
                            ),
                            bottom: BorderSide(
                              color: style.outlineVariant,
                              width: 0.5,
                            ),
                            verticalInside: BorderSide(
                              color: style.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? style.surfaceContainerHighest.withValues(
                                        alpha: 0.24,
                                      )
                                    : (index.isEven
                                          ? null
                                          : style.surfaceContainerHighest
                                                .withValues(alpha: 0.12)),
                              ),
                              children: [
                                _buildCell(
                                  '${index + 1}',
                                  style,
                                  Alignment.center,
                                ),
                                _buildCell(
                                  category.categoryNumber,
                                  style,
                                  Alignment.centerRight,
                                ),
                                _buildCell(
                                  category.categoryName,
                                  style,
                                  Alignment.centerRight,
                                ),
                                _buildCell(
                                  category.subcategory?.catalogName ??
                                      'بدون صنف فرعي',
                                  style,
                                  Alignment.centerRight,
                                ),
                                _buildCell(
                                  category.categoryUnit?.unitName ?? 'غير معرف',
                                  style,
                                  Alignment.center,
                                ),
                                _buildCell(
                                  category.categoryType.displayName(),
                                  style,
                                  Alignment.center,
                                ),
                                _buildCell(
                                  category.barcode ?? 'غير معرف',
                                  style,
                                  Alignment.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCell(String text, AppStyle style) {
    return fluent.Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(4),
      decoration: fluent.BoxDecoration(color: style.surfaceContainerHighest),
      child: fluent.Text(
        text,
        textAlign: TextAlign.center,
        style: style.bodyStrong,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoriesBloc, CategoriesState>(
      listener: (context, state) {
        if (state is CategoriesLoadFailure) {
          error(context: context, toast: state.message);
        }
      },
      child: fluent.ScaffoldPage(
        header: fluent.PageHeader(
          title: Row(
            crossAxisAlignment: .start,
            spacing: Spacings.medium,
            mainAxisAlignment: .spaceBetween,
            children: [
              Expanded(child: const fluent.Text('الأصناف')),
              SizedBox(
                width: isDesktop ? 400.0 : 250.0,
                child: BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    return fluent.TextBox(
                      prefix: Padding(
                        padding: Paddings.smallAll,
                        child: fluent.Icon(
                          fluent.FluentIcons.search,
                          color: AppStyle.of(context).onSurfaceVariant,
                        ),
                      ),
                      placeholder: 'ابحث عن نوع صنف هنا',
                      onChanged: (value) {
                        searchBarController.text = value;
                      },
                    );
                  },
                ),
              ),
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
                  return Text(
                    filtered.length.toString(),
                    style: AppStyle.of(context).subTitle,
                  );
                },
              ),
              fluent.Tooltip(
                message: 'إعادة تحميل الأصناف',
                child: fluent.IconButton(
                  icon: fluent.Icon(fluent.FluentIcons.refresh),
                  onPressed: () =>
                      context.read<CategoriesBloc>().add(LoadCategoriesEvent()),
                ),
              ),
              fluent.Tooltip(
                message: 'طباعة بيانات الأصناف',
                child: fluent.IconButton(
                  icon: fluent.Icon(fluent.FluentIcons.print),
                  onPressed: () async {},
                ),
              ),
              fluent.FilledButton(
                onPressed: _onAddNewCategoryPressed,
                child: Row(
                  children: [
                    const fluent.Icon(fluent.FluentIcons.add),
                    fluent.Text('اضافة صنف جديد'),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: BlocBuilder<CategoriesBloc, CategoriesState>(
                  builder: (context, state) {
                    if (state is CategoriesLoadInProgress) {
                      return const Center(child: fluent.ProgressRing());
                    }
                    if (state is CategoriesLoadSuccess) {
                      return listView(state.categories);
                    }
                    return const Center(
                      child: fluent.Text('لا يوجد اصناف موجودة'),
                    );
                  },
                ),
              ),
            ),
          ],
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
    if (kDebugMode) {
      print('Category Inserted: $category');
    }
    if (category != null && context().mounted) {
      context().read<CategoriesBloc>().add(LoadCategoriesEvent());
      showSnackBar(context(), 'تمت إضافة الصنف بنجاح');
    }
  }

  void showSnackBar(BuildContext context, String s) {
    fluent.displayInfoBar(
      context,
      builder: (context, close) => fluent.InfoBar(
        title: const fluent.Text('تنبيه'),
        content: fluent.Text(s),
      ),
    );
  }

  void _onUpdateCategoryPressed(CategoryEntity category) async {
    BuildContext context() => this.context;
    final updatedCategory = await showDialog<CategoryEntity>(
      context: context(),
      builder: (_) => CategoryFormPage(category: category),
    );
    if (updatedCategory != null && context().mounted) {
      context().read<CategoriesBloc>().add(LoadCategoriesEvent());
    }
  }
}
