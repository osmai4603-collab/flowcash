import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/inventory/presentation/blocs/transactions/transactions_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/transactions/transactions_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/transactions/transactions_state.dart';
import 'package:flowcash/core/enums/inventory_transaction_type_enum.dart';

import 'transaction_form_dialog.dart';
import 'transaction_detail_panel.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  // Local filter states
  String _searchQuery = "";
  InventoryTransactionType? _filterType;
  int? _filterWarehouseId;

  // Fully loaded category reference lists for labels
  List<CategoryEntity> _categories = [];
  bool _isLoadingMetaData = true;

  // Selected transaction locally tracked
  InventoryTransactionEntity? _selectedTransaction;

  @override
  void initState() {
    super.initState();
    _loadMetaData();
  }

  Future<void> _loadMetaData() async {
    try {
      final categoriesRes = await sl<GetAllCategoriesUseCase>().call();
      if (mounted) {
        setState(() {
          categoriesRes.fold((_) => null, (list) => _categories = list);
          _isLoadingMetaData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMetaData = false);
      }
    }
  }

  String _getWarehouseName(int id, List<WarehouseEntity> warehouses) {
    try {
      return warehouses.firstWhere((w) => w.id == id).warehouseName;
    } catch (_) {
      return 'مستودع (#$id)';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<TransactionsBloc>(
      create: (context) =>
          sl<TransactionsBloc>()..add(const LoadTransactionsEvent()),
      child: BlocConsumer<TransactionsBloc, TransactionsState>(
        listener: (context, state) {
          if (state.status == TransactionsStatus.error &&
              state.errorMessage != null) {
            fluent.displayInfoBar(
              context,
              builder: (context, close) => fluent.InfoBar(
                title: const fluent.Text('تنبيه'),
                content: fluent.Text(state.errorMessage!),
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<TransactionsBloc>();

          if (state.status == TransactionsStatus.loading ||
              _isLoadingMetaData) {
            return const Center(child: fluent.ProgressRing());
          }

          // Apply client-side search & filtering
          final filteredTransactions = state.transactions.where((t) {
            final billNumLower = t.billNumber.toString();
            final noteLower = (t.note ?? "").toLowerCase();

            final matchesSearch =
                billNumLower.contains(_searchQuery.toLowerCase()) ||
                noteLower.contains(_searchQuery.toLowerCase());
            final matchesType =
                _filterType == null || t.transactionType == _filterType;
            final matchesWarehouse =
                _filterWarehouseId == null ||
                t.warehouseId == _filterWarehouseId;

            return matchesSearch && matchesType && matchesWarehouse;
          }).toList();

          // Sync local selection if deleted/updated
          List<InventoryTransactionOrderEntity> selectedOrders = [];
          if (_selectedTransaction != null) {
            final exists = state.transactions.any(
              (t) => t.id == _selectedTransaction!.id,
            );
            if (!exists) {
              _selectedTransaction = null;
            } else {
              _selectedTransaction = state.transactions.firstWhere(
                (t) => t.id == _selectedTransaction!.id,
              );
              selectedOrders = state.allOrders
                  .where((o) => o.tranId == _selectedTransaction!.id)
                  .toList();
            }
          }

          return Padding(
            padding: Paddings.largeAll,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MASTER PANEL (Left Side)
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: Paddings.largeAll,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search & Filters row
                          Row(
                            children: [
                              // Search input
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText:
                                        'البحث برقم السند أو البيان... 🔍',
                                    prefixIcon: const fluent.Icon(
                                      fluent.FluentIcons.search,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Type filter
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: MenuBar(
                                    children: [
                                      SubmenuButton(
                                        menuChildren: [
                                          MenuItemButton(
                                            onPressed: () => setState(
                                              () => _filterType = null,
                                            ),
                                            child: const fluent.Text(
                                              'كل الأنواع 📋',
                                            ),
                                          ),
                                          ...InventoryTransactionType.values
                                              .map(
                                                (type) => MenuItemButton(
                                                  onPressed: () => setState(
                                                    () => _filterType = type,
                                                  ),
                                                  child: fluent.Text(
                                                    type.displayName(),
                                                  ),
                                                ),
                                              ),
                                        ],
                                        child: fluent.Text(
                                          _filterType == null
                                              ? 'كل الأنواع'
                                              : _filterType!
                                                    .displayName()
                                                    .toString(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Add transaction button
                              fluent.FilledButton(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const fluent.Icon(fluent.FluentIcons.add),
                                    const SizedBox(width: 8.0),
                                    const fluent.Text(
                                      'إصدار إذن',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () async {
                                  final result =
                                      await fluent.showDialog<Map<String, dynamic>>(
                                        context: context,
                                        builder: (context) =>
                                            TransactionFormDialog(
                                              warehouses: state.warehouses,
                                              inventoryItems:
                                                  [], // state.inventoryItems,
                                            ),
                                      );
                                  if (result != null) {
                                    final t =
                                        result['transaction']
                                            as InventoryTransactionEntity;
                                    final o =
                                        result['orders']
                                            as List<
                                              InventoryTransactionOrderEntity
                                            >;
                                    bloc.add(AddTransactionEvent(t, o));
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Table with selection
                          Expanded(
                            child: filteredTransactions.isEmpty
                                ? const Center(
                                    child: fluent.Text(
                                      'لا توجد أذون حركات تطابق معايير البحث ⚠️',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : TableWidget<InventoryTransactionEntity>(
                                    columns: const {
                                      0: FlexTableWidgetColumnWidth(1),
                                      1: FlexTableWidgetColumnWidth(1),
                                      2: FlexTableWidgetColumnWidth(1),
                                      3: FlexTableWidgetColumnWidth(1),
                                      4: FlexTableWidgetColumnWidth(1),
                                    },
                                    header: const [
                                      'رقم السند 🧂',
                                      'نوع الحركة 📋',
                                      'المستودع الرئيسي 🏢',
                                      'تاريخ الإصدار 📅',
                                      'البيان/ملاحظة 📝',
                                    ],
                                    items: filteredTransactions,
                                    rowColor: theme.colorScheme.primary
                                        .withAlpha(20),
                                    paintRowColorWhen: (t, index) =>
                                        _selectedTransaction?.id == t.id,
                                    onTapRow: (t) {
                                      setState(() {
                                        _selectedTransaction =
                                            _selectedTransaction?.id == t.id
                                            ? null
                                            : t;
                                      });
                                    },
                                    builder: (context, t, index) {
                                      final isReceipt =
                                          t.transactionType ==
                                          InventoryTransactionType
                                              .importInventory;
                                      return [
                                        fluent.Text(
                                          '#${t.billNumber}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        fluent.Text(
                                          t.transactionType.displayName(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isReceipt
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                        fluent.Text(
                                          _getWarehouseName(
                                            t.warehouseId,
                                            state.warehouses,
                                          ),
                                        ),
                                        fluent.Text(_formatDate(t.createdAt)),
                                        fluent.Text(
                                          t.note ?? '──',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ];
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // DETAIL PANEL (Right Side - 40% Width)
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: _selectedTransaction == null
                      ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                fluent.Icon(
                                  fluent.FluentIcons.one_note_doc_type,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                fluent.Text(
                                  'الرجاء اختيار إذن حركة من القائمة اليسرى لعرض كامل تفاصيل البنود والكميات وحالات الإدخال/الإخراج.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : TransactionDetailPanel(
                          transaction: _selectedTransaction!,
                          orders: selectedOrders,
                          warehouses: state.warehouses,
                          inventoryItems: [], // state.inventoryItems,
                          categories: _categories,
                          onEdit: () async {
                            final result =
                                await fluent.showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (context) => TransactionFormDialog(
                                    transaction: _selectedTransaction,
                                    initialOrders: selectedOrders,
                                    warehouses: state.warehouses,
                                    inventoryItems: [], //state.inventoryItems,
                                  ),
                                );
                            if (result != null) {
                              final t =
                                  result['transaction']
                                      as InventoryTransactionEntity;
                              final o =
                                  result['orders']
                                      as List<InventoryTransactionOrderEntity>;
                              bloc.add(UpdateTransactionEvent(t, o));
                            }
                          },
                          onDelete: () {
                            fluent.showDialog(
                              context: context,
                              builder: (context) => fluent.ContentDialog(
                                title: const fluent.Text(
                                  'تأكيد حذف إذن الحركة ⚠️',
                                ),
                                content: const fluent.Text(
                                  'هل أنت متأكد من رغبتك في حذف بطاقة إذن الحركة المخزنية هذه وبنودها نهائياً؟',
                                ),
                                actions: [
                                  fluent.Button(
                                    onPressed: () => Navigator.pop(context),
                                    child: const fluent.Text('إلغاء'),
                                  ),
                                  fluent.FilledButton(
                                    onPressed: () {
                                      bloc.add(
                                        DeleteTransactionEvent(
                                          _selectedTransaction!.id,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const fluent.Text('حذف إذن الحركة'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
