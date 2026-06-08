import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_state.dart';
import 'package:flowcash/features/accounts/presentation/widgets/journal_entry_detail_panel.dart';
import 'package:flowcash/features/accounts/presentation/pages/journal_entries/journal_entry_form_dialog.dart';
import 'package:flowcash/widgets/my_text_widget.dart';

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

  Map<int, TableColumnWidth> _getTableColumnWidths() {
    return {
      0: const FixedColumnWidth(45), // No
      1: const FlexColumnWidth(0.20), // الرقم المرجعي
      2: const FlexColumnWidth(0.38), // البيان العام للقيد
      3: const FlexColumnWidth(0.18), // التاريخ
      4: const FixedColumnWidth(60), // العملة
      5: const FlexColumnWidth(0.18), // المبلغ الأساسي
      6: const FlexColumnWidth(0.18), // التحكم
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
                          child: buildTable(theme, state, filteredEntries),
                        ),
                        const SizedBox(width: 16),

                        // Detail Panel (Right Pane)
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.dividerColor.withAlpha(50),
                              ),
                            ),
                            child: state.selectedEntry == null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        fluent.Icon(
                                          fluent.FluentIcons.note_pinned,
                                          size: 64,
                                          color: theme.colorScheme.onSurface
                                              .withAlpha(50),
                                        ),
                                        const SizedBox(height: 16),
                                        fluent.Text(
                                          'يرجى تحديد قيد يومية لعرض التفاصيل',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: theme.colorScheme.onSurface
                                                .withAlpha(150),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SingleChildScrollView(
                                      child: JournalEntryDetailPanel(
                                        entry: state.selectedEntry!,
                                        items: state.selectedEntryItems,
                                      ),
                                    ),
                                  ),
                          ),
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

  Widget buildTable(
    ThemeData theme,
    JournalEntriesState state,
    List<JournalEntryEntity> filteredEntries,
  ) {
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        fluent.Table(
          border: TableBorder.all(width: 0.50, color: colors.outline),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: _getTableColumnWidths(),
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: colors.primaryContainer.withAlpha(50),
              ),
              children: [
                TextWidget(
                  text: 'No',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(8),
                  style: textTheme.bodySmall,
                ),
                TextWidget(
                  text: 'الرقم المرجعي',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(8),
                  style: textTheme.bodySmall,
                ),
                TextWidget(
                  text: 'البيان العام للقيد',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(8),
                  style: textTheme.bodySmall,
                ),
                TextWidget(
                  text: 'التاريخ',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(8),
                  style: textTheme.bodySmall,
                ),
                TextWidget(
                  text: 'العملة',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(8),
                  style: textTheme.bodySmall,
                ),
                TextWidget(
                  text: 'المبلغ الأساسي',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(8),
                  style: textTheme.bodySmall,
                ),
                TextWidget(
                  text: 'التحكم',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(8),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: state.status == JournalEntriesStatus.loading
              ? const Center(child: fluent.ProgressRing())
              : state.status == JournalEntriesStatus.failure
              ? Center(
                  child: fluent.Text(
                    'خطأ في تحميل القيود: ${state.errorMessage}',
                  ),
                )
              : filteredEntries.isEmpty
              ? _buildEmptyEntries(textTheme)
              : _buildEntriesTable(
                  filteredEntries,
                  state,
                  colors,
                  textTheme,
                  theme,
                ),
        ),
      ],
    );
  }

  Center _buildEmptyEntries(TextTheme textTheme) {
    return Center(
      child: fluent.Text(
        'لا توجد قيود يومية مسجلة ⚠️',
        style: textTheme.bodyLarge?.copyWith(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEntriesTable(
    List<JournalEntryEntity> filteredEntries,
    JournalEntriesState state,
    ColorScheme colors,
    TextTheme textTheme,
    ThemeData theme,
  ) {
    return Material(
      child: ListView.builder(
        itemCount: filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = filteredEntries[index];
          final isSelected = state.selectedEntry?.id == entry.id;
          final dateStr = DateFormat('yyyy-MM-dd').format(entry.createdAt);

          return InkWell(
            onTap: () {
              context.read<JournalEntriesBloc>().add(SelectJournalEntry(entry));
            },
            child: fluent.Table(
              border: TableBorder.all(width: 0.50, color: colors.outline),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: _getTableColumnWidths(),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primaryContainer.withAlpha(50)
                        : (index.isEven
                              ? colors.primaryContainer.withAlpha(15)
                              : null),
                  ),
                  children: [
                    TextWidget(
                      text: '${index + 1}',
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      style: textTheme.bodySmall,
                    ),
                    TextWidget(
                      text: entry.referenceNumber,
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextWidget(
                      text: entry.description ?? 'بدون وصف',
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextWidget(
                      text: dateStr,
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                    TextWidget(
                      text: entry.currencyId == '1'
                          ? 'ر.ي'
                          : (entry.currencyId == '2' ? 'ر.س' : '\$'),
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall,
                    ),
                    TextWidget(
                      text: entry.baseAmount.toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      padding: const EdgeInsets.all(8),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
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
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
