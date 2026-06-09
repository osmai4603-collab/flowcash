import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_returns_page/sales_returns_page_bloc.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_returns_page/sales_returns_page_event.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_returns_page/sales_returns_page_state.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'package:flowcash/widgets/message.dart';

class SalesReturnsPage extends StatelessWidget {
  const SalesReturnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesReturnsPageBloc>(
      create: (_) => SalesReturnsPageBloc(
        getBillsUseCase: GetIt.instance<GetBillsUseCase>(),
      )..add(LoadSalesReturnsPageEvent()),
      child: const _SalesReturnsPageView(),
    );
  }
}

class SalesReturnsPageDataGridSource extends DataGridSource {
  SalesReturnsPageDataGridSource({required this.colors, required List<SalesReturnDocument> items}) {
    _dataGridRows = items.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'no', value: '${item.id}'),
        DataGridCell<String>(columnName: 'return', value: item.returnNumber),
        DataGridCell<String>(columnName: 'customer', value: item.customerName),
        DataGridCell<String>(columnName: 'amount', value: item.amount.toStringAsFixed(2)),
        DataGridCell<String>(columnName: 'status', value: item.status),
        DataGridCell<String>(columnName: 'date', value: '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}'),
      ]);
    }).toList();
  }

  final AppStyle colors;
  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final index = _dataGridRows.indexOf(row);
    return DataGridRowAdapter(
      color: index.isEven ? null : colors.surfaceContainerHighest.withAlpha(30),
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

class _SalesReturnsPageView extends StatefulWidget {
  const _SalesReturnsPageView();

  @override
  State<_SalesReturnsPageView> createState() => _SalesReturnsPageViewState();
}

class _SalesReturnsPageViewState extends State<_SalesReturnsPageView> {
  final searchBarController = TextEditingController();

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
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

  Widget buildColumn(BuildContext context, List<SalesReturnDocument> returns) {
    final colors = AppStyle.of(context);
    if (returns.isEmpty) {
      return const Center(
        child: fluent.Text('لا يوجد مرتجعات مبيعات متاحة حالياً'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant, width: 0.5),
      ),
      child: SfDataGrid(
        source: SalesReturnsPageDataGridSource(colors: colors, items: returns),
        headerRowHeight: 40,
        rowHeight: 30,
        gridLinesVisibility: GridLinesVisibility.both,
        headerGridLinesVisibility: GridLinesVisibility.both,
        columnWidthMode: ColumnWidthMode.fill,
        columns: [
          GridColumn(
            columnName: 'no',
            width: isDesktop ? 70.0 : 50.0,
            label: _buildHeaderCell('No', colors),
          ),
          GridColumn(
            columnName: 'return',
            label: _buildHeaderCell('رقم المرتجع', colors),
          ),
          GridColumn(
            columnName: 'customer',
            label: _buildHeaderCell('العميل', colors),
          ),
          GridColumn(
            columnName: 'amount',
            label: _buildHeaderCell('المبلغ', colors),
          ),
          GridColumn(
            columnName: 'status',
            label: _buildHeaderCell('الحالة', colors),
          ),
          GridColumn(
            columnName: 'date',
            label: _buildHeaderCell('التاريخ', colors),
          ),
        ],
      ),
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
            const Expanded(child: fluent.Text('مرتجعات المبيعات')),
            SizedBox(
              width: isDesktop ? 400.0 : 250.0,
              child: BlocBuilder<SalesReturnsPageBloc, SalesReturnsPageState>(
                builder: (context, state) {
                  return fluent.TextBox(
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: fluent.Icon(
                        fluent.FluentIcons.search,
                        color: colors.surfaceContainerHigh,
                      ),
                    ),
                    placeholder: 'ابحث عن رقم المرتجع أو العميل',
                    controller: searchBarController,
                    onChanged: (value) => context
                        .read<SalesReturnsPageBloc>()
                        .add(SearchSalesReturnsPageEvent(value)),
                  );
                },
              ),
            ),
            fluent.Tooltip(
              message: 'إعادة تحميل البيانات',
              child: fluent.IconButton(
                icon: const fluent.Icon(fluent.FluentIcons.refresh),
                onPressed: () => context
                    .read<SalesReturnsPageBloc>()
                    .add(RefreshSalesReturnsPageEvent()),
              ),
            ),
            fluent.FilledButton(
              child: Row(
                children: [
                  fluent.Icon(fluent.FluentIcons.add),
                  const fluent.Text('إضافة مرتجع مبيعات جديد'),
                ],
              ),
              onPressed: () => context
                  .read<SalesReturnsPageBloc>()
                  .add(AddSalesReturnDocumentEvent()),
            ),
          ],
        ),
      ),
      content: BlocListener<SalesReturnsPageBloc, SalesReturnsPageState>(
        listener: (context, state) {
          if (state is SalesReturnsPageOperationFailure) {
            error(context: context, toast: state.message);
          }
        },
        child: BlocBuilder<SalesReturnsPageBloc, SalesReturnsPageState>(
          builder: (context, state) {
            if (state is SalesReturnsPageLoadInProgress ||
                state is SalesReturnsPageInitial) {
              return const Center(child: fluent.ProgressRing());
            }
            if (state is SalesReturnsPageLoadSuccess) {
              return buildColumn(context, state.returns);
            }
            if (state is SalesReturnsPageOperationFailure) {
              return Center(child: fluent.Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
