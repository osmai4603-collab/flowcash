import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_transaction_order_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/inventory/presentation/blocs/warehouse_transfers/warehouse_transfers_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/warehouse_transfers/warehouse_transfers_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/warehouse_transfers/warehouse_transfers_state.dart';

import 'transfer_form_dialog.dart';
import 'transfer_detail_panel.dart';

class WarehouseTransfersPage extends StatefulWidget {
  const WarehouseTransfersPage({super.key});

  @override
  State<WarehouseTransfersPage> createState() => _WarehouseTransfersPageState();
}

class _WarehouseTransfersPageState extends State<WarehouseTransfersPage> {
  // Local filter states
  String _searchQuery = "";
  int? _filterFromWarehouseId;
  int? _filterToWarehouseId;

  // Fully loaded category reference lists for labels
  List<CategoryEntity> _categories = [];
  bool _isLoadingMetaData = true;

  // Selected transfer transaction tracked locally
  InventoryTransactionEntity? _selectedTransfer;

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

    return BlocProvider<WarehouseTransfersBloc>(
      create: (context) =>
          sl<WarehouseTransfersBloc>()..add(const LoadTransfersEvent()),
      child: BlocConsumer<WarehouseTransfersBloc, WarehouseTransfersState>(
        listener: (context, state) {
          if (state.status == TransfersStatus.error &&
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
          final bloc = context.read<WarehouseTransfersBloc>();

          if (state.status == TransfersStatus.loading || _isLoadingMetaData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter for only "Outward" transfer transactions to avoid duplicate listing of double-sided transfers
          final transfersList = state.transactions.where((t) {
            final isTransfer = t.note?.contains('تحويل مخزني') ?? false;
            final isOutward = t.note?.contains('صادر') ?? false;
            return isTransfer && isOutward;
          }).toList();

          // Apply client-side search & filtering
          final filteredTransfers = transfersList.where((t) {
            final billNumLower = t.billNumber.toString();
            final noteLower = (t.note ?? "").toLowerCase();

            final matchesSearch =
                billNumLower.contains(_searchQuery.toLowerCase()) ||
                noteLower.contains(_searchQuery.toLowerCase());

            // Try to extract counterpart from note "تحويل مخزني صادر إلى مستودع X"
            int toWarehouseId = 0;
            if (t.note != null && t.note!.contains('إلى مستودع')) {
              final regExp = RegExp(r'إلى مستودع (\d+)');
              final match = regExp.firstMatch(t.note!);
              if (match != null) {
                toWarehouseId = int.tryParse(match.group(1) ?? '0') ?? 0;
              }
            }

            final matchesFrom =
                _filterFromWarehouseId == null ||
                t.warehouseId == _filterFromWarehouseId;
            final matchesTo =
                _filterToWarehouseId == null ||
                toWarehouseId == _filterToWarehouseId;

            return matchesSearch && matchesFrom && matchesTo;
          }).toList();

          // Sync local selection if deleted
          if (_selectedTransfer != null) {
            final exists = state.transactions.any(
              (t) => t.id == _selectedTransfer!.id,
            );
            if (!exists) {
              _selectedTransfer = null;
            } else {
              _selectedTransfer = state.transactions.firstWhere(
                (t) => t.id == _selectedTransfer!.id,
              );
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
                                        'البحث برقم سند النقل أو التفاصيل... 🔍',
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

                              // From Warehouse filter
                              Expanded(
                                child: DropdownButtonFormField<int?>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    hintText: 'من مستودع 📤',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                  initialValue: _filterFromWarehouseId,
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('من مستودع 📤'),
                                    ),
                                    ...state.warehouses.map((w) {
                                      return DropdownMenuItem<int?>(
                                        value: w.id,
                                        child: Text(w.warehouseName),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) => setState(
                                    () => _filterFromWarehouseId = val,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Add Transfer button
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
                                            TransferFormDialog(
                                              batches: state.batches,
                                              warehouses: state.warehouses,
                                              inventoryItems:
                                                  [], // state.inventoryItems,
                                            ),
                                      );
                                  if (result != null) {
                                    final fromT =
                                        result['fromTransaction']
                                            as InventoryTransactionEntity;
                                    final toT =
                                        result['toTransaction']
                                            as InventoryTransactionEntity;
                                    final items =
                                        result['items']
                                            as List<
                                              InventoryTransactionOrderEntity
                                            >;
                                    bloc.add(
                                      AddTransferEvent(
                                        fromTransaction: fromT,
                                        toTransaction: toT,
                                        items: items,
                                      ),
                                    );
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
                                icon: const Icon(Icons.local_shipping_outlined),
                                label: const Text(
                                  'إجراء نقل',
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
                                    'من مستودع (الصادر) 📤',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'إلى مستودع (الوارد) 📥',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'تاريخ العملية 📅',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'الحالة وتفاصيل النقل 🚚',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Transfers list
                          Expanded(
                            child: filteredTransfers.isEmpty
                                ? const Center(
                                    child: Text(
                                      'لا توجد عمليات نقل وتوزيع تطابق معايير البحث ⚠️',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filteredTransfers.length,
                                    itemBuilder: (context, index) {
                                      final t = filteredTransfers[index];
                                      final isSelected =
                                          _selectedTransfer?.id == t.id;

                                      // Parse counterpart details
                                      int toWarehouseId = 0;
                                      if (t.note != null &&
                                          t.note!.contains('إلى مستودع')) {
                                        final regExp = RegExp(
                                          r'إلى مستودع (\d+)',
                                        );
                                        final match = regExp.firstMatch(
                                          t.note!,
                                        );
                                        if (match != null) {
                                          toWarehouseId =
                                              int.tryParse(
                                                match.group(1) ?? '0',
                                              ) ??
                                              0;
                                        }
                                      }

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
                                              _selectedTransfer = isSelected
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
                                                    _getWarehouseName(
                                                      t.warehouseId,
                                                      state.warehouses,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    _getWarehouseName(
                                                      toWarehouseId,
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
                                                  flex: 2,
                                                  child: Text(
                                                    'تم التحويل بنجاح ✅',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                    ),
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
                  child: _selectedTransfer == null
                      ? Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_shipping_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'الرجاء اختيار إذن تحويل من القائمة اليسرى لعرض كامل تفاصيل مستودعات الشحن والبنود والكميات المنقولة.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : TransferDetailPanel(
                          transaction: _selectedTransfer!,
                          allTransactions: state.transactions,
                          orders: state.allOrders,
                          batches: state.batches,
                          warehouses: state.warehouses,
                          inventoryItems: [], // state.inventoryItems,
                          categories: _categories,
                          onDelete: (fromId, toId) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'عكس وإلغاء عملية التحويل ⚠️',
                                ),
                                content: const Text(
                                  'هل أنت متأكد من رغبتك في إلغاء عملية النقل والتحويل هذه وإعادة توازن مخزون المستودعات تلقائياً؟',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      bloc.add(
                                        DeleteTransferEvent(fromId, toId),
                                      );
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                      foregroundColor:
                                          theme.colorScheme.onError,
                                    ),
                                    child: const Text('تأكيد الإلغاء والعكس'),
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
