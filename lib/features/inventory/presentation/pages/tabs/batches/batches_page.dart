import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_batch_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/inventory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/inventory/presentation/blocs/batches/batches_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/batches/batches_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/batches/batches_state.dart';
import 'package:flowcash/core/enums/batch_status_enum.dart';

import 'batch_form_dialog.dart';
import 'batch_detail_panel.dart';

class BatchesPage extends StatefulWidget {
  const BatchesPage({super.key});

  @override
  State<BatchesPage> createState() => _BatchesPageState();
}

class _BatchesPageState extends State<BatchesPage> {
  // Local filter states
  String _searchQuery = "";
  int? _filterInventoryId;
  BatchStatus? _filterStatus;

  // Fully loaded category reference lists for labels
  List<CategoryEntity> _categories = [];
  bool _isLoadingMetaData = true;

  // Selected batch tracked locally
  InventoryBatchEntity? _selectedBatch;

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

  String _getInventoryItemName(int id, List<InventoryEntity> items) {
    try {
      final item = items.firstWhere((i) => i.id == id);
      return _categories.firstWhere((c) => c.id == item.categoryId).categoryName;
    } catch (_) {
      return 'صنف (#$id)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<BatchesBloc>(
      create: (context) => sl<BatchesBloc>()..add(const LoadBatchesEvent()),
      child: BlocConsumer<BatchesBloc, BatchesState>(
        listener: (context, state) {
          if (state.status == BatchesStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final bloc = context.read<BatchesBloc>();

          if (state.status == BatchesStatus.loading || _isLoadingMetaData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Apply client-side search & filtering
          final filteredBatches = state.batches.where((b) {
            final batchNumLower = b.batchNumber.toLowerCase();
            final itemNameLower = _getInventoryItemName(b.inventoryId, state.inventoryItems).toLowerCase();
            
            final matchesSearch = batchNumLower.contains(_searchQuery.toLowerCase()) || 
                                 itemNameLower.contains(_searchQuery.toLowerCase());
            final matchesInventory = _filterInventoryId == null || b.inventoryId == _filterInventoryId;
            final matchesStatus = _filterStatus == null || b.batchStatus == _filterStatus;
            
            return matchesSearch && matchesInventory && matchesStatus;
          }).toList();

          // Sync local selection if deleted/updated
          if (_selectedBatch != null) {
            final exists = state.batches.any((b) => b.id == _selectedBatch!.id);
            if (!exists) {
              _selectedBatch = null;
            } else {
              _selectedBatch = state.batches.firstWhere((b) => b.id == _selectedBatch!.id);
            }
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // MASTER PANEL (Left Side - List)
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
                          // Search & Filters row
                          Row(
                            children: [
                              // Search input
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'البحث برقم الدفعة أو اسم الصنف... 🔍',
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

                              // Status filter
                              Expanded(
                                child: DropdownButtonFormField<BatchStatus?>(
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    hintText: 'كل الحالات ✅',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  value: _filterStatus,
                                  items: [
                                    const DropdownMenuItem<BatchStatus?>(
                                      value: null,
                                      child: Text('كل الحالات ✅'),
                                    ),
                                    ...BatchStatus.values.map((status) {
                                      return DropdownMenuItem<BatchStatus?>(
                                        value: status,
                                        child: Text(status.displayName()),
                                      );
                                    }),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      _filterStatus = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Add Batch button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (state.inventoryItems.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('الرجاء إنشاء أصناف مخزون أولاً')),
                                    );
                                    return;
                                  }
                                  final result = await showDialog<InventoryBatchEntity>(
                                    context: context,
                                    builder: (context) => BatchFormDialog(
                                      inventoryItems: state.inventoryItems,
                                    ),
                                  );
                                  if (result != null) {
                                    bloc.add(AddBatchEvent(result));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.add_box_outlined),
                                label: const Text('إضافة دفعة', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Expanded(child: Text('رقم الدفعة 🏷️', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(flex: 2, child: Text('اسم صنف المخزون 📦', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(child: Text('المصدر 📥', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(child: Text('الكمية 🔢', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(child: Text('التكلفة (الوحدة) 💰', style: TextStyle(fontWeight: FontWeight.bold))),
                                Expanded(child: Text('الحالة ✅', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Batches List
                          Expanded(
                            child: filteredBatches.isEmpty
                                ? const Center(
                                    child: Text(
                                      'لا توجد دفعات تطابق معايير البحث ⚠️',
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: filteredBatches.length,
                                    itemBuilder: (context, index) {
                                      final b = filteredBatches[index];
                                      final isSelected = _selectedBatch?.id == b.id;

                                      return Card(
                                        color: isSelected
                                            ? theme.colorScheme.secondary.withAlpha(20)
                                            : null,
                                        elevation: isSelected ? 2 : 0,
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: isSelected
                                                ? theme.colorScheme.secondary
                                                : Colors.transparent,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () {
                                            setState(() {
                                              _selectedBatch = isSelected ? null : b;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    b.batchNumber,
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(_getInventoryItemName(b.inventoryId, state.inventoryItems)),
                                                ),
                                                Expanded(
                                                  child: Text(b.batchSource.displayName()),
                                                ),
                                                Expanded(
                                                  child: Text(b.countUnits.toString()),
                                                ),
                                                Expanded(
                                                  child: Text('${b.unitCost.toStringAsFixed(2)} SAR'),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    b.batchStatus.displayName(),
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: b.batchStatus == BatchStatus.available
                                                          ? Colors.green
                                                          : Colors.red,
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
                  child: _selectedBatch == null
                      ? Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.all_inbox_outlined, size: 48, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'الرجاء اختيار دفعة من القائمة اليسرى لعرض كامل تفاصيل الكميات والأسعار وتواريخ الصلاحية.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : BatchDetailPanel(
                          batch: _selectedBatch!,
                          inventoryItems: state.inventoryItems,
                          categories: _categories,
                          onEdit: () async {
                            final result = await showDialog<InventoryBatchEntity>(
                              context: context,
                              builder: (context) => BatchFormDialog(
                                batch: _selectedBatch,
                                inventoryItems: state.inventoryItems,
                              ),
                            );
                            if (result != null) {
                              bloc.add(UpdateBatchEvent(result));
                            }
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('تأكيد حذف الدفعة ⚠️'),
                                content: const Text('هل أنت متأكد من رغبتك في حذف بطاقة الدفعة هذه نهائياً؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      bloc.add(DeleteBatchEvent(_selectedBatch!.id));
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                      foregroundColor: theme.colorScheme.onError,
                                    ),
                                    child: const Text('حذف الدفعة'),
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
