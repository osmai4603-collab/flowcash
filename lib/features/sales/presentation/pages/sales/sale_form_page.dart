import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/simple_category_entity.dart';
import 'package:flowcash/features/categories/domain/usecases/category_usecases.dart';
import 'package:flowcash/features/currencies/domain/entities/currency_entity.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/features/inventory/domain/entities/warehouse_entity.dart';
import 'package:flowcash/features/sales/presentation/bloc/sale_form/bill_form_bloc.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_order_entity.dart';
import 'package:flowcash/user_session.dart';
import 'package:flowcash/widgets/combo_box_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

enum _BillCashType { cash, future }

extension _BillCashTypeLabel on _BillCashType {
  String get label => this == _BillCashType.cash ? 'نقدا' : 'آجل';

  bool get isCash => this == _BillCashType.cash;
}

class SaleFormPage extends StatelessWidget {
  final BillEntity? saleBill;
  const SaleFormPage({super.key, this.saleBill});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillFormBloc>(
      create: (_) => BillFormBloc(addBill: sl(), updateBill: sl()),
      child: const _SaleFormView(),
    );
  }
}

class _SaleFormView extends StatefulWidget {
  const _SaleFormView();

  @override
  State<_SaleFormView> createState() => _SaleFormViewState();
}

class _SaleFormViewState extends State<_SaleFormView> {
  final _formKey = GlobalKey<FormState>();
  CurrencyEntity? currencySelected;
  WarehouseEntity? warehouseSelected;
  PersonEntity? customerSelected;
  DateTime dateSelected = DateTime.now();
  final _noteController = TextEditingController();
  final _billNumberController = TextEditingController();

  List<CurrencyEntity> currencies = [];
  List<WarehouseEntity> warehouses = [];

  final List<_OrderRow> _orders = [_OrderRow()];
  _BillCashType _billCashType = _BillCashType.cash;
  bool _isDataChanged = false;

  void _markChanged() {
    if (!_isDataChanged) {
      setState(() => _isDataChanged = true);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDataChanged) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الخروج'),
          content: const Text(
            'هل تريد الخروج؟ سيتم فقدان البيانات غير المحفوظة',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('نعم'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final order in _orders) {
      order.dispose();
    }
    super.dispose();
  }

  double get _offerAmount {
    return _orders.fold(0.0, (sum, order) => sum + (order.totalPrice ?? 0));
  }

  void _addOrder() {
    setState(() => _orders.add(_OrderRow()));
  }

  Future<void> _removeOrder(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف طلبية'),
          content: Text('هل تريد حذف الطلبية رقم ${index + 1}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('نعم'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    setState(() {
      _orders[index].dispose();
      _orders.removeAt(index);
      _markChanged();
    });
  }

  void _onChangedCountUnits(String value, int index) {
    setState(() {
      final order = _orders[index];
      final qty = order.qty ?? 0.0;
      final price = order.price ?? 0.0;
      order.totalPriceController.text = AppMoneyFormatter.formatDouble(
        qty * price,
      );
    });
  }

  void _onChangedUnitPrice(String value, int index) {
    setState(() {
      final order = _orders[index];
      final qty = order.qty ?? 0.0;
      final price = order.price ?? 0.0;
      order.totalPriceController.text = AppMoneyFormatter.formatDouble(
        qty * price,
      );
    });
  }

  void _onChangedTotalPrice(String value, int index) {
    setState(() {
      final order = _orders[index];
      final total = order.totalPrice ?? 0.0;
      final qty = order.qty ?? 1.0;
      if (qty > 0) {
        order.priceController.text = AppMoneyFormatter.formatDouble(
          total / qty,
        );
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (selected == null) return;
    dateSelected = selected;
    _markChanged();
    setState(() {});
  }

  Future<void> _pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (result == null) return;

    _markChanged();
    setState(() {});
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_offerAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن ان تكون اجمالي الفاتورة هو 0')),
      );
      return;
    }

    final session = context.read<UserSession>();
    final bill = BillEntity(
      id: 0,
      createdAt: DateTime.now(),
      createdBy: session.currentUser!.id,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      offerAmount: _offerAmount,
      currencyId: currencySelected!.id,
      billNumber: int.tryParse(_billNumberController.text) ?? 1,
      warehouseId: warehouseSelected!.id,
      billType: InvoiceType.sales,
      personId: customerSelected!.id,
      isCash: _billCashType.isCash,
    );

    final orders = _orders.map((order) {
      return BillOrderEntity(
        id: 0,
        billId: 0,
        categoryId: int.tryParse(order.categoryController.text) ?? 1,
        countUnits: order.qty ?? 0.0,
        totalPrice: order.totalPrice ?? 0.0,
      );
    }).toList();

    context.read<BillFormBloc>().add(
      SubmitBillEvent(bill: bill, orders: orders),
    );
  }

