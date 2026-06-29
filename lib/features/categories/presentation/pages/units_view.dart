import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/unit_usecases.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flowcash/core/theme_fluent/app_colors.dart';

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

  Map<int, TableWidgetColumnWidth> getWidths() {
    return {
      0: const FixedTableWidgetColumnWidth(60, alignment: AlignmentDirectional.centerStart),
      1: const FlexTableWidgetColumnWidth(1, alignment: AlignmentDirectional.centerStart),
      2: const FlexTableWidgetColumnWidth(1, alignment: AlignmentDirectional.centerStart),
      3: const FlexTableWidgetColumnWidth(1, alignment: AlignmentDirectional.centerStart),
      4: const FlexTableWidgetColumnWidth(1, alignment: AlignmentDirectional.centerStart),
      5: const FlexTableWidgetColumnWidth(1, alignment: AlignmentDirectional.centerStart),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
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
            return TableWidget<UnitEntity>(
              columns: getWidths(),
              items: filtered,
              header: const [
                'No',
                'اسم الوحدة',
                'نوع الوحدة',
                'الطول',
                'العرض',
                'السُمك'
              ],
              paintRowColorWhen: (item, index) => index.isEven,
              rowColor: colors.surfaceContainer,
              builder: (context, unit, index) {
                return [
                  fluent.Text('${index + 1}', style: colors.body),
                  fluent.Text(unit.unitName, style: colors.body),
                  fluent.Text(unit.unitType.fullUnitName, style: colors.body),
                  fluent.Text(AppMoneyFormatter.formatDouble(unit.length), style: colors.body),
                  fluent.Text(AppMoneyFormatter.formatDouble(unit.width), style: colors.body),
                  fluent.Text(AppMoneyFormatter.formatDouble(unit.thickness), style: colors.body),
                ];
              },
            );
          },
        ),
      ),
    );
  }
}
