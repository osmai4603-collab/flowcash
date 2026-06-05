import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_state.dart';

import 'opening_quantity_form_dialog.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, FluentIcons, InfoBar, ProgressRing, displayInfoBar;
class OpeningQuantitiesPage extends StatefulWidget {
  const OpeningQuantitiesPage({super.key});

  @override
  State<OpeningQuantitiesPage> createState() => _OpeningQuantitiesPageState();
}

class _OpeningQuantitiesPageState extends State<OpeningQuantitiesPage> {
  String _searchQuery = "";
  int? _filterWarehouseId;

  List<CategoryEntity> _categories = [];
  bool _isLoadingMetaData = true;

  @override
  void initState() {
    super.initState();
    _loadMetaData();
  }

  Future<void> _loadMetaData() async {
    try {
      final res = await sl<GetAllCategoriesUseCase>().call();
      if (mounted) {
        setState(() {
          res.fold((_) => null, (list) => _categories = list);
          _isLoadingMetaData = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingMetaData = false);
      }
    }
  }

  String _getInventoryName(int id, List<InventoryEntity> items) {
    try {
      final item = items.firstWhere((i) => i.id == id);
      return _categories.firstWhere((c) => c.id == item.categoryId).categoryName;
    } catch (_) {
      return 'صنف (#$id)';
    }
  }

  String _getWarehouseName(int id, List<WarehouseEntity> warehouses) {
    try {
      return warehouses.firstWhere((w) => w.id == id).warehouseName;
    } catch (_) {
      return 'مستودع (#$id)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<OpeningQuantitiesBloc>(
      create: (context) => sl<OpeningQuantitiesBloc>()..add(const LoadOpeningQuantitiesEvent()),
      child: BlocConsumer<OpeningQuantitiesBloc, OpeningQuantitiesState>(
        listener: (context, state) {
          if (state.status == OpeningQuantitiesStatus.error && state.errorMessage != null) {
            displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final bloc = context.read<OpeningQuantitiesBloc>();

          if (state.status == OpeningQuantitiesStatus.loading || _isLoadingMetaData) {
            return const Center(child: ProgressRing());
          }

          // Apply client filters
          final filteredItems = state.items.where((i) {
            final nameLower = _getInventoryName(i.categoryId, state.inventoryItems).toLowerCase();
            final matchesSearch = nameLower.contains(_searchQuery.toLowerCase());
            final matchesWarehouse = _filterWarehouseId == null || i.warehouseId == _filterWarehouseId;
            return matchesSearch && matchesWarehouse;
          }).toList();

          final double grandTotalCost = filteredItems.fold(0.0, (sum, item) => sum + item.costTotal);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Filter bar
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'البحث باسم صنف المخزون... 🔍',
                              prefixIcon: const Icon(FluentIcons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: MenuBar(
                              children: [
                                SubmenuButton(
                                  menuChildren: [
                                    MenuItemButton(
                                      onPressed: () => setState(() => _filterWarehouseId = null),
                                      child: const Text('كل المخازن 🏢'),
                                    ),
                                    ...state.warehouses.map(
                                      (w) => MenuItemButton(
                                        onPressed: () => setState(() => _filterWarehouseId = w.id),
                                        child: Text(w.warehouseName),
                                      ),
                                    ),
                                  ],
                                  child: Text(
                                    _filterWarehouseId == null
                                        ? 'كل المخازن 🏢'
                                        : state.warehouses.where((w) => w.id == _filterWarehouseId).isEmpty
                                            ? 'كل المخازن 🏢'
                                            : state.warehouses.where((w) => w.id == _filterWarehouseId).first.warehouseName,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (state.inventoryItems.isEmpty) {
                              displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text('الرجاء إنشاء أصناف مخزون أولاً')));
                              return;
                            }
                            final result = await showDialog<OpeningQuantityEntity>(
                              context: context,
                              builder: (context) => OpeningQuantityFormDialog(
                                inventoryItems: state.inventoryItems,
                                warehouses: state.warehouses,
                              ),
                            );
                            if (result != null) {
                              bloc.add(AddOpeningQuantityEvent(result));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          icon: const Icon(FluentIcons.add),
                          label: const Text('رصيد جديد', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('اسم صنف المخزون 📦', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('المستودع الرئيسي 🏢', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('الكمية الافتتاحية 🔢', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('إجمالي التكلفة الدفترية 💰', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('السنة/الفترة المالية 📅', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('الإجراءات ⚙️', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Table Rows
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد أرصدة افتتاحية مسجلة ⚠️',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: theme.colorScheme.outline.withAlpha(20)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            _getInventoryName(item.categoryId, state.inventoryItems),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(_getWarehouseName(item.warehouseId, state.warehouses)),
                                        ),
                                        Expanded(
                                          child: Text(item.countUnits.toString()),
                                        ),
                                        Expanded(
                                          child: Text('${item.costTotal.toStringAsFixed(2)} SAR', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                        Expanded(
                                          child: Text('فترة #${item.periodId}'),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              icon: const Icon(FluentIcons.delete, color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => ContentDialog(
                                                    title: const Text('حذف الرصيد الافتتاحي ⚠️'),
                                                    content: const Text('هل أنت متأكد من رغبتك في حذف هذا الرصيد الافتتاحي؟'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('إلغاء'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          bloc.add(DeleteOpeningQuantityEvent(item.id));
                                                          Navigator.pop(context);
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: theme.colorScheme.error,
                                                          foregroundColor: theme.colorScheme.onError,
                                                        ),
                                                        child: const Text('تأكيد الحذف'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 24),

                    // Sum Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي قيمة الأرصدة الافتتاحية للمخزون:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            '${grandTotalCost.toStringAsFixed(2)} SAR',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
