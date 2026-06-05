import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/core/enums/histories_group_enum.dart';
import 'package:flowcash/features/transactions/domain/entities/financial_transaction_entity.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_transactions/financial_transactions_bloc.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_transactions/financial_transactions_event.dart';
import 'package:flowcash/features/transactions/presentation/blocs/financial_transactions/financial_transactions_state.dart';
import 'package:flowcash/widgets/my_text_widget.dart';

// removed fluent_ui usage from this file; using Material dialogs and icons
class ExpensesRevenuesTab extends StatefulWidget {
  const ExpensesRevenuesTab({super.key});

  @override
  State<ExpensesRevenuesTab> createState() => _ExpensesRevenuesTabState();
}

class _ExpensesRevenuesTabState extends State<ExpensesRevenuesTab> {
  bool _isRevenueFilter = false; // false = Expenses, true = Revenues
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
    return BlocBuilder<FinancialTransactionsBloc, FinancialTransactionsState>(
      builder: (context, state) {
        if (state.status == FinancialTransactionsStatus.loading && state.transactions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredList = state.transactions.where((t) {
          final isTargetType = _isRevenueFilter 
              ? t.historyGroup == HistoriesGroup.revenues
              : t.historyGroup == HistoriesGroup.expenses;
          
          if (!isTargetType) return false;

          if (_searchQuery.isEmpty) return true;
          return t.billNumber.toString().contains(_searchQuery) ||
              (t.note?.contains(_searchQuery) ?? false);
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
                      ButtonSegment(value: false, label: Text('المصروفات'), icon: Icon(Icons.arrow_circle_down)),
                      ButtonSegment(value: true, label: Text('الإيرادات'), icon: Icon(Icons.arrow_circle_up)),
                    ],
                    selected: {_isRevenueFilter},
                    onSelectionChanged: (val) {
                      setState(() {
                        _isRevenueFilter = val.first;
                        context.read<FinancialTransactionsBloc>().add(const SelectFinancialTransactionEvent(null));
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  // Search
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'البحث عن حركة مالية...',
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
                  // Add Button
                  ElevatedButton.icon(
                    onPressed: () => _showAddTransactionContentDialog(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(_isRevenueFilter ? 'إضافة إيراد جديد' : 'إضافة مصروف جديد'),
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
                          child: _buildList(context, filteredList, state.selectedTransaction),
                        ),
                        Expanded(
                          flex: 4,
                          child: _buildDetailsPanel(context, state.selectedTransaction),
                        ),
                      ],
                    )
                  : _buildList(context, filteredList, state.selectedTransaction),
            ),
          ],
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    List<FinancialTransactionEntity> transactions,
    FinancialTransactionEntity? selected,
  ) {
    if (transactions.isEmpty) {
      return const Center(child: TextWidget(text: 'لا توجد حركات مالية مطابقة'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        final isSelected = t.id == selected?.id;

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
              text: '${_isRevenueFilter ? "إيراد" : "مصروف"} رقم #${t.billNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('التاريخ: ${t.createdAt.toString().split(' ')[0]} | البيان: ${t.note ?? "بدون بيان"}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${t.offerAmount} \$',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isRevenueFilter ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
              ],
            ),
            onTap: () {
              context.read<FinancialTransactionsBloc>().add(SelectFinancialTransactionEvent(t));
              if (!isDesktop) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (blocContext) => Scaffold(
                      appBar: AppBar(title: Text('${_isRevenueFilter ? "إيراد" : "مصروف"} #${t.billNumber}')),
                      body: BlocProvider.value(
                        value: context.read<FinancialTransactionsBloc>(),
                        child: BlocBuilder<FinancialTransactionsBloc, FinancialTransactionsState>(
                          builder: (context, state) {
                            return _buildDetailsPanel(context, state.selectedTransaction);
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

  Widget _buildDetailsPanel(BuildContext context, FinancialTransactionEntity? t) {
    if (t == null) {
      return const Center(
        child: TextWidget(
          text: 'الرجاء اختيار حركة مالية لعرض التفاصيل',
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
                  'تفاصيل الحركة المالية #${t.billNumber}',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, t.id),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow('المبلغ:', '${t.offerAmount} \$'),
            _buildInfoRow('النوع:', t.historyGroup == HistoriesGroup.revenues ? 'إيراد' : 'مصروف'),
            _buildInfoRow('التاريخ:', t.createdAt.toString()),
            if (t.note != null) _buildInfoRow('البيان:', t.note!),
            _buildInfoRow('رقم الحساب الفرعي المساعد:', 'حساب #${t.hintId}'),
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

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الحركة المالية'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذه الحركة المالية نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FinancialTransactionsBloc>().add(DeleteFinancialTransactionEvent(id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionContentDialog(BuildContext context) {
    final noteController = TextEditingController();
    final amountController = TextEditingController();
    final billNumController = TextEditingController();
    final hintIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_isRevenueFilter ? 'إضافة إيراد جديد' : 'إضافة مصروف جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: billNumController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'رقم الحركة'),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ'),
              ),
              TextField(
                controller: hintIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'رقم الحساب المرتبط (hintId)'),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'البيان / ملاحظات'),
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
              final hintId = int.tryParse(hintIdController.text) ?? 1;

              final newTransaction = FinancialTransactionEntity(
                id: 0,
                createdAt: DateTime.now(),
                createdBy: 1,
                note: noteController.text,
                offerAmount: amt,
                currencyId: 'YER',
                billNumber: num,
                warehouseId: 1,
                hintId: hintId,
                historyGroup: _isRevenueFilter ? HistoriesGroup.revenues : HistoriesGroup.expenses,
              );

              context.read<FinancialTransactionsBloc>().add(AddFinancialTransactionEvent(newTransaction));
              Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
