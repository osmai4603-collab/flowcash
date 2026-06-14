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
import 'package:flutter/material.dart' show ColorScheme;
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
        updateValueCounter: sl<UpdateValueCounterUseCase>(),
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
      return Align(
        child: SizedBox(
          width: 600.0,
          child: Card(
            margin: const EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: buildActions(context),
                    ),
                    Expanded(child: buildBill(context, state)),
                  ],
                ),
              ),
            ),
          ),
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
          commandBar: Row(children: buildActions(context)),
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

  List<Widget> buildActions(BuildContext context) {
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
    final bloc = context.read<BillFormBloc>();

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
                    onChanged: (date) => bloc.add(BillFormDateChanged(date)),
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
                      onPressed: () =>
                          bloc.add(BillFormCashTypeChanged(BillCashType.cash)),
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
                      onPressed: () => bloc.add(
                        BillFormCashTypeChanged(BillCashType.future),
                      ),
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
                          state.billCounter?.formatValue.length ?? 5,
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
                    items: state.warehouses.map((store) {
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
                    onChanged: (warehouse) {
                      if (warehouse != null) {
                        bloc.add(BillFormWarehouseChanged(warehouse));
                      }
                    },
                    placeholder: const Text('المخزن'),
                    validator: (value) => value == null ? 'المخزن مطلوب' : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
              onEditingComplete: () {
                if (state.requests.isNotEmpty) {
                  state.requests[0].categoryNameFocusNode.requestFocus();
                }
              },
              placeHolder: 'ادخل اسم العميل',
              prefix: Tooltip(
                message: 'اضافة اسم جديد',
                child: IconButton(
                  icon: Icon(FluentIcons.people_add, color: colors.primary),
                  onPressed: () => _onAddNewPerson(context),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'اسم العميل مطلوب';
                }
                if (state.personSelected == null) {
                  return 'لم يتم تحديد اسم العميل من القائمة';
                }
                return null;
              },
              onChanged: (value) => bloc.add(BillFormPersonSelected(null)),
              itemsBuilder: (value) async {
                final result = await sl<GetPersonsUseCase>().call();
                return result.fold(
                  (l) => [],
                  (r) => r.where((p) => p.personName.contains(value)).toList(),
                );
              },
              labelMenu: (person) => person.personName,
              onSelectedItem: (person) {
                personNameController.text = person.personName;
                bloc.add(BillFormPersonSelected(person));
                if (state.requests.isNotEmpty) {
                  state.requests[0].categoryNameFocusNode.requestFocus();
                }
              },
            ),
          ),
          const SizedBox(height: 10),
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
              onChanged: (value) => bloc.add(BillFormNoteChanged(value)),
              maxLines: 2,
              style: Styles.titleSmall,
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
    final bloc = context.read<BillFormBloc>();

    return Table(
      border: TableBorder.all(width: 0.50),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FixedColumnWidth(20),
        1: FlexColumnWidth(0.15),
        2: FlexColumnWidth(0.15),
        3: FlexColumnWidth(0.10),
        4: FixedColumnWidth(60),
        5: FlexColumnWidth(0.50),
      },
      children: [
        TableRow(
          children: [
            TextWidget(
              size: const Size.fromHeight(25.0),
              text: '',
              alignment: Alignment.center,
              style: colors.body,
            ),
            TextWidget(
              text: 'الاجمالي',
              alignment: Alignment.center,
              style: colors.body,
            ),
            TextWidget(
              text: 'سعر الوحدة',
              alignment: Alignment.center,
              style: colors.body,
            ),
            TextWidget(
              text: 'الكمية',
              alignment: Alignment.center,
              style: colors.body,
            ),
            TextWidget(
              text: 'الوحدة',
              alignment: Alignment.center,
              style: colors.body,
            ),
            TextWidget(
              text: 'الوصف',
              alignment: Alignment.center,
              style: colors.body,
            ),
          ],
        ),
        ...List.generate(state.requests.length, (index) {
          final request = state.requests[index];
          return TableRow(
            children: [
              HoverButton(
                onPressed: () => _onRemoveRequest(context, index),
                builder: (context, states) {
                  return TextWidget(
                    size: const Size.fromHeight(30),
                    text: '${index + 1}',
                    alignment: Alignment.center,
                    style: colors.body,
                  );
                },
              ),
              SizedBox(
                height: 28.0,
                child: TextFormBox(
                  textInputAction: TextInputAction.done,
                  controller: request.totalPriceController,
                  focusNode: request.totalPriceFocusNode,
                  keyboardType: TextInputType.number,
                  textDirection: .ltr,
                  cursorHeight: 13.0,
                  style: colors.body,
                  textAlign: TextAlign.center,
                  inputFormatters: [ThousandsFormatter(allowFraction: true)],
                  placeholder: '---',
                  placeholderStyle: colors.body.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  padding: EdgeInsets.only(
                    right: 2,
                    left: 2,
                    bottom: isDesktop ? 18.0 : 16.0,
                  ),
                  onChanged: (value) =>
                      bloc.add(BillFormTotalPriceChanged(index, value)),
                  onEditingComplete: () {
                    index + 1 == state.requests.length
                        ? bloc.add(BillFormRequestAdded())
                        : state.requests[index + 1].categoryNameFocusNode
                              .requestFocus();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'مطلوب';
                    final doubleVal = double.tryParse(
                      value.replaceAll(',', ''),
                    );
                    if (doubleVal == null || doubleVal <= 0) {
                      return 'يجب أن يكون أكبر من 0';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                height: 28.0,
                child: Align(
                  child: TextFormBox(
                    textInputAction: TextInputAction.next,
                    controller: request.unitPriceController,
                    focusNode: request.unitPriceFocusNode,
                    keyboardType: TextInputType.number,
                    textDirection: .ltr,
                    cursorHeight: 13.0,
                    style: colors.body,
                    textAlign: TextAlign.center,
                    inputFormatters: [ThousandsFormatter(allowFraction: true)],
                    placeholder: '---',
                    placeholderStyle: colors.body.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.only(
                      right: 2,
                      left: 2,
                      bottom: isDesktop ? 18.0 : 16.0,
                    ),
                    onChanged: (value) =>
                        bloc.add(BillFormUnitPriceChanged(index, value)),
                    onEditingComplete: request.totalPriceFocusNode.requestFocus,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'مطلوب';
                      final doubleVal = double.tryParse(
                        value.replaceAll(',', ''),
                      );
                      if (doubleVal == null || doubleVal <= 0) {
                        return 'يجب أن يكون أكبر من 0';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 28.0,
                child: Align(
                  child: TextFormBox(
                    textInputAction: TextInputAction.next,
                    controller: request.countUnitsController,
                    focusNode: request.countUnitsFocusNode,
                    keyboardType: TextInputType.number,
                    textDirection: .ltr,
                    cursorHeight: 13.0,
                    style: colors.body,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      (request.category?.unitType.isPiece ?? true)
                          ? FilteringTextInputFormatter.digitsOnly
                          : FilteringTextInputFormatter.allow(
                              RegExp(r'\d+\.?\d*'),
                              replacementString:
                                  request.countUnitsController.text.contains(
                                    '.',
                                  )
                                  ? ''
                                  : '.',
                            ),
                    ],
                    placeholder: '---',
                    placeholderStyle: colors.body.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    padding: EdgeInsets.only(
                      right: 2,
                      left: 2,
                      bottom: isDesktop ? 18.0 : 16.0,
                    ),
                    onChanged: (value) =>
                        bloc.add(BillFormCountUnitsChanged(index, value)),
                    onEditingComplete: () =>
                        request.unitPriceFocusNode.requestFocus(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'مطلوب';
                      final doubleVal = double.tryParse(
                        value.replaceAll(',', ''),
                      );
                      if (doubleVal == null || doubleVal <= 0) {
                        return 'يجب أن يكون أكبر من 0';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Container(
                height: 28.0,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(3.0),
                child: Text(
                  request.category?.unitType.unitName ?? 'الوحدة',
                  overflow: TextOverflow.fade,
                  style: colors.body.copyWith(
                    color: request.category != null
                        ? null
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
                child: Align(
                  child: ComboBoxForm<SimpleCategoryEntity>(
                    itemsBuilder: (value) async {
                      final result =
                          await sl<GetCategoriesWhereContainsNameUseCase>()
                              .call(value);
                      return result.fold((l) => [], (r) => r);
                    },
                    onSelectedItem: (category) =>
                        bloc.add(BillFormCategorySelected(index, category)),
                    style: colors.body,
                    controller: request.categoryNameController,
                    labelMenu: (category) => category.categoryName,
                    focusNode: request.categoryNameFocusNode,
                    placeHolder: 'ادخل الطلبية',
                    cursorHeight: 13.0,
                    minCharsForSuggestions: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'مطلوب';
                      if (request.category == null) return 'غير محدد';
                      return null;
                    },
                    onChanged: (value) =>
                        bloc.add(BillFormCategorySelected(index, null)),
                  ),
                ),
              ),
            ],
          );
        }),
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
