import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/inventory/presentation/blocs/stocktaking/stocktaking_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/stocktaking/stocktaking_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/stocktaking/stocktaking_state.dart';

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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<StocktakingBloc>();

          if (state.status == StocktakingStatus.loading || _isLoadingMetaData) {
            return const Center(child: CircularProgressIndicator());
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
                              prefixIcon: const Icon(Icons.search),
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
                          child: DropdownButtonFormField<int?>(
                            decoration: InputDecoration(
                              hintText: 'كل المخازن 🏢',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            initialValue: _filterWarehouseId,
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('كل المخازن 🏢'),
                              ),
                              ...state.warehouses.map((w) {
                                return DropdownMenuItem<int?>(
                                  value: w.id,
                                  child: Text(w.warehouseName),
                                );
                              }),
                            ],
                            onChanged: (val) =>
                                setState(() => _filterWarehouseId = val),
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
                          icon: const Icon(Icons.sync),
                          label: const Text('إعادة تحميل القياسات'),
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
                            child: Text(
                              'اسم صنف المخزون 📦',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'المستودع الرئيسي 🏢',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'الكمية الدفترية 📘',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'الكمية الفعلية ✏️',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'الفارق الحسابي 🔢',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'الحالة 💡',
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
                              child: Text(
                                'لا توجد أصناف مخزنية جارية ⚠️',
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
                                final book = item.countUnits;
                                final actual =
                                    state.actualCounts[item.categoryId] ?? book;
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
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        // Category Name
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            _getInventoryName(item.categoryId),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        // Warehouse
                                        Expanded(
                                          child: Text(
                                            _getWarehouseName(
                                              item.storeId,
                                              state.warehouses,
                                            ),
                                          ),
                                        ),

                                        // Book count
                                        Expanded(
                                          child: Text(
                                            book.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        // Editable Actual Count
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 32.0,
                                            ),
                                            child: TextFormField(
                                              initialValue: actual.toString(),
                                              keyboardType:
                                                  const TextInputType.numberWithOptions(
                                                    decimal: true,
                                                  ),
                                              decoration: const InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                
                                              ),
                                              onChanged: (val) {
                                                final num =
                                                    double.tryParse(val) ??
                                                    book;
                                                bloc.add(
                                                  UpdateActualCountEvent(
                                                    item.categoryId,
                                                    num,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),

                                        // Difference
                                        Expanded(
                                          child: Text(
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
                                        ),

                                        // Status
                                        Expanded(
                                          child: Text(
                                            statusLabel,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
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
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
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
