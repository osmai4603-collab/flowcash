import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_event.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_state.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

// removed fluent_ui usage from this file; using Material dialogs and icons
class PurchasesTab extends StatefulWidget {
  const PurchasesTab({super.key});

  @override
  State<PurchasesTab> createState() => _PurchasesTabState();
}

class _PurchasesTabState extends State<PurchasesTab> {
  bool _isReturnFilter = false; // false = Purchases, true = Purchase Returns
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
    final theme = Theme.of(context);

    return BlocBuilder<BillsBloc, BillsState>(
      builder: (context, state) {
        if (state.status == BillsStatus.loading && state.bills.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredBills = state.bills.where((b) {
          // Identify purchases. In our mockup let's assume notes starting with "[مشتريات]" or similar, 
          // or we can just filter by whether the note contains "مشتريات".
          // If return filter is true, let's look for returns.
          final matchesReturn = _isReturnFilter 
              ? (b.note?.contains('مرتجع') ?? false)
              : !(b.note?.contains('مرتجع') ?? false);
          
          if (!matchesReturn) return false;

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
                  // Filter Switch (Purchases / Returns)
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: fluent.Text('المشتريات'), icon: Icon(Icons.shopping_cart)),
                      ButtonSegment(value: true, label: fluent.Text('المرتجع'), icon: Icon(Icons.open_in_new)),
                    ],
                    selected: {_isReturnFilter},
                    onSelectionChanged: (val) {
                      setState(() {
                        _isReturnFilter = val.first;
                        context.read<BillsBloc>().add(const SelectBillEvent(null));
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  // Search Field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'البحث برقم الفاتورة...',
                        prefixIcon: const Icon(Icons.search),
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
                  // Add New Bill Button
                  ElevatedButton.icon(
                    onPressed: () => _showAddBillContentDialog(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: fluent.Text(_isReturnFilter ? 'مرتجع مشتريات جديد' : 'فاتورة مشتريات جديدة'),
                  ),
                ],
              ),
            ),
            
            // Content Layout
            Expanded(
              child: isDesktop 
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // List View
                      Expanded(
                        flex: 6,
                        child: _buildBillsList(context, filteredBills, state.selectedBill),
                      ),
                      // Details Panel
                      Expanded(
                        flex: 4,
                        child: _buildDetailsPanel(context, state.selectedBill, state.selectedBillOrders),
                      ),
                    ],
                  )
                : _buildBillsList(context, filteredBills, state.selectedBill),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBillsList(BuildContext context, List<BillEntity> bills, BillEntity? selectedBill) {
    if (bills.isEmpty) {
      return const Center(child: TextWidget(text: 'لا توجد فواتير مطابقة'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bills.length,
      itemBuilder: (context, index) {
        final bill = bills[index];
        final isSelected = bill.id == selectedBill?.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSelected 
                ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: TextWidget(
              text: 'فاتورة مشتريات #${bill.billNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: fluent.Text('التاريخ: ${bill.createdAt.toString().split(' ')[0]} | المبلغ: ${bill.offerAmount} \$'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: fluent.Text(bill.isCash ? 'نقداً' : 'آجل'),
                  backgroundColor: bill.isCash ? Colors.green.shade50 : Colors.orange.shade50,
                  labelStyle: TextStyle(color: bill.isCash ? Colors.green.shade800 : Colors.orange.shade800, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
            onTap: () {
              context.read<BillsBloc>().add(SelectBillEvent(bill));
              if (!isDesktop) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (blocContext) => Scaffold(
                      appBar: AppBar(title: fluent.Text('تفاصيل فاتورة #${bill.billNumber}')),
                      body: BlocProvider.value(
                        value: context.read<BillsBloc>(),
                        child: BlocBuilder<BillsBloc, BillsState>(
                          builder: (context, state) {
                            return _buildDetailsPanel(context, state.selectedBill, state.selectedBillOrders);
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

  Widget _buildDetailsPanel(BuildContext context, BillEntity? bill, List<BillOrderEntity> orders) {
    if (bill == null) {
      return const Center(
        child: TextWidget(
          text: 'الرجاء اختيار فاتورة لعرض التفاصيل',
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
                  'تفاصيل فاتورة #${bill.billNumber}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteBill(context, bill.id),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow('المبلغ الإجمالي:', '${bill.offerAmount} \$'),
            _buildInfoRow('طريقة الدفع:', bill.isCash ? 'نقداً' : 'آجل'),
            _buildInfoRow('المستودع:', 'مستودع #${bill.warehouseId}'),
            _buildInfoRow('التاريخ:', bill.createdAt.toString()),
            if (bill.note != null) _buildInfoRow('ملاحظات:', bill.note!),
            const SizedBox(height: 16),
            fluent.Text(
              '📦 الأصناف والبنود المشمولة',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return ListTile(
                      dense: true,
                      title: fluent.Text('صنف #${order.categoryId}'),
                      subtitle: fluent.Text('الكمية: ${order.countUnits}'),
                      trailing: fluent.Text('${order.totalPrice} \$'),
                    );
                  },
                ),
              ),
            ),
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
          fluent.Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDeleteBill(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const fluent.Text('حذف الفاتورة'),
        content: const fluent.Text('هل أنت متأكد من رغبتك في حذف هذه الفاتورة نهائياً؟'),
        actions: [
          fluent.Button(
            onPressed: () => Navigator.pop(dialogContext),
            child: const fluent.Text('إلغاء'),
          ),
          fluent.FilledButton(
            onPressed: () {
              context.read<BillsBloc>().add(DeleteBillEvent(id));
              Navigator.pop(dialogContext);
            },
            child: const fluent.Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddBillContentDialog(BuildContext context) {
    final noteController = TextEditingController();
    final amountController = TextEditingController();
    final billNumController = TextEditingController();
    bool isCash = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: fluent.Text(_isReturnFilter ? 'إضافة مرتجع مشتريات' : 'إضافة فاتورة مشتريات جديدة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: billNumController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'رقم الفاتورة'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ الإجمالي'),
                ),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'البيان / ملاحظات'),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const fluent.Text('طريقة الدفع:'),
                    ChoiceChip(
                      label: const fluent.Text('نقداً'),
                      selected: isCash,
                      onSelected: (val) => setState(() => isCash = true),
                    ),
                    ChoiceChip(
                      label: const fluent.Text('آجل'),
                      selected: !isCash,
                      onSelected: (val) => setState(() => isCash = false),
                    ),
                  ],
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
                
                final newBill = BillEntity(
                  id: 0,
                  createdAt: DateTime.now(),
                  createdBy: 1,
                  note: _isReturnFilter 
                      ? '[مشتريات - مرتجع] ${noteController.text}' 
                      : '[مشتريات] ${noteController.text}',
                  offerAmount: amt,
                  currencyId: 'YER',
                  billNumber: num,
                  warehouseId: 1,
                  isCash: isCash,
                );

                context.read<BillsBloc>().add(AddBillEvent(bill: newBill, orders: const []));
                Navigator.pop(dialogContext);
              },
              child: const fluent.Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
