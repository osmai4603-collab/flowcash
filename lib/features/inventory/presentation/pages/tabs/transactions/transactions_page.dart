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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<TransactionsBloc>();

          if (state.status == TransactionsStatus.loading ||
              _isLoadingMetaData) {
            return const Center(child: CircularProgressIndicator());
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
            padding: const EdgeInsets.all(20.0),
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
                      padding: const EdgeInsets.all(20.0),
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
                                    prefixIcon: const Icon(Icons.search),
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
                                child:
                                    DropdownButtonFormField<
                                      InventoryTransactionType?
                                    >(
                                      isExpanded: true,
                                      decoration: InputDecoration(
                                        hintText: 'كل الأنواع 📋',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                      ),
                                      value: _filterType,
                                      items: [
                                        const DropdownMenuItem<
                                          InventoryTransactionType?
                                        >(
                                          value: null,
                                          child: Text('كل الأنواع 📋'),
                                        ),
                                        ...InventoryTransactionType.values.map((
                                          type,
                                        ) {
                                          return DropdownMenuItem<
                                            InventoryTransactionType?
                                          >(
                                            value: type,
                                            child: Text(type.displayName()),
                                          );
                                        }),
                                      ],
                                      onChanged: (val) {
                                        setState(() {
                                          _filterType = val;
                                        });
                                      },
                                    ),
                              ),
                              const SizedBox(width: 12),

                              // Add transaction button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (state.batches.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'الرجاء إنشاء دفعات أصناف أولاً',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final result =
                                      await showDialog<Map<String, dynamic>>(
                                        context: context,
                                        builder: (context) =>
                                            TransactionFormDialog(
                                              batches: state.batches,
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
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.add_box_outlined),
                                label: const Text(
                                  'إصدار إذن',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'رقم السند 🧾',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'نوع الحركة 📋',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'المستودع الرئيسي 🏢',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'تاريخ الإصدار 📅',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'البيان/ملاحظة 📝',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Transactions list
                          Expanded(
                            child: filteredTransactions.isEmpty
                                ? const Center(
                                    child: Text(
                                      'لا توجد أذون حركات تطابق معايير البحث ⚠️',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filteredTransactions.length,
                                    itemBuilder: (context, index) {
                                      final t = filteredTransactions[index];
                                      final isSelected =
                                          _selectedTransaction?.id == t.id;

                                      final isReceipt =
                                          t.transactionType ==
                                          InventoryTransactionType
                                              .inventoryReceipt;

                                      return Card(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                                  .withAlpha(20)
                                            : null,
                                        elevation: isSelected ? 2 : 0,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          onTap: () {
                                            setState(() {
                                              _selectedTransaction = isSelected
                                                  ? null
                                                  : t;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '#${t.billNumber}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    t.transactionType
                                                        .displayName(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isReceipt
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    _getWarehouseName(
                                                      t.warehouseId,
                                                      state.warehouses,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    _formatDate(t.createdAt),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    t.note ?? '──',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
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
                                Icon(
                                  Icons.description_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
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
                          batches: state.batches,
                          warehouses: state.warehouses,
                          inventoryItems: [], // state.inventoryItems,
                          categories: _categories,
                          onEdit: () async {
                            final result =
                                await showDialog<Map<String, dynamic>>(
                                  context: context,
                                  builder: (context) => TransactionFormDialog(
                                    transaction: _selectedTransaction,
                                    initialOrders: selectedOrders,
                                    batches: state.batches,
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
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('تأكيد حذف إذن الحركة ⚠️'),
                                content: const Text(
                                  'هل أنت متأكد من رغبتك في حذف بطاقة إذن الحركة المخزنية هذه وبنودها نهائياً؟',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      bloc.add(
                                        DeleteTransactionEvent(
                                          _selectedTransaction!.id,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                      foregroundColor:
                                          theme.colorScheme.onError,
                                    ),
                                    child: const Text('حذف إذن الحركة'),
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
