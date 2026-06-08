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

import 'package:fluent_ui/fluent_ui.dart' as fluent;

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
          final bloc = context.read<WarehouseTransfersBloc>();

          if (state.status == TransfersStatus.loading || _isLoadingMetaData) {
            return const Center(child: fluent.ProgressRing());
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

                              // From Warehouse filter
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: MenuBar(
                                    children: [
                                      SubmenuButton(
                                        menuChildren: [
                                          MenuItemButton(
                                            onPressed: () => setState(
                                              () =>
                                                  _filterFromWarehouseId = null,
                                            ),
                                            child: const fluent.Text(
                                              'من مستودع 📤',
                                            ),
                                          ),
                                          ...state.warehouses.map(
                                            (w) => MenuItemButton(
                                              onPressed: () => setState(
                                                () => _filterFromWarehouseId =
                                                    w.id,
                                              ),
                                              child: fluent.Text(
                                                w.warehouseName,
                                              ),
                                            ),
                                          ),
                                        ],
                                        child: fluent.Text(
                                          _filterFromWarehouseId == null
                                              ? 'من مستودع 📤'
                                              : state.warehouses
                                                    .where(
                                                      (w) =>
                                                          w.id ==
                                                          _filterFromWarehouseId,
                                                    )
                                                    .isEmpty
                                              ? 'من مستودع 📤'
                                              : state.warehouses
                                                    .where(
                                                      (w) =>
                                                          w.id ==
                                                          _filterFromWarehouseId,
                                                    )
                                                    .first
                                                    .warehouseName,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Add Transfer button
                              fluent.FilledButton(
child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const fluent.Icon(
                                  fluent.FluentIcons.shopping_cart,
                                ),
    const SizedBox(width: 8.0),
    const fluent.Text(
                                  'إجراء نقل',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
  ],
),
onPressed: () async {
                                  if (state.batches.isEmpty) {
                                    fluent.displayInfoBar(
                                      context,
                                      builder: (context, close) =>
                                          fluent.InfoBar(
                                            title: const fluent.Text('تنبيه'),
                                            content: fluent.Text(
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
                                              warehouses: state.warehouses,
                                              inventoryItems: state.batches,
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
                                  child: fluent.Text(
                                    'رقم السند 🧾',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: fluent.Text(
                                    'من مستودع (الصادر) 📤',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: fluent.Text(
                                    'إلى مستودع (الوارد) 📥',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: fluent.Text(
                                    'تاريخ العملية 📅',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: fluent.Text(
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
                                    child: fluent.Text(
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
                                                  child: fluent.Text(
                                                    '#${t.billNumber}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: fluent.Text(
                                                    _getWarehouseName(
                                                      t.warehouseId,
                                                      state.warehouses,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: fluent.Text(
                                                    _getWarehouseName(
                                                      toWarehouseId,
                                                      state.warehouses,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: fluent.Text(
                                                    _formatDate(t.createdAt),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: fluent.Text(
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
                                fluent.Icon(
                                  fluent.FluentIcons.shopping_cart,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                fluent.Text(
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
                          warehouses: state.warehouses,
                          inventoryItems: state.batches,
                          categories: _categories,
                          onDelete: (fromId, toId) {
                            showDialog(
                              context: context,
                              builder: (context) => fluent.ContentDialog(
                                title: const fluent.Text(
                                  'عكس وإلغاء عملية التحويل ⚠️',
                                ),
                                content: const fluent.Text(
                                  'هل أنت متأكد من رغبتك في إلغاء عملية النقل والتحويل هذه وإعادة توازن مخزون المستودعات تلقائياً؟',
                                ),
                                actions: [
                                  fluent.Button(
                                    onPressed: () => Navigator.pop(context),
                                    child: const fluent.Text('إلغاء'),
                                  ),
                                  fluent.FilledButton(
                                    onPressed: () {
                                      bloc.add(
                                        DeleteTransferEvent(fromId, toId),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const fluent.Text(
                                      'تأكيد الإلغاء والعكس',
                                    ),
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
