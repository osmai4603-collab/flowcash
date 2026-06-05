import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flowcash/features/accounts/domain/entities/journal_entry_entity.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_bloc.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_event.dart';
import 'package:flowcash/features/accounts/presentation/blocs/journal_entries/journal_entries_state.dart';
import 'package:flowcash/features/accounts/presentation/widgets/journal_entry_row.dart';
import 'package:flowcash/features/accounts/presentation/widgets/journal_entry_detail_panel.dart';
import 'package:flowcash/features/accounts/presentation/pages/journal_entries/journal_entry_form_dialog.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, FluentIcons, ProgressRing;
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

  Future<void> _showEntryDialog(BuildContext context, [JournalEntryEntity? entry]) async {
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

  Future<void> _confirmDelete(BuildContext context, JournalEntryEntity entry) async {
    final bloc = context.read<JournalEntriesBloc>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: const [
            Icon(FluentIcons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Text('هل أنت متأكد من رغبتك في حذف القيد رقم "${entry.referenceNumber}"؟ سيتم حذف جميع البنود المرتبطة به وتعديل أرصدة الحسابات.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف قيد اليومية'),
          ),
        ],
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
      create: (context) => GetIt.instance<JournalEntriesBloc>()..add(const LoadJournalEntries()),
      child: BlocBuilder<JournalEntriesBloc, JournalEntriesState>(
        builder: (context, state) {
          // Client-side filtering based on search query
          final filteredEntries = state.entries.where((entry) {
            final query = _searchQuery.toLowerCase();
            final ref = entry.referenceNumber.toLowerCase();
            final desc = (entry.description ?? '').toLowerCase();
            return ref.contains(query) || desc.contains(query);
          }).toList();

          return Padding(
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
                          border: Border.all(color: theme.dividerColor.withAlpha(50)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(FluentIcons.search, color: theme.colorScheme.onSurface.withAlpha(120)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'البحث بالرقم المرجعي أو البيان...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(FluentIcons.clear, size: 18),
                                onPressed: () => _searchController.clear(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Add Entry button
                    ElevatedButton.icon(
                      onPressed: () => _showEntryDialog(context),
                      icon: const Icon(FluentIcons.add),
                      label: const Text('إضافة قيد جديد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Refresh Button
                    IconButton(
                      icon: const Icon(FluentIcons.refresh),
                      tooltip: 'إعادة تحميل البيانات',
                      onPressed: () => context.read<JournalEntriesBloc>().add(const LoadJournalEntries()),
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
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.dividerColor.withAlpha(50)),
                          ),
                          child: Column(
                            children: [
                              // List Header Row
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: theme.dividerColor.withAlpha(80),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(flex: 2, child: Text('الرقم المرجعي', style: TextStyle(fontWeight: FontWeight.bold))),
                                    const Expanded(flex: 4, child: Text('البيان العام للقيد', style: TextStyle(fontWeight: FontWeight.bold))),
                                    const Expanded(flex: 2, child: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
                                    const Expanded(flex: 1, child: Text('العملة', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                                    const Expanded(flex: 2, child: Text('المبلغ الأساسي', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                                    const Expanded(flex: 2, child: Text('التحكم', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                                  ],
                                ),
                              ),

                              // Items List
                              Expanded(
                                child: state.status == JournalEntriesStatus.loading
                                    ? const Center(child: ProgressRing())
                                    : state.status == JournalEntriesStatus.failure
                                        ? Center(child: Text('خطأ في تحميل القيود: ${state.errorMessage}'))
                                        : filteredEntries.isEmpty
                                            ? const Center(child: Text('لا توجد قيود يومية مسجلة'))
                                            : ListView.builder(
                                                itemCount: filteredEntries.length,
                                                itemBuilder: (context, index) {
                                                  final entry = filteredEntries[index];
                                                  final isSelected = state.selectedEntry?.id == entry.id;
                                                  return JournalEntryRow(
                                                    entry: entry,
                                                    isSelected: isSelected,
                                                    onTap: () {
                                                      context.read<JournalEntriesBloc>().add(SelectJournalEntry(entry));
                                                    },
                                                    onEdit: () => _showEntryDialog(context, entry),
                                                    onDelete: () => _confirmDelete(context, entry),
                                                  );
                                                },
                                              ),
                              ),
                            ],
                          ),
                        ),
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
                            border: Border.all(color: theme.dividerColor.withAlpha(50)),
                          ),
                          child: state.selectedEntry == null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(FluentIcons.note_pinned,
                                        size: 64,
                                        color: theme.colorScheme.onSurface.withAlpha(50),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'يرجى تحديد قيد يومية لعرض التفاصيل',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: theme.colorScheme.onSurface.withAlpha(150),
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
          );
        },
      ),
    );
  }
}
