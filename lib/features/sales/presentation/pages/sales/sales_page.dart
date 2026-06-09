import 'dart:io';

import 'package:flowcash/features/sales/presentation/pages/sales/sale_form_page.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_page/sales_page_bloc.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_page/sales_page_event.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_page/sales_page_state.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'package:flowcash/widgets/message.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesPageBloc>(
      create: (_) => SalesPageBloc(
        getBillsUseCase: GetIt.instance<GetBillsUseCase>(),
      )..add(LoadSalesPageEvent()),
      child: const _SalesPageView(),
    );
  }
}

class SalesPageDataGridSource extends DataGridSource {
  SalesPageDataGridSource({required List<SalesDocument> items, required this.colors}) {
    _dataGridRows = items.map<DataGridRow>((item) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'no', value: '${item.id}'),
        DataGridCell<String>(columnName: 'invoice', value: item.invoiceNumber),
        DataGridCell<String>(columnName: 'customer', value: item.customerName),
        DataGridCell<String>(columnName: 'amount', value: item.amount.toStringAsFixed(2)),
        DataGridCell<String>(columnName: 'status', value: item.status),
        DataGridCell<String>(columnName: 'date', value: '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')}'),
      ]);
    }).toList();
  }

  List<DataGridRow> _dataGridRows = [];
  final AppStyle colors;

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

class _SalesPageView extends StatefulWidget {
  const _SalesPageView();

  @override
  State<_SalesPageView> createState() => _SalesPageViewState();
}

class _SalesPageViewState extends State<_SalesPageView> {
  final searchBarController = TextEditingController();

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  Map<int, TableColumnWidth> getWidths() {
    return {
      0: const FlexColumnWidth(0.08),
      1: const FlexColumnWidth(0.20),
      2: const FlexColumnWidth(0.24),
      3: const FlexColumnWidth(0.16),
      4: const FlexColumnWidth(0.16),
      5: const FlexColumnWidth(0.16),
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

  Widget buildColumn(BuildContext context, List<SalesDocument> sales) {
    final colors = AppStyle.of(context);
    if (sales.isEmpty) {
      return const Center(
        child: fluent.Text('لا يوجد مبيعات متاحة حالياً'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant, width: 0.5),
      ),
      child: SfDataGrid(
        source: SalesPageDataGridSource(colors: colors, items: sales),
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
            columnName: 'invoice',
            label: _buildHeaderCell('رقم الفاتورة', colors),
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
            const Expanded(child: fluent.Text('المبيعات')),
            SizedBox(
              width: isDesktop ? 400.0 : 250.0,
              child: BlocBuilder<SalesPageBloc, SalesPageState>(
                builder: (context, state) {
                  return fluent.TextBox(
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: fluent.Icon(
                        fluent.FluentIcons.search,
                        color: colors.surfaceContainerHigh,
                      ),
                    ),
                    placeholder: 'ابحث عن فاتورة أو عميل',
                    controller: searchBarController,
                    onChanged: (value) => context
                        .read<SalesPageBloc>()
                        .add(SearchSalesPageEvent(value)),
                  );
                },
              ),
            ),
            fluent.Tooltip(
              message: 'إعادة تحميل البيانات',
              child: fluent.IconButton(
                icon: const fluent.Icon(fluent.FluentIcons.refresh),
                onPressed: () => context
                    .read<SalesPageBloc>()
                    .add(RefreshSalesPageEvent()),
              ),
            ),
            fluent.FilledButton(
              onPressed: _onAddNewSaleBill,
              child: Row(
                spacing: Spacings.small,
                children: [
                  fluent.Icon(fluent.FluentIcons.add),
                  const fluent.Text('إضافة سند مبيعات جديد'),
                ],
              ),
            ),
          ],
        ),
      ),
      content: BlocListener<SalesPageBloc, SalesPageState>(
        listener: (context, state) {
          if (state is SalesPageOperationFailure) {
            error(context: context, toast: state.message);
          }
        },
        child: BlocBuilder<SalesPageBloc, SalesPageState>(
          builder: (context, state) {
            if (state is SalesPageLoadInProgress || state is SalesPageInitial) {
              return const Center(child: fluent.ProgressRing());
            }
            if (state is SalesPageLoadSuccess) {
              return buildColumn(context, state.sales);
            }
            if (state is SalesPageOperationFailure) {
              return Center(child: fluent.Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _onAddNewSaleBill() async {
    final bloc = context.read<SalesPageBloc>();
    final saleBill = await showDialog<BillEntity>(
      context: context,
      builder: (context) => const SaleFormPage(),
    );
    if (saleBill != null && context.mounted) {
      bloc.add(AddSalesDocumentEvent(saleBill));
    }
  }
}
