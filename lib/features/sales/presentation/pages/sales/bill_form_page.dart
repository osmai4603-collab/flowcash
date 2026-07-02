import 'dart:io';
import 'package:flowcash/core/entities/person_entity.dart';
import 'package:flowcash/core/enums/invoice_type_enum.dart';
import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/usecases/value_counter_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/currency_repository_usecases.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';
import 'package:flowcash/features/sales/presentation/bloc/sale_form/bill_form_bloc.dart';
import 'package:flowcash/features/sales/presentation/pages/customers/customer_form_page.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flowcash/features/transactions/domain/usecases/bill_repository_usecases.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' show BoxDecoration;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tafqit/tafqit.dart';
import 'package:flowcash/core/theme/styles.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flowcash/widgets/combo_box_form.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/simple_category_entity.dart';
import '../../../../../core/enums/unit_type_enum.dart';
import '../../../../../core/usecases/person_repository_usecases.dart';
import '../../../../../formatter.dart';
import '../../../../../user_session.dart';
import '../../../../../widgets/message.dart';
import '../../../../categories/domain/usecases/category_usecases.dart';
import '../../../../categories/presentation/pages/categories/category_form_page.dart';
import '../../../../currencies/domain/entities/currency_entity.dart';
import '../../../../injection_container.dart';
import '../../../../inventory/domain/entities/warehouse_entity.dart';
import '../../../../inventory/domain/usecases/warehouse_usecases.dart';
import '../../../../transactions/domain/usecases/post_bill_to_accounting_use_case.dart';
import '../../../../transactions/domain/usecases/post_bill_to_inventory_use_case.dart';
import '../../../../transactions/domain/usecases/post_bill_to_costing_use_case.dart';

class BillFormPage extends StatelessWidget {
  final BillEntity? bill;
  final InvoiceType billType;

  const BillFormPage({super.key, this.bill, required this.billType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillFormBloc>(
      create: (context) => BillFormBloc(
        getCurrencies: sl<GetCurrenciesUseCase>(),
        getExchangePrices: sl<GetExchangePricesUseCase>(),
        getWarehouses: sl<GetWarehousesUseCase>(),
        getValueCounter: sl<GetValueCounterByCounterTypeUseCase>(),
        getPersons: sl<GetPersonsUseCase>(),
        insertBill: sl<InsertBillUseCase>(),
        updateBill: sl<UpdateBillUseCase>(),
        postBillToAccounting: sl<PostBillToAccountingUseCase>(),
        postBillToInventory: sl<PostBillToInventoryUseCase>(),
        postBillToCosting: sl<PostBillToCostingUseCase>(),
        updateValueCounter: sl<UpdateValueCounterUseCase>(),
        getCategoriesWhereContainsName:
            sl<GetCategoriesWhereContainsNameUseCase>(),
        userSession: context.read<UserSession>(),
      )..add(BillFormInitRequested(bill: bill, billType: billType)),
      child: _BillFormView(bill: bill, billType: billType),
    );
  }
}

class _BillFormView extends StatefulWidget {
  final BillEntity? bill;
  final InvoiceType billType;

  const _BillFormView({this.bill, required this.billType});

  @override
  State<_BillFormView> createState() => _BillFormViewState();
}

class _BillFormViewState extends State<_BillFormView> {
  final personNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    personNameController.dispose();
    super.dispose();
  }

  void _onBackPressed(BillFormState state) async {
    if (!state.isDataChanged) {
      if (context.mounted) Navigator.pop(context);
      return;
    }
    final sure = await makeSure(
      context: context,
      title: 'تأكيد الخروج',
      content: 'هل تريد الخروج؟ سيتم فقدان البيانات غير المحفوظة',
    );
    if (sure && context.mounted) {
      Navigator.pop(context);
    }
  }

  TafqitUnitCode _getUnitCode(CurrencyEntity? currencySelected) {
    if (currencySelected == null) {
      return TafqitUnitCode.yemeniRial;
    }
    if (currencySelected.symbol.contains('ريال سعودي')) {
      return TafqitUnitCode.saudiRiyal;
    }
    if (currencySelected.symbol.contains('دولار')) {
      return TafqitUnitCode.unitedStatesDollar;
    }
    return TafqitUnitCode.yemeniRial;
  }

  // --- Handlers & Validators Extracted from Widget Tree ---

