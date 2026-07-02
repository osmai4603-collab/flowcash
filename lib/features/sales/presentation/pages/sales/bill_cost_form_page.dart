import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/usecases/inventory_usecases.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/cost_good_bill_order_entity.dart';
import 'package:flowcash/features/transactions/domain/repositories/bill_order_repository.dart';
import 'package:flowcash/features/injection_container.dart';

class BillCostFormPage extends StatefulWidget {
  final BillEntity bill;

  const BillCostFormPage({super.key, required this.bill});

  @override
  State<BillCostFormPage> createState() => _BillCostFormPageState();
}

class _BillCostFormPageState extends State<BillCostFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _orderRows = <CostOrderRow>[];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSyncing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCostRows();
  }

  @override
  void dispose() {
    for (final row in _orderRows) {
      row.unitCostController.dispose();
      row.totalCostController.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCostRows() async {
    try {
      final orderResult = await sl<BillOrderRepository>().whereBillId([widget.bill.id]);
      await orderResult.match(
        (failure) async {
          setState(() {
            _errorMessage = failure.message;
            _isLoading = false;
          });
        },
        (orders) async {
          final categoryIds = orders.map((order) => order.categoryId).toSet();
          if (categoryIds.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return;
          }

          final categoriesResult = await sl<GetAllCategoriesUseCase>()(ids: categoryIds);
          await categoriesResult.match(
            (failure) async {
              setState(() {
                _errorMessage = failure.message;
                _isLoading = false;
              });
            },
            (categories) async {
              final categoriesById = {
                for (final category in categories) category.id: category,
              };
              final inventoryCache = <int, InventoryEntity>{};
              for (final order in orders) {
                final category = categoriesById[order.categoryId];
                if (category == null || category.categoryType == CategoryDefineType.services) {
                  continue;
                }

                final inventoryResult = await sl<GetInventoryUseCase>()(
                  categoryId: order.categoryId,
                  warehouseId: widget.bill.warehouseId,
                );
                await inventoryResult.match(
                  (failure) async {
                    throw Exception(failure.message);
                  },
                  (inventory) async {
                    inventoryCache[order.categoryId] = inventory;
                  },
                );
              }

              if (inventoryCache.isEmpty) {
                setState(() {
                  _isLoading = false;
                });
                return;
              }

              final rows = <CostOrderRow>[];
              for (final order in orders) {
                final category = categoriesById[order.categoryId];
                if (category == null || category.categoryType == CategoryDefineType.services) {
                  continue;
                }
                final inventory = inventoryCache[order.categoryId]!;
                final unitCost = inventory.countUnits > 0
                    ? inventory.costTotal / inventory.countUnits
                    : 0.0;
                final totalCost = unitCost * order.countUnits;
                final unitCostController = TextEditingController(
                  text: AppMoneyFormatter.formatDouble(unitCost),
                );
                final totalCostController = TextEditingController(
                  text: AppMoneyFormatter.formatDouble(totalCost),
                );
                rows.add(
                  CostOrderRow(
                    billOrderId: order.id,
                    categoryId: order.categoryId,
                    categoryName: category.categoryName,
                    inventoryName: inventory.inventoryName,
                    unitName: category.categoryUnit?.unitName ?? '',
                    countUnits: order.countUnits,
                    unitCostController: unitCostController,
                    totalCostController: totalCostController,
                  ),
                );
              }

              setState(() {
                _orderRows.addAll(rows);
                _isLoading = false;
              });
            },
          );
        },
      );
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  double get _grandTotal {
    return _orderRows.fold<double>(0.0, (sum, row) => sum + row.totalCost);
  }

  void _syncFromUnitCost(int index, String value) {
    if (_isSyncing) return;
    _isSyncing = true;
    final row = _orderRows[index];
    final unitCost = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    final total = unitCost * row.countUnits;
    row.totalCostController.text = AppMoneyFormatter.formatDouble(total);
    setState(() {});
    _isSyncing = false;
  }

  void _syncFromTotalCost(int index, String value) {
    if (_isSyncing) return;
    _isSyncing = true;
    final row = _orderRows[index];
    final totalCost = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    final unitCost = row.countUnits > 0 ? totalCost / row.countUnits : 0.0;
    row.unitCostController.text = AppMoneyFormatter.formatDouble(unitCost);
    setState(() {});
    _isSyncing = false;
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;
    final overrideOrders = _orderRows.map((row) {
      return CostGoodBillOrderEntity(
        id: 0,
        costGoodBillId: 0,
        categoryId: row.categoryId,
        countUnits: row.countUnits,
        totalPrice: row.totalCost,
      );
    }).toList();
    Navigator.pop(context, overrideOrders);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    return fluent.ContentDialog(
      title: fluent.Text('ترحيل تكلفة الفاتورة'),
      content: _buildContent(colors),
      actions: _buildActions(context),
      constraints: const BoxConstraints(maxWidth: 600),
    );
  }

  Widget _buildContent(AppStyle colors) {
    if (_isLoading) {
      return const SizedBox(
        height: 120,
        child: Center(child: fluent.ProgressRing()),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 120,
        child: Center(
          child: fluent.Text(
            'حدث خطأ: $_errorMessage',
            style: colors.body.copyWith(color: colors.error),
          ),
        ),
      );
    }

    if (_orderRows.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: fluent.Text(
            'لا توجد عناصر صالحة لترحيل التكلفة لهذا الفاتورة.',
            style: colors.body,
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Table(
              border: TableBorder.all(color: colors.outlineVariant, width: 0.5),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(0.30),
                1: FlexColumnWidth(0.10),
                2: FlexColumnWidth(0.12),
                3: FlexColumnWidth(0.16),
                4: FlexColumnWidth(0.16),
              },
              children: [
                TableRow(
                  decoration:
                      BoxDecoration(color: colors.surfaceContainerHigh),
                  children: [
                    _headerCell('الصنف', colors),
                    _headerCell('الوحدة', colors),
                    _headerCell('الكمية', colors),
                    _headerCell('سعر الوحدة', colors),
                    _headerCell('الإجمالي', colors),
                  ],
                ),
                ..._orderRows.asMap().entries.map(
                      (entry) => _buildOrderRow(entry.key, entry.value, colors),
                    ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: fluent.Text(
                'إجمالي التكلفة: ${AppMoneyFormatter.formatDouble(_grandTotal)} ${widget.bill.currencyId}',
                style: colors.body.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      fluent.Button(
        child: const fluent.Text('إلغاء'),
        onPressed: () => Navigator.pop(context),
      ),
      fluent.FilledButton(
        onPressed: _orderRows.isEmpty || _isSaving ? null : _onSavePressed,
        child: _isSaving
            ? const fluent.ProgressRing()
            : const fluent.Text('حفظ وترحيل'),
      ),
    ];
  }

  Widget _headerCell(String text, AppStyle colors) {
    return Container(
      alignment: .center,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: fluent.Text(
        text,
        style: colors.body.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TableRow _buildOrderRow(int index, CostOrderRow row, AppStyle colors) {
    return TableRow(
      decoration: BoxDecoration(
        color: index.isEven ? null : colors.surfaceContainerHighest,
      ),
      children: [
        // _dataCell(row.inventoryName, colors),
        _dataCell(row.categoryName, colors),
        _dataCell(row.unitName, colors),
        _dataCell(AppMoneyFormatter.formatDouble(row.countUnits), colors),
        _editableCell(
          controller: row.unitCostController,
          onChanged: (value) => _syncFromUnitCost(index, value),
          colors: colors,
        ),
        _editableCell(
          controller: row.totalCostController,
          onChanged: (value) => _syncFromTotalCost(index, value),
          colors: colors,
        ),
      ],
    );
  }

  Widget _dataCell(String text, AppStyle colors) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: fluent.Text(text, style: colors.body),
    );
  }

  Widget _editableCell({
    required TextEditingController controller,
    required void Function(String) onChanged,
    required AppStyle colors,
  }) {
    return fluent.TextBox(
      controller: controller,
      textAlign: TextAlign.center,
      textDirection: .ltr,
      decoration: const WidgetStatePropertyAll(
        BoxDecoration(
          border: Border.fromBorderSide(BorderSide.none),
          borderRadius: BorderRadius.zero,
        ),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
      ],
      onChanged: onChanged,
      onEditingComplete: () {
        FocusScope.of(context).nextFocus();
      },
    );
  }
}

class CostOrderRow {
  final int billOrderId;
  final int categoryId;
  final String categoryName;
  final String inventoryName;
  final String unitName;
  final double countUnits;
  final TextEditingController unitCostController;
  final TextEditingController totalCostController;

  CostOrderRow({
    required this.billOrderId,
    required this.categoryId,
    required this.categoryName,
    required this.inventoryName,
    required this.unitName,
    required this.countUnits,
    required this.unitCostController,
    required this.totalCostController,
  });

  double get unitCost => double.tryParse(unitCostController.text.replaceAll(',', '')) ?? 0.0;

  double get totalCost => double.tryParse(totalCostController.text.replaceAll(',', '')) ?? 0.0;
}
