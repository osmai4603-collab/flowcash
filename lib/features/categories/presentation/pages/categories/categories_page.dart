import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
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

  Map<int, TableWidgetColumnWidth> getWidths() {
    return {
      0: const FlexTableWidgetColumnWidth(0.06, alignment: Alignment.centerRight), // No
      1: const FlexTableWidgetColumnWidth(0.08, alignment: Alignment.centerRight), // الرقم
      2: const FlexTableWidgetColumnWidth(0.40, alignment: Alignment.centerRight), // الصنف
      3: const FlexTableWidgetColumnWidth(0.14, alignment: Alignment.centerRight), // الصنف الفرعي
      4: const FlexTableWidgetColumnWidth(0.10, alignment: Alignment.center), // الوحدة
      5: const FlexTableWidgetColumnWidth(0.10, alignment: Alignment.center), // نوع تعريف الصنف
      6: const FlexTableWidgetColumnWidth(0.12, alignment: Alignment.center), // الباركود
    };
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

        return TableWidget<CategoryEntity>(
          items: filtered,
          header: const [
            'No',
            'الرقم',
            'الصنف',
            'الصنف الفرعي',
            'الوحدة',
            'نوع الصنف',
            'الباركود',
          ],
          columns: getWidths(),
          onTapRow: (category) => _onUpdateCategoryPressed(category),
          onLongPressed: (category) => _onDeleteCategoryPressed(category),
          paintRowColorWhen: (category, index) => index.isOdd,
          rowColor: style.surfaceContainerLowest,
          builder: (context, category, index) {
            return [
              fluent.Text('${index + 1}', style: style.body),
              fluent.Text(category.categoryNumber, style: style.body),
              fluent.Text(category.categoryName, style: style.body),
              fluent.Text(
                category.subcategory?.catalogName ?? 'بدون صنف فرعي',
                style: style.body,
              ),
              fluent.Text(
                category.categoryUnit?.unitName ?? 'غير معرف',
                style: style.body,
              ),
              fluent.Text(category.categoryType.displayName(), style: style.body),
              fluent.Text(category.barcode ?? 'غير معرف', style: style.body),
            ];
          },
        );
      },
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
