import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/categories/categories_state.dart';
import 'package:flowcash/features/categories/presentation/pages/categories/category_form_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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

  Widget listView(List<CategoryEntity> categories) {
    final style = AppStyle.of(context);
    return ValueListenableBuilder<TextEditingValue>(
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

        if (filtered.isEmpty) {
          return Center(
            child: fluent.Text('لا يوجد اصناف موجودة', style: style.bodyLarge),
          );
        }

        final dataSource = CategoryDataGridSource(
          items: filtered,
          style: style,
          onItemTap: _onUpdateCategoryPressed,
          onItemLongPress: _onDeleteCategoryPressed,
        );

        return SfDataGrid(
          source: dataSource,
          headerRowHeight: 40,
          rowHeight: 35,
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          columnWidthMode: ColumnWidthMode.fill,
          onCellTap: (DataGridCellTapDetails details) {
            if (details.rowColumnIndex.rowIndex > 0) {
              final item = filtered[details.rowColumnIndex.rowIndex - 1];
              _onUpdateCategoryPressed(item);
            }
          },
          columns: [
            GridColumn(
              columnName: 'no',
              width: isDesktop ? 60.0 : 50.0,
              label: _buildHeaderCell('No', style),
            ),
            GridColumn(
              columnName: 'categoryNumber',
              width: isDesktop ? 80.0 : 60.0,
              label: _buildHeaderCell('الرقم', style),
            ),
            GridColumn(
              columnName: 'categoryName',
              label: _buildHeaderCell('الصنف', style),
            ),
            GridColumn(
              columnName: 'unitName',
              width: isDesktop ? 90.0 : 70.0,
              label: _buildHeaderCell('الوحدة', style),
            ),
            GridColumn(
              columnName: 'type',
              width: isDesktop ? 140.0 : 100.0,
              label: _buildHeaderCell('نوع تعريف الصنف', style),
            ),
            GridColumn(
              columnName: 'barcode',
              label: _buildHeaderCell('الباركود', style),
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
                  return Text(filtered.length.toString(),
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
      context().read<CategoriesBloc>().add(InjectCategoryEvent(category));
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
      context().read<CategoriesBloc>().add(
        InjectCategoryEvent(updatedCategory),
      );
    }
  }
}

class CategoryDataGridSource extends DataGridSource {
  CategoryDataGridSource({
    required List<CategoryEntity> items,
    required this.style,
    required this.onItemTap,
    required this.onItemLongPress,
  }) {
    _dataGridRows = items.asMap().entries.map<DataGridRow>((entry) {
      final index = entry.key;
      final category = entry.value;
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'no', value: '${index + 1}'),
          DataGridCell<String>(
            columnName: 'categoryNumber',
            value: category.categoryNumber,
          ),
          DataGridCell<String>(
            columnName: 'categoryName',
            value: category.categoryName,
          ),
          DataGridCell<String>(
            columnName: 'unitName',
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
    }).toList();
  }

  final AppStyle style;
  final void Function(CategoryEntity) onItemTap;
  final void Function(CategoryEntity) onItemLongPress;

  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final index = _dataGridRows.indexOf(row);
    return DataGridRowAdapter(
      color: index.isEven ? null : style.surfaceContainer,
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.all(8.0),
          child: fluent.Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: style.body,
          ),
        );
      }).toList(),
    );
  }
}

class MainCategoriesDataGridSource extends DataGridSource {
  MainCategoriesDataGridSource({
    required List<MainCategoryEntity> items,
    required this.textTheme,
    required this.colors,
  }) {
    _dataGridRows = items.map<DataGridRow>((item) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'no', value: item.id.toString()),
          DataGridCell<String>(columnName: 'name', value: item.name),
          DataGridCell<String>(columnName: 'unitName', value: item.unitName),
          DataGridCell<String>(
            columnName: 'priceUnit',
            value: item.unitType.fullUnitName,
          ),
          DataGridCell<String>(
            columnName: 'stockUnit',
            value: item.unitType.fullUnitName,
          ),
          DataGridCell<String>(
            columnName: 'type',
            value: item.type.displayName(),
          ),
          DataGridCell<String>(
            columnName: 'containerName',
            value: item.unitName,
          ),
        ],
      );
    }).toList();
  }

  final TextTheme textTheme;
  final ColorScheme colors;
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.all(8.0),
          child: fluent.Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        );
      }).toList(),
    );
  }
}
