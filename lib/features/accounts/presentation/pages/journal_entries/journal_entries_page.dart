import 'package:flowcash/core/formatters/money_formatter.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/widgets/table_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_state.dart';
import 'package:flowcash/features/accounts/presentation/pages/journal_entries/journal_entry_form_dialog.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class JournalEntriesPage extends StatefulWidget {
  const JournalEntriesPage({super.key});

  @override
  State<JournalEntriesPage> createState() => _JournalEntriesPageState();
}

class _JournalEntriesPageState extends State<JournalEntriesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<int, TableWidgetColumnWidth> _getTableColumnWidths() {
    return {
      0: const FixedTableWidgetColumnWidth(
        45,
        alignment: Alignment.center,
      ), // No
      1: const FlexTableWidgetColumnWidth(
        0.20,
        alignment: Alignment.centerRight,
      ), // الرقم المرجعي
      2: const FlexTableWidgetColumnWidth(
        0.38,
        alignment: AlignmentDirectional.centerStart,
      ), // البيان العام للقيد
      3: const FlexTableWidgetColumnWidth(
        0.18,
        alignment: Alignment.center,
      ), // التاريخ
      4: const FlexTableWidgetColumnWidth(
        0.18,
        alignment: Alignment.center,
      ), // المبلغ الأساسي
      5: const FlexTableWidgetColumnWidth(
        0.18,
        alignment: Alignment.center,
      ), // التحكم
    };
  }

  Future<void> _showEntryDialog(
    BuildContext context, [
    JournalEntryEntity? entry,
  ]) async {
    final bloc = context.read<JournalEntriesBloc>();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => JournalEntryFormDialog(entry: entry),
    );

    if (result == true && mounted) {
      bloc.add(const LoadJournalEntries());
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    JournalEntryEntity entry,
  ) async {
    final bloc = context.read<JournalEntriesBloc>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Material(
        color: Colors.transparent,
        child: fluent.ContentDialog(
          title: Row(
            children: const [
              fluent.Icon(fluent.FluentIcons.warning, color: Colors.red),
              SizedBox(width: 10),
              fluent.Text('تأكيد الحذف'),
            ],
          ),
          content: fluent.Text(
            'هل أنت متأكد من رغبتك في حذف القيد رقم "${entry.referenceNumber}"؟ سيتم حذف جميع البنود المرتبطة به وتعديل أرصدة الحسابات.',
          ),
          actions: [
            fluent.Button(
              onPressed: () => Navigator.of(context).pop(false),
              child: const fluent.Text('إلغاء'),
            ),
            fluent.FilledButton(
              onPressed: () => Navigator.of(context).pop(true),

              child: const fluent.Text('حذف قيد اليومية'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true && mounted) {
      bloc.add(DeleteJournalEntry(entry.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          GetIt.instance<JournalEntriesBloc>()..add(const LoadJournalEntries()),
      child: BlocBuilder<JournalEntriesBloc, JournalEntriesState>(
        builder: (context, state) {
          // Client-side filtering based on search query
          final filteredEntries = state.entries.where((entry) {
            final query = _searchQuery.toLowerCase();
            final ref = entry.referenceNumber.toLowerCase();
            final desc = (entry.description ?? '').toLowerCase();
            return ref.contains(query) || desc.contains(query);
          }).toList();

          return Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top Toolbar
                  Row(
                    children: [
                      // Search box
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.dividerColor.withAlpha(50),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              fluent.Icon(
                                fluent.FluentIcons.search,
                                color: theme.colorScheme.onSurface.withAlpha(
                                  120,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText:
                                        'البحث بالرقم المرجعي أو البيان...',
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                fluent.IconButton(
                                  icon: const fluent.Icon(
                                    fluent.FluentIcons.clear,
                                    size: 18,
                                  ),
                                  onPressed: () => _searchController.clear(),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Add Entry button
                      fluent.FilledButton(
                        onPressed: () => _showEntryDialog(context),

                        child: Row(
                          children: [
                            const fluent.Icon(fluent.FluentIcons.add),
                            const SizedBox(width: 10),
                            const fluent.Text('إضافة قيد جديد'),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Refresh Button
                      fluent.Tooltip(
                        message: 'إعادة تحميل البيانات',
                        child: fluent.IconButton(
                          icon: const fluent.Icon(fluent.FluentIcons.refresh),
                          //tooltip: 'إعادة تحميل البيانات',
                          onPressed: () => context
                              .read<JournalEntriesBloc>()
                              .add(const LoadJournalEntries()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Main Master-Detail Area
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Master List (Left Pane)
                        Expanded(
                          flex: 4,
                          child: _buildTableContent(state, filteredEntries),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableContent(
    JournalEntriesState state,
    List<JournalEntryEntity> filteredEntries,
  ) {
    final style = AppStyle.of(context);

    if (state.status == JournalEntriesStatus.loading) {
      return const Center(child: fluent.ProgressRing());
    }

    if (state.status == JournalEntriesStatus.failure) {
      return Center(
        child: fluent.Text('خطأ في تحميل القيود: ${state.errorMessage}'),
      );
    }

    if (filteredEntries.isEmpty) {
      return Center(
        child: fluent.Text(
          'لا توجد قيود يومية مسجلة ⚠️',
          style: style.bodyLarge.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return TableWidget<JournalEntryEntity>(
      columns: _getTableColumnWidths(),
      header: const [
        'No',
        'الرقم المرجعي',
        'البيان العام للقيد',
        'التاريخ',
        'المبلغ الأساسي',
        'التحكم',
      ],
      items: filteredEntries,
      onTapRow: (entry) {
        context.read<JournalEntriesBloc>().add(SelectJournalEntry(entry));
      },
      rowColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(15),
      paintRowColorWhen: (item, index) =>
          state.selectedEntry?.id == item.id || index.isEven,
      builder: (context, entry, index) {
        final bodyStyle = style.bodyStrong;
        final dateStr = DateFormat('yyyy-MM-dd').format(entry.createdAt);

        return [
          Text(
            '${index + 1}',
            textAlign: TextAlign.center,
            textDirection: .ltr,
            style: bodyStyle,
          ),
          Text(
            entry.referenceNumber,
            textAlign: TextAlign.center,
            style: bodyStyle.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            entry.description ?? 'بدون وصف',
            style: bodyStyle,
            overflow: TextOverflow.ellipsis,
          ),
          Text(dateStr, textAlign: TextAlign.center),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  AppMoneyFormatter.formatDouble(entry.baseAmount),
                  textDirection: .ltr,
                  textAlign: TextAlign.end,
                  style: bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                entry.currencyId,
                textAlign: TextAlign.center,
                style: bodyStyle,
              ),
            ],
          ),
          Row(
            spacing: Spacings.small,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              fluent.Tooltip(
                message: 'تعديل القيد',
                child: fluent.IconButton(
                  icon: const fluent.Icon(
                    fluent.FluentIcons.edit,
                    size: 16,
                    color: Colors.orange,
                  ),
                  onPressed: () => _showEntryDialog(context, entry),
                ),
              ),
              fluent.Tooltip(
                message: 'حذف القيد',
                child: fluent.IconButton(
                  icon: const fluent.Icon(
                    fluent.FluentIcons.delete,
                    size: 16,
                    color: Colors.red,
                  ),
                  onPressed: () => _confirmDelete(context, entry),
                ),
              ),
            ],
          ),
        ];
      },
    );
  }
}