  void _onDateChanged(DateTime date) {
    context.read<BillFormBloc>().add(BillFormDateChanged(date));
  }

  void _onCashTypeChanged(BillCashType cashType) {
    context.read<BillFormBloc>().add(BillFormCashTypeChanged(cashType));
  }

  void _onWarehouseChanged(WarehouseEntity? warehouse) {
    if (warehouse != null) {
      context.read<BillFormBloc>().add(BillFormWarehouseChanged(warehouse));
    }
  }

  void _onCurrencyChanged(CurrencyEntity? currency) {
    if (currency != null) {
      context.read<BillFormBloc>().add(BillFormCurrencyChanged(currency));
    }
  }

  void _onTreasuryChanged(PersonEntity? treasury) {
    if (treasury != null) {
      context.read<BillFormBloc>().add(BillFormTreasurySelected(treasury));
    }
  }

  void _onPersonEditingComplete(BillFormState state) {
    if (state.requests.isNotEmpty) {
      state.requests[0].categoryNameFocusNode.requestFocus();
    }
  }

  String? _validatePerson(String? value, BillFormState state) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم العميل مطلوب';
    }
    if (state.personSelected == null) {
      return 'لم يتم تحديد اسم العميل من القائمة';
    }
    return null;
  }

  void _onPersonChanged(String value) {
    context.read<BillFormBloc>().add(BillFormPersonSelected(null));
  }

  Future<List<PersonEntity>> _fetchPersons(String value) {
    return context.read<BillFormBloc>().searchPersons(value);
  }

  void _onPersonSelected(PersonEntity person, BillFormState state) {
    personNameController.text = person.personName;
    context.read<BillFormBloc>().add(BillFormPersonSelected(person));
    if (state.requests.isNotEmpty) {
      state.requests[0].categoryNameFocusNode.requestFocus();
    }
  }

  void _onNoteChanged(String value) {
    context.read<BillFormBloc>().add(BillFormNoteChanged(value));
  }

  void _onTotalPriceChanged(int index, String value) {
    context.read<BillFormBloc>().add(BillFormTotalPriceChanged(index, value));
  }

  void _onTotalPriceEditingComplete(int index, BillFormState state) async {
    if (index < state.requests.length - 1) {
      state.requests[index + 1].categoryNameFocusNode.requestFocus();
      return;
    }
    final sure = await makeSure(
      context: context,
      title: 'إضافة طلبية',
      content: 'هل تريد إضافة طلبية جديدة؟',
    );
    if (!sure || !context.mounted) return;
    context.read<BillFormBloc>().add(BillFormRequestAdded());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final requests = context.read<BillFormBloc>().state.requests;
      if (requests.isNotEmpty) {
        requests.last.categoryNameFocusNode.requestFocus();
      }
    });
  }

  String? _validateRequiredPriceOrCount(String? value) {
    if (value == null || value.trim().isEmpty) return 'مطلوب';
    final doubleVal = double.tryParse(value.replaceAll(',', ''));
    if (doubleVal == null || doubleVal <= 0) {
      return 'يجب أن يكون أكبر من 0';
    }
    return null;
  }

  void _onUnitPriceChanged(int index, String value) {
    context.read<BillFormBloc>().add(BillFormUnitPriceChanged(index, value));
  }

  void _onCountUnitsChanged(int index, String value) {
    context.read<BillFormBloc>().add(BillFormCountUnitsChanged(index, value));
  }

  Future<List<SimpleCategoryEntity>> _fetchCategories(String value) {
    return context.read<BillFormBloc>().searchCategories(value);
  }

  void _onCategorySelected(
    int index,
    SimpleCategoryEntity? category,
    RequestModel request,
  ) {
    context.read<BillFormBloc>().add(BillFormCategorySelected(index, category));
    if (category != null) {
      request.countUnitsFocusNode.requestFocus();
    }
  }

  String? _validateCategory(String? value, RequestModel request) {
    if (value == null || value.trim().isEmpty) return 'مطلوب';
    if (request.category == null) return 'غير محدد';
    return null;
  }

  void _onCategoryChanged(int index, String value) {
    context.read<BillFormBloc>().add(BillFormCategorySelected(index, null));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BillFormBloc, BillFormState>(
      listener: (context, state) {
        if (state.status == BillFormStatus.submitSuccess) {
          Navigator.pop(context, state.initialBill);
          successToast(
            context: context,
            toast: 'تم حفظ بيانات الفاتورة بنجاح في قاعدة البيانات',
          );
        } else if (state.status == BillFormStatus.submitFailure ||
            state.status == BillFormStatus.failure) {
          error(context: context, toast: state.errorMessage ?? 'حدث خطأ ما');
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: !state.isDataChanged,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onBackPressed(state);
          },
          child: _buildBody(context, state),
        );
      },
    );
  }

  bool get isDesktop => Platform.isWindows || Platform.isLinux;

  Widget _buildBody(BuildContext context, BillFormState state) {
    if (state.status == BillFormStatus.loading) {
      return const Center(child: ProgressBar());
    }

    if (isDesktop) {
      return ContentDialog(
        constraints: const BoxConstraints(maxWidth: 600),
        title: buildDesktopHeader(context, state),
        actions: buildDialogActions(context, state),
        
        content: Form(
          key: _formKey,
          child: buildBill(context, state),
        ),
      );
    }
    return Form(
      key: _formKey,
      child: ScaffoldPage(
        header: PageHeader(
          title: Text(
            'فاتورة ${widget.billType.totalName}',
            textAlign: TextAlign.center,
          ),
          commandBar: Row(children: buildMobileActions(context)),
          leading: Tooltip(
            message: 'رجوع',
            child: IconButton(
              icon: const Icon(FluentIcons.back_to_window),
              onPressed: () => _onBackPressed(state),
            ),
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(5),
          child: buildBill(context, state),
        ),
      ),
    );
  }

  Widget buildDesktopHeader(BuildContext context, BillFormState state) {
    final bloc = context.read<BillFormBloc>();
    return Row(
      children: [
        Expanded(
          child: Text(
            'فاتورة ${widget.billType.totalName}',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        Tooltip(
          message: 'اضافة طلبية جديدة',
          child: IconButton(
            icon: const Icon(FluentIcons.add_field),
            onPressed: () => bloc.add(BillFormRequestAdded()),
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: 'اضافة عميل جديد',
          child: IconButton(
            icon: const Icon(FluentIcons.people_add),
            onPressed: () => _onAddNewPerson(context),
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: 'اضافة صنف جديد',
          child: IconButton(
            icon: const Icon(FluentIcons.category_classification),
            onPressed: () => _onAddNewCategory(context),
          ),
        ),
      ],
    );
  }

  List<Widget> buildDialogActions(BuildContext context, BillFormState state) {
    final bloc = context.read<BillFormBloc>();
    return [
      Expanded(
        child: Button(
          child: const Text('رجوع'),
          onPressed: () => _onBackPressed(state),
        ),
      ),
      Expanded(
        child: FilledButton(
          child: const Text('حفظ'),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              bloc.add(BillFormSubmitRequested());
            }
          },
        ),
      ),
    ];
  }

  List<Widget> buildMobileActions(BuildContext context) {
    final bloc = context.read<BillFormBloc>();
    return [
      Tooltip(
        message: 'اضافة صنف جديد',
        child: IconButton(
          icon: const Icon(FluentIcons.category_classification),
          onPressed: () => _onAddNewCategory(context),
        ),
      ),
      const SizedBox(width: 2),
      Tooltip(
        message: 'اضافة طلبية جديدة',
        child: IconButton(
          icon: const Icon(FluentIcons.add_field),
          onPressed: () => bloc.add(BillFormRequestAdded()),
        ),
      ),
      const SizedBox(width: 2),
      Tooltip(
        message: 'حفظ البيانات',
        child: IconButton(
          icon: const Icon(FluentIcons.save),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              bloc.add(BillFormSubmitRequested());
            }
          },
        ),
      ),
      const SizedBox(width: 2),
    ];
  }

  Widget buildBill(BuildContext context, BillFormState state) {
    final colors = AppStyle.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'التاريخ',
                  child: DatePicker(
                    selected: state.dateSelected,
                    startDate: state.firstDate,
                    endDate: DateTime.now(),
                    onChanged: _onDateChanged,
                  ),
                ),
              ),
              Container(
                height: isDesktop ? 40.0 : 35.0,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.0),
                  border: Border.all(color: colors.surface, width: 2.0),
                  color: colors.surfaceContainerHigh,
                ),
                child: Row(
                  children: [
                    TextWidget(
                      text: widget.billType.singleName,
                      style: colors.body,
                    ),
                    const SizedBox(width: 5.0),
                    HoverButton(
                      onPressed: () => _onCashTypeChanged(BillCashType.cash),
                      builder: (context, states) {
                        return TextWidget(
                          text: 'نقدا',
                          backColor: state.billCashType == BillCashType.cash
                              ? colors.primary
                              : null,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: isDesktop ? 3 : 0.0,
                          ),
                          style: colors.body.copyWith(
                            color: state.billCashType == BillCashType.cash
                                ? colors.onSurface
                                : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 2.0),
                    TextWidget(
                      text: '/',
                      style: colors.body.copyWith(fontSize: 20),
                    ),
                    const SizedBox(width: 2.0),
                    HoverButton(
                      onPressed: () => _onCashTypeChanged(BillCashType.future),
                      builder: (context, states) {
                        return TextWidget(
                          text: 'آجل',
                          backColor: state.billCashType == BillCashType.future
                              ? colors.primary
                              : null,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: isDesktop ? 3 : 0.0,
                          ),
                          style: colors.body.copyWith(
                            color: state.billCashType == BillCashType.future
                                ? colors.onSurface
                                : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: isDesktop ? 30 : 25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'الرقم:   ',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        state.billNumber.toString().padLeft(
                          context
                                  .read<BillFormBloc>()
                                  .billCounter
                                  ?.formatValue
                                  .length ??
                              5,
                          '0',
                        ),
                        style: TextStyle(color: colors.primary, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InfoLabel(
                  label: 'المخزن',
                  child: ComboboxFormField<WarehouseEntity>(
                    value: state.warehouseSelected,
                    isExpanded: true,
                    items: context.read<BillFormBloc>().warehouses.map((store) {
                      return ComboBoxItem<WarehouseEntity>(
                        value: store,
                        child: Text(
                          store.warehouseName,
                          style: Styles.titleSmall.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _onWarehouseChanged,
                    placeholder: const Text('المخزن'),
                    validator: (value) => value == null ? 'المخزن مطلوب' : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InfoLabel(
                  label: 'العملة',
                  child: ComboboxFormField<CurrencyEntity>(
                    value: state.currencySelected,
                    isExpanded: true,
                    items: context.read<BillFormBloc>().currencies.map((
                      currency,
                    ) {
                      return ComboBoxItem<CurrencyEntity>(
                        value: currency,
                        child: Text(
                          currency.name,
                          style: Styles.titleSmall.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _onCurrencyChanged,
                    placeholder: const Text('العملة'),
                    validator: (value) =>
                        value == null ? 'العملة مطلوبة' : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InfoLabel(
            label: 'اسم العميل',
            child: ComboBoxForm<PersonEntity>(
              style: Styles.titleSmall,
              textInputAction: TextInputAction.next,
              controller: personNameController,
              textAlignVertical: isDesktop
                  ? TextAlignVertical.center
                  : TextAlignVertical.bottom,
              onEditingComplete: () => _onPersonEditingComplete(state),
              placeHolder: 'ادخل اسم العميل',
              prefix: Tooltip(
                message: 'اضافة اسم جديد',
                child: IconButton(
                  icon: Icon(FluentIcons.people_add, color: colors.primary),
                  onPressed: () => _onAddNewPerson(context),
                ),
              ),
              validator: (value) => _validatePerson(value, state),
              onChanged: _onPersonChanged,
              itemsBuilder: _fetchPersons,
              labelMenu: (person) => person.personName,
              onSelectedItem: (person) => _onPersonSelected(person, state),
            ),
          ),
          const SizedBox(height: 10),
          if (state.billCashType == BillCashType.cash) ...[
            InfoLabel(
              label: 'الحساب النقدي',
              child: ComboboxFormField<PersonEntity>(
                value: state.treasurySelected?.id != 0
                    ? state.treasurySelected
                    : null,
                isExpanded: true,
                items: context.read<BillFormBloc>().treasuries.map((treasury) {
                  return ComboBoxItem<PersonEntity>(
                    value: treasury,
                    child: Text(
                      treasury.personName,
                      style: Styles.titleSmall.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: _onTreasuryChanged,
                placeholder: const Text('اختر الحساب النقدي'),
                validator: (value) =>
                    value == null ? 'الحساب النقدي مطلوب' : null,
              ),
            ),
            const SizedBox(height: 10),
          ],
          _buildBillTable(context, state),
          const SizedBox(height: 5),
          if (!isDesktop)
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    height: 25,
                    color: colors.surfaceContainerHigh,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      Tafqit().tafqitNumberWithParts(
                            listOfNumberAndParts: [state.totalAmount.toInt()],
                            tafqitUnitCode: _getUnitCode(
                              state.currencySelected,
                            ),
                            justWord: '',
                            noOtherWord: '',
                          ) ??
                          '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 25,
                    color: colors.surfaceContainerHigh,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppMoneyFormatter.formatDouble(state.totalAmount),
                    ),
                  ),
                ),
              ],
            ),
          if (isDesktop)
            Row(
              children: [
                Container(
                  width: 114,
                  height: 25,
                  color: colors.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  child: Text(
                    AppMoneyFormatter.formatDouble(state.totalAmount),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    height: 25,
                    color: colors.surfaceContainerHigh,
                    alignment: Alignment.center,
                    child: Text(
                      Tafqit().tafqitNumberWithParts(
                            listOfNumberAndParts: [state.totalAmount.toInt()],
                            tafqitUnitCode: TafqitUnitCode.yemeniRial,
                            justWord: '',
                            noOtherWord: '',
                          ) ??
                          '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          InfoLabel(
            label: 'ملاحظة',
            child: TextFormBox(
              onChanged: _onNoteChanged,
              maxLines: 2,
              style: Styles.titleSmall,
              decoration: const WidgetStatePropertyAll(
                BoxDecoration(
                  border: Border.fromBorderSide(BorderSide.none),
                ),
              ),
              placeholder: 'ادخل الملاحظة',
              prefix: const Icon(FluentIcons.add_notes),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildBillTable(BuildContext context, BillFormState state) {
    final colors = AppStyle.of(context);
    const borderThickness = 0.50;

    final columnWidths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(20),
      1: const FlexColumnWidth(0.17),
      2: const FlexColumnWidth(0.17),
      3: const FlexColumnWidth(0.10),
      4: const FixedColumnWidth(60),
      5: const FlexColumnWidth(0.46),
    };

    final headerTitles = ['', 'الاجمالي', 'سعر الوحدة', 'الكمية', 'الوحدة', 'الوصف'];

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: columnWidths,
      border: TableBorder(
        top: BorderSide(width: borderThickness, color: colors.outline),
        bottom: BorderSide(width: borderThickness, color: colors.outline),
        left: BorderSide(width: borderThickness, color: colors.outline),
        right: BorderSide(width: borderThickness, color: colors.outline),
        verticalInside: BorderSide(width: borderThickness, color: colors.outline),
        horizontalInside: BorderSide(width: borderThickness, color: colors.outline),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(color: colors.surface),
          children: headerTitles.map((title) {
            return Container(
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: colors.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            );
          }).toList(),
        ),
        for (var index = 0; index < state.requests.length; index++)
          TableRow(
            decoration: BoxDecoration(
              color: index.isOdd ? colors.surfaceContainerHigh : null,
            ),
            children: [
              HoverButton(
                onPressed: () => _onRemoveRequest(context, index),
                builder: (context, states) {
                  return Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: TextWidget(
                      size: const Size.fromHeight(30),
                      text: '${index + 1}',
                      alignment: Alignment.center,
                      style: colors.body,
                    ),
                  );
                },
              ),
              TextFormBox(
                textInputAction: TextInputAction.done,
                controller: state.requests[index].totalPriceController,
                focusNode: state.requests[index].totalPriceFocusNode,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                cursorHeight: 13.0,
                style: colors.body,
                decoration: const WidgetStatePropertyAll(
                  BoxDecoration(
                    border: Border.fromBorderSide(BorderSide.none),
                  ),
                ),
                textAlign: TextAlign.center,
                inputFormatters: [ThousandsFormatter(allowFraction: true)],
                placeholder: '---',
                placeholderStyle: colors.body.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                onChanged: (value) => _onTotalPriceChanged(index, value),
                onEditingComplete: () => _onTotalPriceEditingComplete(index, state),
                validator: _validateRequiredPriceOrCount,
              ),
              TextFormBox(
                textInputAction: TextInputAction.next,
                controller: state.requests[index].unitPriceController,
                focusNode: state.requests[index].unitPriceFocusNode,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                cursorHeight: 13.0,
                style: colors.body,
                decoration: const WidgetStatePropertyAll(
                  BoxDecoration(
                    border: Border.fromBorderSide(BorderSide.none),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                textAlign: TextAlign.center,
                inputFormatters: [ThousandsFormatter(allowFraction: true)],
                placeholder: '---',
                placeholderStyle: colors.body.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                onChanged: (value) => _onUnitPriceChanged(index, value),
                onEditingComplete: state.requests[index].totalPriceFocusNode.requestFocus,
                validator: _validateRequiredPriceOrCount,
              ),
              TextFormBox(
                textInputAction: TextInputAction.next,
                controller: state.requests[index].countUnitsController,
                focusNode: state.requests[index].countUnitsFocusNode,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                cursorHeight: 13.0,
                style: colors.body,
                decoration: const WidgetStatePropertyAll(
                  BoxDecoration(
                    border: Border.fromBorderSide(BorderSide.none),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                textAlign: TextAlign.center,
                inputFormatters: [
                  (state.requests[index].category?.unitType.isPiece ?? true)
                      ? FilteringTextInputFormatter.digitsOnly
                      : FilteringTextInputFormatter.allow(
                          RegExp(r'\d+\.?\d*'),
                          replacementString:
                              state.requests[index].countUnitsController.text.contains('.')
                                  ? ''
                                  : '.',
                        ),
                ],
                placeholder: '---',
                placeholderStyle: colors.body.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                onChanged: (value) => _onCountUnitsChanged(index, value),
                onEditingComplete: state.requests[index].unitPriceFocusNode.requestFocus,
                validator: _validateRequiredPriceOrCount,
              ),
              TextWidget(
                size: const Size.fromHeight(30),
                backColor: colors.surface,
                // backColor: colors.surfaceContainerLowest,
                text: state.requests[index].category?.unitType.unitName ?? 'الوحدة',
                overflow: TextOverflow.fade,
                alignment: Alignment.center,
                style: colors.body.copyWith(
                  color: state.requests[index].category != null
                      ? null
                      : colors.onSurfaceVariant,
                ),

              ),
              ComboBoxForm<SimpleCategoryEntity>(
                itemsBuilder: _fetchCategories,
                onSelectedItem: (category) => _onCategorySelected(index, category, state.requests[index]),
                style: colors.body,
                controller: state.requests[index].categoryNameController,
                labelMenu: (category) => category.categoryName,
                focusNode: state.requests[index].categoryNameFocusNode,
                placeHolder: 'ادخل الطلبية',
                cursorHeight: 13.0,
                decoration: const WidgetStatePropertyAll(
                  BoxDecoration(
                    border: Border.fromBorderSide(BorderSide.none),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                minCharsForSuggestions: 2,
                validator: (value) => _validateCategory(value, state.requests[index]),
                onChanged: (value) => _onCategoryChanged(index, value),
              ),
            ],
          ),
      ],
    );
  }

  void _onAddNewCategory(BuildContext context) async {
    final bloc = context.read<BillFormBloc>();
    final category = await showDialog<CategoryEntity>(
      context: context,
      builder: (_) => const CategoryFormPage(),
    );
    if (category == null) return;

    bloc.add(BillFormRequestAdded());
    final index = bloc.state.requests.length - 1;
    bloc.add(
      BillFormCategorySelected(
        index,
        SimpleCategoryEntity(
          id: category.id,
          categoryName: category.categoryName,
          unitName: category.categoryUnit?.unitName ?? '',
          unitType: category.categoryUnit?.unitType ?? UnitType.piece,
        ),
      ),
    );
  }

  void _onAddNewPerson(BuildContext context) async {
    final bloc = context.read<BillFormBloc>();
    final person = await showDialog<PersonEntity>(
      context: context,
      builder: (_) => const CustomerFormPage(),
    );
    if (person == null) return;
    personNameController.text = person.personName;
    bloc.add(BillFormPersonSelected(person));
  }

  void _onRemoveRequest(BuildContext context, int index) async {
    final bloc = context.read<BillFormBloc>();
    final sure = await makeSure(
      context: context,
      title: 'حذف طلبية',
      content: 'هل تريد حذف الطلبية رقم ${index + 1}',
    );
    if (!sure) return;
    bloc.add(BillFormRequestRemoved(index));
  }
}
