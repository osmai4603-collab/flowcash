import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

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
    final colors = Theme.of(context).colorScheme;
    return fluent.ScaffoldPage(
      header: fluent.PageHeader(
        title: Row(
          spacing: Spacings.medium,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: fluent.Text('الوحدات')),
            SizedBox(
              width: 400.0,
              child: fluent.TextBox(
                prefix: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: fluent.Icon(
                    fluent.FluentIcons.search,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                placeholder: 'ابحث عن وحدة هنا',
                controller: searchController,
              ),
            ),
            fluent.Tooltip(
              message: 'إعادة تحميل البيانات',
              child: fluent.IconButton(
                icon: const fluent.Icon(fluent.FluentIcons.refresh),
                onPressed: () => setState(() {
                  _unitsFuture = _loadUnits();
                }),
              ),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(12.0),
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
            final dataSource = UnitsDataGridSource(items: filtered);
            return SfDataGrid(
              source: dataSource,
              headerRowHeight: 40,
              rowHeight: 36,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              columnWidthMode: ColumnWidthMode.fill,
              columns: [
                GridColumn(
                  columnName: 'no',
                  width: 60,
                  label: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    child: fluent.Text('No'),
                  ),
                ),
                GridColumn(
                  columnName: 'unitName',
                  label: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    child: fluent.Text('اسم الوحدة'),
                  ),
                ),
                GridColumn(
                  columnName: 'unitType',
                  label: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    child: fluent.Text('نوع الوحدة'),
                  ),
                ),
                GridColumn(
                  columnName: 'length',
                  label: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    child: fluent.Text('الطول'),
                  ),
                ),
                GridColumn(
                  columnName: 'width',
                  label: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    child: fluent.Text('العرض'),
                  ),
                ),
                GridColumn(
                  columnName: 'thickness',
                  label: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    child: fluent.Text('السُمك'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


class UnitsDataGridSource extends DataGridSource {
  UnitsDataGridSource({required List<UnitEntity> items}) {
    _rows = items.asMap().entries.map<DataGridRow>((entry) {
      final index = entry.key;
      final unit = entry.value;
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'no', value: '${index + 1}'),
          DataGridCell<String>(columnName: 'unitName', value: unit.unitName),
          DataGridCell<String>(
            columnName: 'unitType',
            value: unit.unitType.fullUnitName,
          ),
          DataGridCell<String>(
            columnName: 'length',
            value: unit.length.toString(),
          ),
          DataGridCell<String>(
            columnName: 'width',
            value: unit.width.toString(),
          ),
          DataGridCell<String>(
            columnName: 'thickness',
            value: unit.thickness.toString(),
          ),
        ],
      );
    }).toList();
  }

  List<DataGridRow> _rows = [];

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: fluent.Text(cell.value.toString()),
        );
      }).toList(),
    );
  }
}
