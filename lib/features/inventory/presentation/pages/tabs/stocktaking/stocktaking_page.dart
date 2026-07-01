import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/inventory/presentation/blocs/stocktaking/stocktaking_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/stocktaking/stocktaking_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/stocktaking/stocktaking_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class StocktakingPage extends StatefulWidget {
  const StocktakingPage({super.key});

  @override
  State<StocktakingPage> createState() => _StocktakingPageState();
}

class _StocktakingPageState extends State<StocktakingPage> {
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

  String _getInventoryName(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id).categoryName;
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

    return BlocProvider<StocktakingBloc>(
      create: (context) =>
          sl<StocktakingBloc>()..add(const LoadStocktakingEvent()),
      child: BlocConsumer<StocktakingBloc, StocktakingState>(
        listener: (context, state) {
          if (state.status == StocktakingStatus.error &&
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
          final bloc = context.read<StocktakingBloc>();

          if (state.status == StocktakingStatus.loading || _isLoadingMetaData) {
            return const Center(child: fluent.ProgressRing());
          }

          // Apply client filters
          final filteredItems = state.items.where((item) {
            final name = _getInventoryName(item.categoryId).toLowerCase();
            final matchesSearch = name.contains(_searchQuery.toLowerCase());
            final matchesWarehouse =
                _filterWarehouseId == null ||
                item.storeId == _filterWarehouseId;
            return matchesSearch && matchesWarehouse;
          }).toList();

          // Calculate summary stats
          int matchCount = 0;
          int surplusCount = 0;
          int shortageCount = 0;

          for (var item in filteredItems) {
            final book = item.countUnits;
            final actual = state.actualCounts[item.categoryId] ?? book;
            final diff = actual - book;

            if (diff == 0) {
              matchCount++;
            } else if (diff > 0) {
              surplusCount++;
            } else {
              shortageCount++;
            }
          }

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
                    // Search & Filters bar
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
                        OutlinedButton.icon(
                          onPressed: () {
                            bloc.add(const LoadStocktakingEvent());
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          icon: const fluent.Icon(fluent.FluentIcons.sync),
                          label: const fluent.Text('إعادة تحميل القياسات'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Table with editable counts
                    Expanded(
                      child: filteredItems.isEmpty
                          ? const Center(
                              child: fluent.Text(
                                'لا توجد أصناف مخزنية جارية ⚠️',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : TableWidget<InventoryEntity>(
                              columns: const {
                                0: FlexTableWidgetColumnWidth(2),
                                1: FlexTableWidgetColumnWidth(1),
                                2: FlexTableWidgetColumnWidth(1),
                                3: FlexTableWidgetColumnWidth(1),
                                4: FlexTableWidgetColumnWidth(1),
                                5: FlexTableWidgetColumnWidth(1),
                              },
                              header: const [
                                'اسم صنف المخزون 📦',
                                'المستودع الرئيسي 🏢',
                                'الكمية الدفترية 📘',
                                'الكمية الفعلية ✏️',
                                'الفارق الحسابي 🔢',
                                'الحالة 💡',
                              ],
                              items: filteredItems,
                              builder: (context, item, index) {
                                final book = item.countUnits;
                                final actual =
                                    state.actualCounts[item.categoryId] ??
                                        book;
                                final diff = actual - book;

                                String statusLabel = "مطابق ✅";
                                Color statusColor = Colors.green;
                                if (diff > 0) {
                                  statusLabel = "فائض 📈";
                                  statusColor = Colors.blue;
                                } else if (diff < 0) {
                                  statusLabel = "عجز ⚠️";
                                  statusColor = Colors.red;
                                }

                                return [
                                  fluent.Text(
                                    _getInventoryName(item.categoryId),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  fluent.Text(
                                    _getWarehouseName(
                                      item.storeId,
                                      state.warehouses,
                                    ),
                                  ),
                                  fluent.Text(
                                    book.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextFormField(
                                    initialValue: actual.toString(),
                                    keyboardType:
                                        const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration:
                                        const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      final num =
                                          double.tryParse(val) ?? book;
                                      bloc.add(
                                        UpdateActualCountEvent(
                                          item.categoryId,
                                          num,
                                        ),
                                      );
                                    },
                                  ),
                                  fluent.Text(
                                    diff == 0
                                        ? '0.0'
                                        : (diff > 0
                                              ? '+$diff'
                                              : '$diff'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  fluent.Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ];
                              },
                            ),
                    ),
                    const Divider(height: 24),

                    // Stats Footer summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withAlpha(80),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatSummary(
                            'أصناف مطابقة ✅',
                            matchCount,
                            Colors.green,
                          ),
                          _buildStatSummary(
                            'أصناف بها فائض 📈',
                            surplusCount,
                            Colors.blue,
                          ),
                          _buildStatSummary(
                            'أصناف بها عجز ⚠️',
                            shortageCount,
                            Colors.red,
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

  Widget _buildStatSummary(String label, int val, Color color) {
    return Column(
      children: [
        fluent.Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        fluent.Text(
          val.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }
}
