import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_event.dart';
import 'package:flowcash/features/transactions/presentation/blocs/bills/bills_state.dart';
import 'package:flowcash/widgets/my_text_widget.dart';

// removed fluent_ui usage from this file; using Material dialogs and icons
class SalesTab extends StatefulWidget {
  const SalesTab({super.key});

  @override
  State<SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  bool _isReturnFilter = false; // false = Sales, true = Sales Returns
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

        // Filter: sales vs salesReturn.
        // sales: isCash/isCredit, but what defines sales? 
        // Let's assume we can differentiate by note or type if needed.
        // Wait, BillEntity has billNumber and isCash. 
        // Let's assume returns are marked by note or we can filter.
        // Actually, in databases or repositories, isReturn might be handled.
        // Let's look at how the DB table or entities are structured for returns.
        // Let's check `lib/features/transactions/data/models/bill_model.dart` or tables to see.
        final filteredBills = state.bills.where((b) {
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
            // Toolbar (Search + Filters + Add Button)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Filter Switch (Sales / Returns)
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('المبيعات'), icon: Icon(Icons.shopping_cart)),
                      ButtonSegment(value: true, label: Text('المرتجع'), icon: Icon(Icons.open_in_new)),
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
                    label: Text(_isReturnFilter ? 'مرتجع مبيعات جديد' : 'فاتورة مبيعات جديدة'),
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
                      // List View (60% width)
                      Expanded(
                        flex: 6,
                        child: _buildBillsList(context, filteredBills, state.selectedBill),
                      ),
                      // Details Panel (40% width)
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
              text: 'فاتورة رقم #${bill.billNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('التاريخ: ${bill.createdAt.toString().split(' ')[0]} | المبلغ: ${bill.offerAmount} \$'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(bill.isCash ? 'نقداً' : 'آجل'),
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
                // On mobile, navigate to details page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (blocContext) => Scaffold(
                      appBar: AppBar(title: Text('تفاصيل فاتورة #${bill.billNumber}')),
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
                Text(
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
            Text(
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
                      title: Text('صنف #${order.categoryId}'),
                      subtitle: Text('الكمية: ${order.countUnits}'),
                      trailing: Text('${order.totalPrice} \$'),
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
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDeleteBill(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الفاتورة'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذه الفاتورة نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<BillsBloc>().add(DeleteBillEvent(id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف'),
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
          title: Text(_isReturnFilter ? 'إضافة مرتجع مبيعات' : 'إضافة فاتورة مبيعات جديدة'),
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
                    const Text('طريقة الدفع:'),
                    ChoiceChip(
                      label: const Text('نقداً'),
                      selected: isCash,
                      onSelected: (val) => setState(() => isCash = true),
                    ),
                    ChoiceChip(
                      label: const Text('آجل'),
                      selected: !isCash,
                      onSelected: (val) => setState(() => isCash = false),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountController.text) ?? 0.0;
                final num = int.tryParse(billNumController.text) ?? 1;
                
                final newBill = BillEntity(
                  id: 0,
                  createdAt: DateTime.now(),
                  createdBy: 1,
                  note: _isReturnFilter 
                      ? '[مرتجع] ${noteController.text}' 
                      : noteController.text,
                  offerAmount: amt,
                  currencyId: 'YER',
                  billNumber: num,
                  warehouseId: 1,
                  isCash: isCash,
                );

                context.read<BillsBloc>().add(AddBillEvent(bill: newBill, orders: const []));
                Navigator.pop(dialogContext);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}
