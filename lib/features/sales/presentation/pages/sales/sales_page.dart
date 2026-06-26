import 'dart:io';

import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/features/sales/presentation/pages/sales/bill_form_page.dart';
import 'package:flowcash/features/transactions/domain/entities/bill_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_page/sales_page_bloc.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_page/sales_page_event.dart';
import 'package:flowcash/features/sales/presentation/bloc/sales_page/sales_page_state.dart';
import 'package:flowcash/features/currencies/domain/usecases/exchange_price_repository_usecases.dart';
import 'package:flowcash/features/transactions/domain/usecases/post_bill_to_accounting_use_case.dart';
import 'package:flowcash/features/transactions/domain/usecases/post_bill_to_inventory_use_case.dart';
import 'package:flowcash/features/transactions/domain/usecases/post_bill_to_costing_use_case.dart';
import 'package:flowcash/user_session.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/features/injection_container.dart';

import '../../../../../core/enums/invoice_type_enum.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesPageBloc>(
      create: (_) => SalesPageBloc(
        getBillsWithCustomerUseCase: sl(),
        deleteBillUseCase: sl(),
        postBillToAccountingUseCase: sl<PostBillToAccountingUseCase>(),
        postBillToInventoryUseCase: sl<PostBillToInventoryUseCase>(),
        postBillToCostingUseCase: sl<PostBillToCostingUseCase>(),
        getExchangePricesUseCase: sl<GetExchangePricesUseCase>(),
        userSession: sl<UserSession>(),
      )..add(LoadSalesPageEvent()),
      child: const _SalesPageView(),
    );
  }
}

class _SalesPageView extends StatefulWidget {
  const _SalesPageView();

  @override
  State<_SalesPageView> createState() => _SalesPageViewState();
}

