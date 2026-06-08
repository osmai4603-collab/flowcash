import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_bond_entity.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_bonds/financial_bonds_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_bonds/financial_bonds_event.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_bonds/financial_bonds_state.dart';
import 'package:flowcash/widgets/my_text_widget.dart';

// removed fluent_ui dependency from this file; use Material dialogs and icons
class BondsTab extends StatefulWidget {
  const BondsTab({super.key});

  @override
  State<BondsTab> createState() => _BondsTabState();
}

class _BondsTabState extends State<BondsTab> {
  bool _isPaidFilter =
      false; // false = Receipts (proceeds), true = Payments (paids)
  String _searchQuery = '';
  final _searchController = TextEditingController();

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinancialBondsBloc, FinancialBondsState>(
      builder: (context, state) {
        if (state.status == FinancialBondsStatus.loading &&
            state.bonds.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredList = state.bonds.where((b) {
          final isTargetType = _isPaidFilter
              ? b.historyGroup == HistoriesGroup.paids
              : b.historyGroup == HistoriesGroup.proceeds;

          if (!isTargetType) return false;

          if (_searchQuery.isEmpty) return true;
          return b.billNumber.toString().contains(_searchQuery) ||
              (b.note?.contains(_searchQuery) ?? false);
        }).toList();

        return Column(
          children: [
            // Toolbar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Segmented Switch
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: fluent.Text('سندات القبض'),
                        icon: fluent.Icon(Icons.download),
                      ),
                      ButtonSegment(
                        value: true,
                        label: fluent.Text('سندات الصرف'),
                        icon: fluent.Icon(Icons.upload),
                      ),
                    ],
                    selected: {_isPaidFilter},
                    onSelectionChanged: (val) {
                      setState(() {
                        _isPaidFilter = val.first;
                        context.read<FinancialBondsBloc>().add(
                          const SelectFinancialBondEvent(null),
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  // Search
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'البحث عن سند مالي...',
                        prefixIcon: const fluent.Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Add Button
                  fluent.FilledButton(
child: const fluent.Icon(Icons.add),
onPressed: () => _showAddBondContentDialog(context),
label: fluent.Text(
                      _isPaidFilter
                          ? 'إضافة سند صرف جديد'
                          : 'إضافة سند قبض جديد',
                    ),
),
                ],
              ),
            ),

            // Content
            Expanded(
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildList(
                            context,
                            filteredList,
                            state.selectedBond,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: _buildDetailsPanel(
                            context,
                            state.selectedBond,
                          ),
                        ),
                      ],
                    )
                  : _buildList(context, filteredList, state.selectedBond),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    List<FinancialBondEntity> bonds,
    FinancialBondEntity? selected,
  ) {
    if (bonds.isEmpty) {
      return const Center(child: TextWidget(text: 'لا توجد سندات مطابقة'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bonds.length,
      itemBuilder: (context, index) {
        final b = bonds[index];
        final isSelected = b.id == selected?.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected
                ? BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: TextWidget(
              text:
                  '${_isPaidFilter ? "سند صرف" : "سند قبض"} رقم #${b.billNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: fluent.Text(
              'التاريخ: ${b.createdAt.toString().split(' ')[0]} | البيان: ${b.note ?? "بدون بيان"}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                fluent.Text(
                  '${b.offerAmount} \$',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isPaidFilter ? Colors.red : Colors.green,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const fluent.Icon(Icons.arrow_forward, size: 16),
              ],
            ),
            onTap: () {
              context.read<FinancialBondsBloc>().add(
                SelectFinancialBondEvent(b),
              );
              if (!isDesktop) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (blocContext) => Scaffold(
                      appBar: AppBar(
                        title: fluent.Text(
                          '${_isPaidFilter ? "سند صرف" : "سند قبض"} #${b.billNumber}',
                        ),
                      ),
                      body: BlocProvider.value(
                        value: context.read<FinancialBondsBloc>(),
                        child:
                            BlocBuilder<
                              FinancialBondsBloc,
                              FinancialBondsState
                            >(
                              builder: (context, state) {
                                return _buildDetailsPanel(
                                  context,
                                  state.selectedBond,
                                );
                              },
                            ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailsPanel(BuildContext context, FinancialBondEntity? b) {
    if (b == null) {
      return const Center(
        child: TextWidget(
          text: 'الرجاء اختيار سند لعرض التفاصيل',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                fluent.Text(
                  'تفاصيل السند المالي #${b.billNumber}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                fluent.Tooltip(
                  message: 'حذف السند',
                  child: fluent.IconButton(
                    icon: const fluent.Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, b.id),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow('المبلغ:', '${b.offerAmount} \$'),
            _buildInfoRow(
              'النوع:',
              b.historyGroup == HistoriesGroup.paids ? 'سند صرف' : 'سند قبض',
            ),
            _buildInfoRow('التاريخ:', b.createdAt.toString()),
            if (b.note != null) _buildInfoRow('البيان:', b.note!),
            _buildInfoRow('رقم الحساب الفرعي المساعد:', 'حساب #${b.hintId}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          fluent.Text(label, style: const TextStyle(color: Colors.grey)),
          fluent.Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const fluent.Text('حذف السند'),
        content: const fluent.Text(
          'هل أنت متأكد من رغبتك في حذف هذا السند نهائياً؟',
        ),
        actions: [
          fluent.Button(
            onPressed: () => Navigator.pop(dialogContext),
            child: const fluent.Text('إلغاء'),
          ),
          fluent.FilledButton(
            onPressed: () {
              context.read<FinancialBondsBloc>().add(
                DeleteFinancialBondEvent(id),
              );
              Navigator.pop(dialogContext);
            },
            child: const fluent.Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddBondContentDialog(BuildContext context) {
    final noteController = TextEditingController();
    final amountController = TextEditingController();
    final billNumController = TextEditingController();
    final hintIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: fluent.Text(
          _isPaidFilter ? 'إضافة سند صرف جديد' : 'إضافة سند قبض جديد',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: billNumController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'رقم السند'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ'),
              ),
              TextField(
                controller: hintIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رقم الحساب المرتبط (hintId)',
                ),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'البيان / ملاحظات',
                ),
              ),
            ],
          ),
        ),
        actions: [
          fluent.Button(
            onPressed: () => Navigator.pop(dialogContext),
            child: const fluent.Text('إلغاء'),
          ),
          fluent.FilledButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text) ?? 0.0;
              final num = int.tryParse(billNumController.text) ?? 1;
              final hintId = int.tryParse(hintIdController.text) ?? 1;

              final newBond = FinancialBondEntity(
                id: 0,
                createdAt: DateTime.now(),
                createdBy: 1,
                note: noteController.text,
                offerAmount: amt,
                currencyId: 'YER',
                billNumber: num,
                warehouseId: 1,
                hintId: hintId,
                historyGroup: _isPaidFilter
                    ? HistoriesGroup.paids
                    : HistoriesGroup.proceeds,
              );

              context.read<FinancialBondsBloc>().add(
                AddFinancialBondEvent(newBond),
              );
              Navigator.pop(dialogContext);
            },
            child: const fluent.Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
