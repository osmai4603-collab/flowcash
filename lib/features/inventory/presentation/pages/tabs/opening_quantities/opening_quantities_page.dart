import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/opening_quantity_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/opening_quantities/opening_quantities_state.dart';

import 'opening_quantity_form_dialog.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class OpeningQuantitiesPage extends StatefulWidget {
  const OpeningQuantitiesPage({super.key});

  @override
  State<OpeningQuantitiesPage> createState() => _OpeningQuantitiesPageState();
}

class _OpeningQuantitiesPageState extends State<OpeningQuantitiesPage> {
  String _searchQuery = "";
  int? _filterWarehouseId;

  final bool _isLoadingMetaData = false;

  String _getInventoryName(int inventoryId, List<InventoryEntity> items) {
    try {
      final item = items.firstWhere((i) => i.id == inventoryId);
      return item.inventoryName;
    } catch (_) {
      return 'صنف (#$inventoryId)';
    }
  }

  int? _getInventoryWarehouseId(int inventoryId, List<InventoryEntity> items) {
    try {
      return items.firstWhere((i) => i.id == inventoryId).storeId;
    } catch (_) {
      return null;
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
      create: (context) =>
          sl<OpeningQuantitiesBloc>()..add(const LoadOpeningQuantitiesEvent()),
      child: BlocConsumer<OpeningQuantitiesBloc, OpeningQuantitiesState>(
        listener: (context, state) {
          if (state.status == OpeningQuantitiesStatus.error &&
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
          final bloc = context.read<OpeningQuantitiesBloc>();

          if (state.status == OpeningQuantitiesStatus.loading ||
              _isLoadingMetaData) {
            return const Center(child: fluent.ProgressRing());
          }

          // Apply client filters
          final filteredItems = state.items.where((i) {
            final nameLower = _getInventoryName(
              i.inventoryId,
              state.inventoryItems,
            ).toLowerCase();
            final matchesSearch = nameLower.contains(
              _searchQuery.toLowerCase(),
            );
            final matchesWarehouse =
                _filterWarehouseId == null ||
                _getInventoryWarehouseId(i.inventoryId, state.inventoryItems) ==
                    _filterWarehouseId;
            return matchesSearch && matchesWarehouse;
          }).toList();

          final double grandTotalCost = filteredItems.fold(
            0.0,
            (sum, item) => sum + item.costTotal,
          );

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                            onChanged: (val) =>
                                setState(() => _searchQuery = val),
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
                                      onPressed: () => setState(
                                        () => _filterWarehouseId = null,
                                      ),
                                      child: const fluent.Text('كل المخازن 🏢'),
                                    ),
                                    ...state.warehouses.map(
                                      (w) => MenuItemButton(
                                        onPressed: () => setState(
                                          () => _filterWarehouseId = w.id,
                                        ),
                                        child: fluent.Text(w.warehouseName),
                                      ),
                                    ),
                                  ],
                                  child: fluent.Text(
                                    _filterWarehouseId == null
                                        ? 'كل المخازن 🏢'
                                        : state.warehouses
                                              .where(
                                                (w) =>
                                                    w.id == _filterWarehouseId,
                                              )
                                              .isEmpty
                                        ? 'كل المخازن 🏢'
                                        : state.warehouses
                                              .where(
                                                (w) =>
                                                    w.id == _filterWarehouseId,
                                              )
                                              .first
                                              .warehouseName,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        fluent.FilledButton(
child: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    const fluent.Icon(fluent.FluentIcons.add),
    const SizedBox(width: 8.0),
    const fluent.Text(
                            'رصيد جديد',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
  ],
),
onPressed: () async {
                            if (state.inventoryItems.isEmpty) {
                              fluent.displayInfoBar(
                                context,
                                builder: (context, close) => fluent.InfoBar(
                                  title: const fluent.Text('تنبيه'),
                                  content: fluent.Text(
                                    'الرجاء إنشاء أصناف مخزون أولاً',
                                  ),
                                ),
                              );
                              return;
                            }
                            final result =
                                await showDialog<OpeningQuantityEntity>(
                                  context: context,
                                  builder: (context) =>
                                      OpeningQuantityFormDialog(
                                        inventoryItems: state.inventoryItems,
                                      ),
                                );
                            if (result != null) {
                              bloc.add(AddOpeningQuantityEvent(result));
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
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: fluent.Text(
                              'اسم صنف المخزون 📦',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: fluent.Text(
                              'المستودع الرئيسي 🏢',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: fluent.Text(
                              'الكمية الافتتاحية 🔢',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: fluent.Text(
                              'إجمالي التكلفة الدفترية 💰',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: fluent.Text(
                              'السنة/الفترة المالية 📅',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: fluent.Text(
                              'الإجراءات ⚙️',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Table Rows
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: fluent.Text(
                                'لا توجد أرصدة افتتاحية مسجلة ⚠️',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withAlpha(20),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: fluent.Text(
                                            _getInventoryName(
                                              item.inventoryId,
                                              state.inventoryItems,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: fluent.Text(
                                            _getWarehouseName(
                                              _getInventoryWarehouseId(
                                                    item.inventoryId,
                                                    state.inventoryItems,
                                                  ) ??
                                                  0,
                                              state.warehouses,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: fluent.Text(
                                            item.countUnits.toString(),
                                          ),
                                        ),
                                        Expanded(
                                          child: fluent.Text(
                                            '${item.costTotal.toStringAsFixed(2)} SAR',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: fluent.Text(
                                            'فترة #${item.periodId}',
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: fluent.IconButton(
                                              icon: const fluent.Icon(
                                                fluent.FluentIcons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => fluent.ContentDialog(
                                                    title: const fluent.Text(
                                                      'حذف الرصيد الافتتاحي ⚠️',
                                                    ),
                                                    content: const fluent.Text(
                                                      'هل أنت متأكد من رغبتك في حذف هذا الرصيد الافتتاحي؟',
                                                    ),
                                                    actions: [
                                                      fluent.Button(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child:
                                                            const fluent.Text(
                                                              'إلغاء',
                                                            ),
                                                      ),
                                                      fluent.FilledButton(
                                                        onPressed: () {
                                                          bloc.add(
                                                            DeleteOpeningQuantityEvent(
                                                              item.id,
                                                            ),
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child:
                                                            const fluent.Text(
                                                              'تأكيد الحذف',
                                                            ),
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
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(80),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const fluent.Text(
                            'إجمالي قيمة الأرصدة الافتتاحية للمخزون:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          fluent.Text(
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
