import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/goods_cost_entity.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/inventory/presentation/blocs/goods_cost/goods_cost_bloc.dart';
import 'package:flowcash/features/inventory/presentation/blocs/goods_cost/goods_cost_event.dart';
import 'package:flowcash/features/inventory/presentation/blocs/goods_cost/goods_cost_state.dart';

import 'goods_cost_form_dialog.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

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
          if (state.status == GoodsCostStatus.error &&
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
          final bloc = context.read<GoodsCostBloc>();

          if (state.status == GoodsCostStatus.loading) {
            return const Center(child: fluent.ProgressRing());
          }

          // Apply client filters
          final filteredCosts = state.costs.where((c) {
            final billStr = c.billNumber.toString();
            final noteStr = (c.note ?? "").toLowerCase();
            final matchesSearch =
                billStr.contains(_searchQuery) ||
                noteStr.contains(_searchQuery.toLowerCase());
            final matchesWarehouse =
                _filterWarehouseId == null ||
                c.warehouseId == _filterWarehouseId;
            return matchesSearch && matchesWarehouse;
          }).toList();

          final double grandTotalCost = filteredCosts.fold(
            0.0,
            (sum, cost) => sum + cost.offerAmount,
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
                    // Search & Action bar
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'البحث برقم السند أو البيان... 🔍',
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
                                'تسجيل تكلفة',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
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
                        color: theme.colorScheme.secondaryContainer.withAlpha(
                          50,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            child: fluent.Text(
                              'رقم السند 🧾',
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
                              'مبلغ التكلفة 💰',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: fluent.Text(
                              'العملة 💱',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: fluent.Text(
                              'تاريخ الإصدار 📅',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: fluent.Text(
                              'البيان والملاحظات 📝',
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
                      child: filteredCosts.isEmpty
                          ? const Center(
                              child: fluent.Text(
                                'لا توجد قيود تكاليف بضائع مسجلة ⚠️',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCosts.length,
                              itemBuilder: (context, index) {
                                final cost = filteredCosts[index];
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
                                          child: fluent.Text(
                                            '#${cost.billNumber}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: fluent.Text(
                                            _getWarehouseName(
                                              cost.warehouseId,
                                              state.warehouses,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: fluent.Text(
                                            '${cost.offerAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: fluent.Text(cost.currencyId),
                                        ),
                                        Expanded(
                                          child: fluent.Text(
                                            _formatDate(cost.createdAt),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: fluent.Text(
                                            cost.note ?? '──',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                                                      'حذف قيد التكلفة ⚠️',
                                                    ),
                                                    content: const fluent.Text(
                                                      'هل أنت متأكد من رغبتك في حذف قيد تكلفة البضاعة هذا؟',
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
                                                            DeleteGoodsCostEvent(
                                                              cost.id,
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

                    // Cost Footer
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
                            'إجمالي تكاليف البضاعة المباعة الكلي:',
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
