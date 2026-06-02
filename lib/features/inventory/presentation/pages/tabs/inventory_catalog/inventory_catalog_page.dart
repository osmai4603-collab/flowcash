import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/accounts/domain/entities/sub_account_entity.dart';
import 'package:flowcash/features/inventory/presentation/blocs/inventory_catalog/inventory_catalog_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/inventory_catalog/inventory_catalog_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/inventory_catalog/inventory_catalog_state.dart';
import 'package:flowcash/core/enums/inventory_cost_type_enum.dart';
import 'package:flowcash/features/inventory/domain/usecases/warehouse_usecases.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/accounts/domain/usecases/sub_account_repository_usecases.dart';

import 'inventory_item_form_dialog.dart';
import 'inventory_item_detail_panel.dart';

class InventoryCatalogPage extends StatefulWidget {
  const InventoryCatalogPage({super.key});

  @override
  State<InventoryCatalogPage> createState() => _InventoryCatalogPageState();
}

class _InventoryCatalogPageState extends State<InventoryCatalogPage> {
  // Local filter states
  String _searchQuery = "";
  int? _filterWarehouseId;
  InventoryCostType? _filterCostType;

  // Fully loaded reference lists for labels
  List<CategoryEntity> _categories = [];
  List<WarehouseEntity> _warehouses = [];
  List<SubAccountEntity> _subAccounts = [];
  bool _isLoadingMetaData = true;

  // Selected item locally tracked
  InventoryEntity? _selectedItem;

  @override
  void initState() {
    super.initState();
    _loadMetaData();
  }

  Future<void> _loadMetaData() async {
    try {
      final categoriesRes = await sl<GetAllCategoriesUseCase>().call();
      final warehousesRes = await sl<GetWarehousesUseCase>().call();
      final subAccountsRes = await sl<GetSubAccountsUseCase>().call();

      if (mounted) {
        setState(() {
          categoriesRes.fold((_) => null, (list) => _categories = list);
          warehousesRes.fold((_) => null, (list) => _warehouses = list);
          subAccountsRes.fold((_) => null, (list) => _subAccounts = list);
          _isLoadingMetaData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMetaData = false;
        });
      }
    }
  }

  String _getCategoryName(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id).categoryName;
    } catch (_) {
      return 'صنف (#$id)';
    }
  }

  String _getWarehouseName(int id) {
    try {
      return _warehouses.firstWhere((w) => w.id == id).warehouseName;
    } catch (_) {
      return 'مستودع (#$id)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<InventoryCatalogBloc>(
      create: (context) => sl<InventoryCatalogBloc>()..add(const LoadInventoryCatalogEvent()),
      child: BlocConsumer<InventoryCatalogBloc, InventoryCatalogState>(
        listener: (context, state) {
          if (state.status == CatalogStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<InventoryCatalogBloc>();

          if (state.status == CatalogStatus.loading || _isLoadingMetaData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Apply client-side search & filtering
          final filteredItems = state.items.where((item) {
            final categoryName = _getCategoryName(item.categoryId).toLowerCase();
            final matchesSearch = categoryName.contains(_searchQuery.toLowerCase());
            final matchesWarehouse = _filterWarehouseId == null || item.storeId == _filterWarehouseId;
            final matchesCostType = _filterCostType == null || item.costType == _filterCostType;
            return matchesSearch && matchesWarehouse && matchesCostType;
          }).toList();

          // Sync local selection if deleted/updated
          if (_selectedItem != null) {
            final exists = state.items.any((i) => i.id == _selectedItem!.id);
            if (!exists) {
              _selectedItem = null;
            } else {
              _selectedItem = state.items.firstWhere((i) => i.id == _selectedItem!.id);
            }
          }

          // Desktop master-detail layout
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Actions header: Search & Filters & Add Button
                          Row(
                            children: [
                              // Search input
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'البحث عن صنف مخزون... 🔍',
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Warehouse Filter
                              Expanded(
                                child: DropdownButtonFormField<int?>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    hintText: 'كل المخازن 🏢',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  value: _filterWarehouseId,
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('كل المخازن 🏢'),
                                    ),
                                    ..._warehouses.map((w) {
                                      return DropdownMenuItem<int?>(
                                        value: w.id,
                                        child: Text(w.warehouseName),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _filterWarehouseId = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Add item button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await showDialog<InventoryEntity>(
                                    context: context,
                                    builder: (context) => const InventoryItemFormDialog(),
                                  );
                                  if (result != null) {
                                    bloc.add(AddInventoryItemEvent(result));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('إضافة صنف', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Header Row / Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 2, child: Text('اسم الصنف 📦', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(child: Text('المستودع الرئيسي 🏢', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(child: Text('طريقة التسعير 💰', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(child: Text('الوحدات 🔢', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Items List
                          Expanded(
                            child: filteredItems.isEmpty
                                ? const Center(
                                    child: Text(
                                      'لا توجد أصناف تطابق معايير البحث ⚠️',
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      final isSelected = _selectedItem?.id == item.id;

                                      return Card(
                                        color: isSelected
                                            ? theme.colorScheme.primary.withAlpha(20)
                                            : null,
                                        elevation: isSelected ? 2 : 0,
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () {
                                            setState(() {
                                              _selectedItem = isSelected ? null : item;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    _getCategoryName(item.categoryId),
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(_getWarehouseName(item.storeId)),
                                                ),
                                                Expanded(
                                                  child: Text(item.costType.name),
                                                ),
                                                Expanded(
                                                  child: Text(item.countUnits.toString()),
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
                  child: _selectedItem == null
                      ? Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 48, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'الرجاء اختيار صنف من القائمة اليسرى لعرض كامل التفاصيل والحسابات المرتبطة.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : InventoryItemDetailPanel(
                          item: _selectedItem!,
                          categories: _categories,
                          warehouses: _warehouses,
                          subAccounts: _subAccounts,
                          onEdit: () async {
                            final result = await showDialog<InventoryEntity>(
                              context: context,
                              builder: (context) => InventoryItemFormDialog(item: _selectedItem),
                            );
                            if (result != null) {
                              bloc.add(UpdateInventoryItemEvent(result));
                            }
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('تأكيد الحذف ⚠️'),
                                content: const Text('هل أنت متأكد من رغبتك في حذف بطاقة صنف المخزون هذه؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      bloc.add(DeleteInventoryItemEvent(_selectedItem!.id));
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                      foregroundColor: theme.colorScheme.onError,
                                    ),
                                    child: const Text('حذف الصنف'),
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
