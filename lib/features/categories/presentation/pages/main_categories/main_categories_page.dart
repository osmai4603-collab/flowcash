import 'dart:io';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/presentation/pages/main_categories/main_category_form_page.dart';
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
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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

class MainCategoryDataGridSource extends DataGridSource {
  MainCategoryDataGridSource({
    required List<MainCategoryEntity> items,
    required this.colors,
    required this.onItemTap,
    required this.onItemDoubleTap,
    required this.onItemLongPress,
  }) {
    _dataGridRows = items.asMap().entries.map<DataGridRow>((entry) {
      final index = entry.key;
      final item = entry.value;
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'no', value: '${index + 1}'),
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

  final AppStyle colors;
  final void Function(MainCategoryEntity) onItemTap;
  final void Function(MainCategoryEntity) onItemDoubleTap;
  final void Function(MainCategoryEntity) onItemLongPress;

  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final index = _dataGridRows.indexOf(row);
    return DataGridRowAdapter(
      color: index.isEven
          ? null
          : colors.surfaceContainerHighest.withValues(alpha: 0.12),
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4.0),
          child: fluent.Text(
            dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
            style: colors.body,
          ),
        );
      }).toList(),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant, width: 0.5),
      ),
      child: SfDataGrid(
        source: MainCategoryDataGridSource(
          items: mainCategories,
          colors: colors,
          onItemTap: (category) async {
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
          onItemDoubleTap: (category) async {
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
          onItemLongPress: (category) =>
              _onCategoryLongPressed(context, category),
        ),
        headerRowHeight: 40,
        rowHeight: 30,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: ColumnWidthMode.fill,
        onCellTap: (details) async {
          if (details.rowColumnIndex.rowIndex > 0) {
            final item = mainCategories[details.rowColumnIndex.rowIndex - 1];
            final result = await showDialog<MainCategoryEntity?>(
              context: context,
              builder: (_) => MainCategoryFormPage(id: item.id),
            );
            if (result != null && context.mounted) {
              context.read<MainCategoriesBloc>().add(
                RefreshMainCategoriesEvent(),
              );
            }
          }
        },
        onCellDoubleTap: (details) async {
          if (details.rowColumnIndex.rowIndex > 0) {
            final item = mainCategories[details.rowColumnIndex.rowIndex - 1];
            final result = await showDialog<MainCategoryEntity?>(
              context: context,
              builder: (_) => MainCategoryFormPage(id: item.id),
            );
            if (result != null && context.mounted) {
              context.read<MainCategoriesBloc>().add(
                RefreshMainCategoriesEvent(),
              );
            }
          }
        },
        columns: [
          GridColumn(
            columnName: 'no',
            width: isDesktop ? 60.0 : 50.0,
            label: _buildHeaderCell('No', colors),
          ),
          GridColumn(
            columnName: 'name',
            label: _buildHeaderCell('اسم الصنف', colors),
          ),
          GridColumn(
            columnName: 'unitName',
            label: _buildHeaderCell('وحدة الصنف', colors),
          ),
          GridColumn(
            columnName: 'priceUnit',
            label: _buildHeaderCell('وحدة السعر', colors),
          ),
          GridColumn(
            columnName: 'stockUnit',
            label: _buildHeaderCell('وحدة الجرد', colors),
          ),
          GridColumn(
            columnName: 'type',
            label: _buildHeaderCell('نوع الصنف', colors),
          ),
          GridColumn(
            columnName: 'containerName',
            label: _buildHeaderCell('اسم الحاوية', colors),
          ),
        ],
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