class _SalesPageViewState extends State<_SalesPageView> {
  final searchBarController = TextEditingController();

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  Widget _buildHeaderCell(
    String text,
    AppStyle colors, {
    Alignment alignment = Alignment.center,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(color: colors.surfaceContainerHigh),
      child: fluent.Text(
        text,
        textAlign: TextAlign.center,
        style: colors.body.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildColumn(BuildContext context, List<SalesDocument> sales) {
    final colors = AppStyle.of(context);
    if (sales.isEmpty) {
      return const Center(child: fluent.Text('لا يوجد مبيعات متاحة حالياً'));
    }

    const columnWidths = {
      0: FlexColumnWidth(0.20), // الفاتورة
      1: FlexColumnWidth(0.16), // اسم العميل
      2: FlexColumnWidth(0.12), // إجمالي الفاتورة
      3: FlexColumnWidth(0.09), // التاريخ
      4: FlexColumnWidth(0.11), // حالة الترحيل
      5: FlexColumnWidth(0.11), // الترحيل المخزني
      6: FlexColumnWidth(0.11), // تكلفة الفاتورة
      7: FixedColumnWidth(100.0), // العمليات
    };

    return Column(
      children: [
        // Fixed Header Table
        Table(
          border: TableBorder.all(width: 0.5, color: colors.outlineVariant),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: columnWidths,
          children: [
            TableRow(
              decoration: BoxDecoration(color: colors.surfaceContainerHigh),
              children: [
                _buildHeaderCell(
                  'الفاتورة',
                  colors,
                  alignment: Alignment.centerRight,
                ),
                _buildHeaderCell(
                  'اسم العميل',
                  colors,
                  alignment: Alignment.centerRight,
                ),
                _buildHeaderCell(
                  'إجمالي الفاتورة',
                  colors,
                  alignment: Alignment.centerRight,
                ),
                _buildHeaderCell('التاريخ', colors),
                _buildHeaderCell('حالة الترحيل', colors),
                _buildHeaderCell('الترحيل المخزني', colors),
                _buildHeaderCell('تكلفة الفاتورة', colors),
                _buildHeaderCell('العمليات', colors),
              ],
            ),
          ],
        ),
        // Scrollable List of Rows using ListView.builder
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: colors.outlineVariant, width: 0.5),
                right: BorderSide(color: colors.outlineVariant, width: 0.5),
                bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
              ),
            ),
            child: ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final item = sales[index];
                final isEven = index.isEven;
                final rowColor = isEven
                    ? null
                    : colors.surfaceContainerHighest.withValues(alpha: 0.12);

                return Table(
                  border: TableBorder(
                    verticalInside: BorderSide(
                      color: colors.outlineVariant,
                      width: 0.5,
                    ),
                    bottom: BorderSide(
                      color: colors.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: columnWidths,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: rowColor),
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 6.0,
                          ),
                          child: fluent.Text(
                            item.billHistory,
                            overflow: TextOverflow.ellipsis,
                            style: colors.body,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 6.0,
                          ),
                          child: fluent.Text(
                            item.customerName,
                            overflow: TextOverflow.ellipsis,
                            style: colors.body,
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 6.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              fluent.Text(
                                AppMoneyFormatter.formatDouble(item.totalAmount),
                                style: colors.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              fluent.Text(
                                item.currencyId,
                                style: colors.body.copyWith(
                                  fontSize:
                                      (colors.body.fontSize ?? 14.0) * 0.75,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 6.0,
                          ),
                          child: fluent.Text(
                            '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}',
                            style: colors.body,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 4.0,
                          ),
                          child: TextButton(
                            child: fluent.Text(
                              item.isJournalPosted
                                  ? 'مرحل محاسبياً'
                                  : 'غير مرحل محاسبياً',
                              style: colors.body.copyWith(
                                color: item.isJournalPosted
                                    ? colors.success
                                    : colors.error,
                                fontWeight: item.isJournalPosted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            onPressed: () => _onPostJournal(item),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 4.0,
                          ),
                          child: TextButton(
                            child: fluent.Text(
                              item.isInventoryPosted
                                  ? 'مرحل مخزنياً'
                                  : 'غير مرحل مخزنياً',
                              style: colors.body.copyWith(
                                color: item.isInventoryPosted
                                    ? colors.success
                                    : colors.error,
                                fontWeight: item.isInventoryPosted
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            onPressed: () => _onPostInventory(item),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 4.0,
                          ),
                          child: TextButton(
                            child: fluent.Text(
                              item.isCostGoodPosted
                                  ? 'مرحلة للتكلفة'
                                  : 'إلى فواتير التكلفة',
                              style: colors.body.copyWith(
                                color: item.isCostGoodPosted
                                    ? colors.success
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                            onPressed: () => _onPostCost(item),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 6.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              fluent.Tooltip(
                                message: 'تعديل',
                                child: fluent.IconButton(
                                  icon: const fluent.Icon(
                                    fluent.FluentIcons.edit,
                                    size: 14,
                                  ),
                                  onPressed: () => _onEditSaleBill(item),
                                ),
                              ),
                              const SizedBox(width: 4),
                              fluent.Tooltip(
                                message: 'حذف',
                                child: fluent.IconButton(
                                  icon: fluent.Icon(
                                    fluent.FluentIcons.delete,
                                    size: 14,
                                    color: colors.error,
                                  ),
                                  onPressed: () => _onDeleteSaleBill(item),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    return fluent.ScaffoldPage(
      header: fluent.PageHeader(
        title: Row(
          spacing: Spacings.medium,
          children: [
            const Expanded(child: fluent.Text('المبيعات')),
            SizedBox(
              width: isDesktop ? 400.0 : 250.0,
              child: BlocBuilder<SalesPageBloc, SalesPageState>(
                builder: (context, state) {
                  return fluent.TextBox(
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: fluent.Icon(
                        fluent.FluentIcons.search,
                        color: colors.surfaceContainerHigh,
                      ),
                    ),
                    placeholder: 'ابحث عن فاتورة أو عميل',
                    controller: searchBarController,
                    onChanged: (value) => context.read<SalesPageBloc>().add(
                      SearchSalesPageEvent(value),
                    ),
                  );
                },
              ),
            ),
            fluent.Tooltip(
              message: 'إعادة تحميل البيانات',
              child: fluent.IconButton(
                icon: const fluent.Icon(fluent.FluentIcons.refresh),
                onPressed: () =>
                    context.read<SalesPageBloc>().add(RefreshSalesPageEvent()),
              ),
            ),
            fluent.FilledButton(
              onPressed: _onAddNewSaleBill,
              child: Row(
                spacing: Spacings.small,
                children: [
                  fluent.Icon(fluent.FluentIcons.add),
                  const fluent.Text('إضافة سند مبيعات جديد'),
                ],
              ),
            ),
          ],
        ),
      ),
      content: BlocListener<SalesPageBloc, SalesPageState>(
        listener: (context, state) {
          if (state is SalesPageOperationFailure) {
            error(context: context, toast: state.message);
          } else if (state is SalesPageOperationSuccess) {
            successToast(
              context: context,
              title: 'نجاح العملية',
              toast: state.message,
            );
          }
        },
        child: BlocBuilder<SalesPageBloc, SalesPageState>(
          builder: (context, state) {
            if (state is SalesPageLoadInProgress || state is SalesPageInitial) {
              return const Center(child: fluent.ProgressRing());
            }
            if (state is SalesPageLoadSuccess) {
              return buildColumn(context, state.sales);
            }
            if (state is SalesPageOperationFailure) {
              return Center(child: fluent.Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _onAddNewSaleBill() async {
    final bloc = context.read<SalesPageBloc>();
    final saleBill = await showDialog<BillEntity>(
      context: context,
      builder: (context) => const BillFormPage(billType: InvoiceType.sales),
    );
    if (saleBill != null && context.mounted) {
      bloc.add(AddSalesDocumentEvent(saleBill));
    }
  }

  void _onEditSaleBill(SalesDocument doc) async {
    final sure = await makeSure(
      context: context,
      title: 'تأكيد التعديل',
      content: 'هل تريد تعديل ${doc.billHistory}؟',
    );
    if (!sure || !context.mounted) return;

    final updatedBill = await showDialog<BillEntity>(
      context: context,
      builder: (context) =>
          BillFormPage(bill: doc.rawBill, billType: InvoiceType.sales),
    );
    if (updatedBill != null && context.mounted) {
      context.read<SalesPageBloc>().add(UpdateSalesDocumentEvent(updatedBill));
    }
  }

  void _onDeleteSaleBill(SalesDocument doc) async {
    final sure = await makeSure(
      context: context,
      title: 'تأكيد الحذف',
      content: 'هل أنت متأكد من حذف ${doc.billHistory}؟ سيتم حذفها نهائياً.',
    );
    if (!sure || !context.mounted) return;

    context.read<SalesPageBloc>().add(DeleteSalesDocumentEvent(doc.billId));
  }

  void _onPostJournal(SalesDocument doc) async {
    final sure = await makeSure(
      context: context,
      title: doc.isJournalPosted
          ? 'إلغاء الترحيل المحاسبي'
          : 'تأكيد الترحيل المحاسبي',
      content: doc.isJournalPosted
          ? 'هل أنت متأكد من إلغاء الترحيل المحاسبي لـ ${doc.billHistory}؟'
          : 'هل تريد ترحيل ${doc.billHistory} محاسبياً؟',
    );
    if (!sure || !context.mounted) return;

    if (!doc.isJournalPosted) {
      context
          .read<SalesPageBloc>()
          .add(PostSalesDocumentToAccountingEvent(doc));
    } else {
      // Currently we only support posting, not un-posting from here yet.
      // But we can show a message.
      error(context: context, toast: 'إلغاء الترحيل غير مدعوم حالياً من هنا.');
    }
  }

  void _onPostInventory(SalesDocument doc) async {
    final sure = await makeSure(
      context: context,
      title: doc.isInventoryPosted
          ? 'إلغاء الترحيل المخزني'
          : 'تأكيد الترحيل المخزني',
      content: doc.isInventoryPosted
          ? 'هل أنت متأكد من إلغاء الترحيل المخزني لـ ${doc.billHistory}؟'
          : 'هل تريد ترحيل ${doc.billHistory} مخزنياً؟',
    );
    if (!sure || !context.mounted) return;

    if (!doc.isInventoryPosted) {
      context.read<SalesPageBloc>().add(PostSalesDocumentToInventoryEvent(doc));
    } else {
      error(context: context, toast: 'إلغاء الترحيل غير مدعوم حالياً من هنا.');
    }
  }

  void _onPostCost(SalesDocument doc) async {
    final sure = await makeSure(
      context: context,
      title: doc.isCostGoodPosted
          ? 'إلغاء ترحيل التكلفة'
          : 'تأكيد ترحيل التكلفة',
      content: doc.isCostGoodPosted
          ? 'هل أنت متأكد من إلغاء ترحيل التكلفة لـ ${doc.billHistory}؟'
          : 'هل تريد ترحيل ${doc.billHistory} إلى فواتير التكلفة؟',
    );
    if (!sure || !context.mounted) return;

    if (!doc.isCostGoodPosted) {
      context.read<SalesPageBloc>().add(PostSalesDocumentToCostingEvent(doc));
    } else {
      error(context: context, toast: 'إلغاء الترحيل غير مدعوم حالياً من هنا.');
    }
  }
}