  List<Widget> buildActions() {
    return [
      IconButton(
        icon: const Icon(Icons.add_outlined),
        tooltip: 'اضافة طلبية جديدة',
        onPressed: _addOrder,
      ),
      IconButton(
        icon: const Icon(Icons.save),
        tooltip: 'حفظ البيانات',
        onPressed: _submit,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    // ignore: deprecated_member_use
    return PopScope(
      onPopInvokedWithResult: (result, value) async {
        _onWillPop();
      },
      child: BlocListener<BillFormBloc, BillFormState>(
        listener: (context, state) {
          if (state is BillFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ الفاتورة بنجاح')),
            );
            Navigator.of(context).pop(true);
          } else if (state is BillFormFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: fluent.ContentDialog(
          constraints: BoxConstraints(maxWidth: 600, minWidth: 500),

          title: Row(
            children: [
              fluent.Tooltip(
                message: 'رجوع',
                child: fluent.IconButton(
                  icon: fluent.Icon(fluent.FluentIcons.back_to_window),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(
                    'بيانات الصنف',
                    textAlign: TextAlign.center,
                    style: colors.subTitle,
                  ),
                ),
              ),
              fluent.Tooltip(
                message: 'حفظ البيانات',
                child: fluent.IconButton(
                  icon: fluent.Icon(fluent.FluentIcons.save),
                  onPressed: () => _onSaveButtonClicked(context),
                ),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 16),
                    _buildIdentifiersSection(),
                    const SizedBox(height: 16),
                    _buildPersonSection(),
                    const SizedBox(height: 16),
                    _buildOrdersSection(),
                    const SizedBox(height: 16),
                    _buildTotalSection(),
                    const SizedBox(height: 16),
                    _buildNoteSection(),
                    const SizedBox(height: 20),
                    BlocBuilder<BillFormBloc, BillFormState>(
                      builder: (context, state) {
                        if (state is BillFormLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          child: fluent.FilledButton(
                            onPressed: _submit,
                            child: const fluent.Text('حفظ الفاتورة'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final colors = AppStyle.of(context);
    return Row(
      spacing: Spacings.medium,
      crossAxisAlignment: .end,
      children: [
        Expanded(
          child: fluent.InfoLabel(
            label: 'التاريخ',
            child: fluent.DatePicker(
              selected: dateSelected,
              onChanged: (date) {
                dateSelected = date;
                _markChanged();
                setState(() {});
              },
              // controller: _dateController,
            ),
          ),
        ),
        

        Expanded(
          child: fluent.InfoLabel(
            label: 'نوع الفاتورة',
            child: Row(
                children: _BillCashType.values.map((type) {
                  final selected = _billCashType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _billCashType = type;
                        });
                        _markChanged();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2,),
                        padding: Paddings.xsmallVertical,
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.primary
                              : null,
                          borderRadius: Radiuses.xsmallAll,
                        ),
                        alignment: Alignment.center,
                        child: fluent.Text(
                          type.label,
                          style: selected 
                            ? colors.bodyStrong.copyWith(color: colors.onPrimary)
                            : colors.bodyStrong,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentifiersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: fluent.InfoLabel(
                label: 'معرف العملة',
                child: fluent.ComboboxFormField<CurrencyEntity>(
                  isExpanded: true,
                  placeholder: Text('اختر العملة'),
                  // controller: _currencyController,
                  onChanged: (_) => _markChanged(),
                  items: currencies
                      .map(
                        (c) => fluent.ComboBoxItem(
                          value: c,
                          child: fluent.Text(c.name),
                        ),
                      )
                      .toList(),
                  validator: (value) => value == null ? 'مطلوب' : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: fluent.InfoLabel(
                label: 'رقم الفاتورة',
                child: fluent.TextFormBox(
                  textDirection: .ltr,
                  controller: _billNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => _markChanged(),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'مطلوب' : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: fluent.InfoLabel(
                label: 'معرف المخزن',
                child: fluent.ComboboxFormField<WarehouseEntity>(
                  placeholder: Text('اختر المخزن'),
                  isExpanded: true,
                  items: warehouses
                      .map(
                        (w) => fluent.ComboBoxItem(
                          value: w,
                          child: Text(w.warehouseName),
                        ),
                      )
                      .toList(),
                  // controller: _warehouseController,
                  onChanged: (_) => _markChanged(),
                  validator: (value) => value == null ? 'مطلوب' : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonSection() {
    return fluent.InfoLabel(
      label: 'العميل',
      child: ComboBoxForm<PersonEntity>(
        controller: TextEditingController(),
        onSelectedItem: (person) {
          customerSelected = person;
          _markChanged();
        },
        itemsBuilder: (value) async {
          return [];
        },
        placeHolder: 'ادخل اسم العميل',

        labelMenu: (entity) => entity.personName,

        onChanged: (_) => _markChanged(),
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الطلبات',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ..._orders.asMap().entries.map((entry) {
          final index = entry.key;
          final order = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: fluent.InfoLabel(
                          label: 'معرف الصنف',
                          child: ComboBoxForm<SimpleCategoryEntity>(
                            controller: order.categoryController,
                            placeHolder: 'ادخل معرف الصنف',
                            onChanged: (_) => _markChanged(),
                            itemsBuilder: (value) async {
                              final result =
                                  await sl<
                                    GetCategoriesWhereContainsNameUseCase
                                  >()(value);
                              return result.fold(
                                (failure) => [],
                                (categories) => categories,
                              );
                            },
                            onSelectedItem: (category) {
                              order.categoryController.text = category.id
                                  .toString();
                              order.categorySelected = category;
                              _markChanged();
                            },
                            labelMenu: (entity) => entity.categoryName,
                            validator: (value) =>
                                value == null ? 'مطلوب' : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: fluent.InfoLabel(
                          label: 'الكمية',
                          child: fluent.TextFormBox(
                            controller: order.qtyController,
                            placeholder: 'ادخل الكمية',

                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'\d+\.?\d*'),
                              ),
                            ],
                            onChanged: (value) {
                              _markChanged();
                              _onChangedCountUnits(value, index);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'مطلوب';
                              if (double.tryParse(value) == null ||
                                  double.parse(value) <= 0) {
                                return 'يجب أن يكون أكبر من 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: fluent.InfoLabel(
                          label: 'سعر الوحدة',
                          child: fluent.TextFormBox(
                            placeholder: 'ادخل سعر الوحدة',
                            controller: order.priceController,

                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'\d+\.?\d*'),
                              ),
                            ],
                            onChanged: (value) {
                              _markChanged();
                              _onChangedUnitPrice(value, index);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'مطلوب';
                              if (double.tryParse(value) == null ||
                                  double.parse(value) <= 0) {
                                return 'يجب أن يكون أكبر من 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: fluent.InfoLabel(
                          label: 'السعر الإجمالي',
                          child: fluent.TextFormBox(
                            controller: order.totalPriceController,

                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'\d+\.?\d*'),
                              ),
                            ],
                            onChanged: (value) {
                              _markChanged();
                              _onChangedTotalPrice(value, index);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'مطلوب';
                              if (double.tryParse(value) == null ||
                                  double.parse(value) <= 0) {
                                return 'يجب أن يكون أكبر من 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _removeOrder(index),
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('إزالة الطلبية'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTotalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'المجموع الكلي: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              AppMoneyFormatter.formatDouble(_offerAmount),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('الرجاء التأكد من أن جميع الطلبات مكتملة قبل حفظ الفاتورة.'),
      ],
    );
  }

  Widget _buildNoteSection() {
    return fluent.InfoLabel(
      label: 'ملاحظة',
      child: fluent.TextFormBox(
        placeholder: 'أضف ملاحظة توضيحية',
        controller: _noteController,
        maxLines: 3,
        onChanged: (_) => _markChanged(),
      ),
    );
  }

  void _onSaveButtonClicked(BuildContext context) {}
}

class _OrderRow {
  final categoryController = TextEditingController(text: '1');
  final qtyController = TextEditingController(text: '1');
  final priceController = TextEditingController(text: '0');
  final totalPriceController = TextEditingController(text: '0');

  SimpleCategoryEntity? categorySelected;

  double? get qty => double.tryParse(qtyController.text);
  double? get price => double.tryParse(priceController.text);
  double? get totalPrice => double.tryParse(totalPriceController.text);

  void dispose() {
    categoryController.dispose();
    qtyController.dispose();
    priceController.dispose();
    totalPriceController.dispose();
  }
}
