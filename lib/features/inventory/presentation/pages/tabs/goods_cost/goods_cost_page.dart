import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/presentation/blocs/goods_cost/goods_cost_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/goods_cost/goods_cost_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/goods_cost/goods_cost_state.dart';

import 'goods_cost_form_dialog.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, FluentIcons, InfoBar, ProgressRing, displayInfoBar;
class GoodsCostPage extends StatefulWidget {
  const GoodsCostPage({super.key});

  @override
  State<GoodsCostPage> createState() => _GoodsCostPageState();
}

class _GoodsCostPageState extends State<GoodsCostPage> {
  String _searchQuery = "";
  int? _filterWarehouseId;

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

    return BlocProvider<GoodsCostBloc>(
      create: (context) => sl<GoodsCostBloc>()..add(const LoadGoodsCostEvent()),
      child: BlocConsumer<GoodsCostBloc, GoodsCostState>(
        listener: (context, state) {
          if (state.status == GoodsCostStatus.error && state.errorMessage != null) {
            displayInfoBar(context, builder: (context, close) => InfoBar(title: const Text('تنبيه'), content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          final bloc = context.read<GoodsCostBloc>();

          if (state.status == GoodsCostStatus.loading) {
            return const Center(child: ProgressRing());
          }

          // Apply client filters
          final filteredCosts = state.costs.where((c) {
            final billStr = c.billNumber.toString();
            final noteStr = (c.note ?? "").toLowerCase();
            final matchesSearch = billStr.contains(_searchQuery) || noteStr.contains(_searchQuery.toLowerCase());
            final matchesWarehouse = _filterWarehouseId == null || c.warehouseId == _filterWarehouseId;
            return matchesSearch && matchesWarehouse;
          }).toList();

          final double grandTotalCost = filteredCosts.fold(0.0, (sum, cost) => sum + cost.offerAmount);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search & Action bar
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'البحث برقم السند أو البيان... 🔍',
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
                            final result = await showDialog<GoodsCostEntity>(
                              context: context,
                              builder: (context) => GoodsCostFormDialog(
                                warehouses: state.warehouses,
                              ),
                            );
                            if (result != null) {
                              bloc.add(AddGoodsCostEvent(result));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          ),
                          icon: const Icon(FluentIcons.add),
                          label: const Text('تسجيل تكلفة', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Expanded(child: Text('رقم السند 🧾', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('المستودع الرئيسي 🏢', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('مبلغ التكلفة 💰', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('العملة 💱', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('تاريخ الإصدار 📅', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('البيان والملاحظات 📝', style: TextStyle(fontWeight: FontWeight.bold))),
                          Expanded(child: Text('الإجراءات ⚙️', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Table Rows
                    Expanded(
                      child: filteredCosts.isEmpty
                          ? const Center(
                              child: Text(
                                'لا توجد قيود تكاليف بضائع مسجلة ⚠️',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCosts.length,
                              itemBuilder: (context, index) {
                                final cost = filteredCosts[index];
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
                                          child: Text(
                                            '#${cost.billNumber}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(_getWarehouseName(cost.warehouseId, state.warehouses)),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${cost.offerAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(cost.currencyId),
                                        ),
                                        Expanded(
                                          child: Text(_formatDate(cost.createdAt)),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(cost.note ?? '──', maxLines: 1, overflow: TextOverflow.ellipsis),
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
                                                    title: const Text('حذف قيد التكلفة ⚠️'),
                                                    content: const Text('هل أنت متأكد من رغبتك في حذف قيد تكلفة البضاعة هذا؟'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('إلغاء'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          bloc.add(DeleteGoodsCostEvent(cost.id));
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

                    // Cost Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي تكاليف البضاعة المباعة الكلي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
