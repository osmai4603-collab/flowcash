import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategories/subcategories_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategories/subcategories_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategories/subcategories_state.dart';
import 'package:flowcash/features/categories/presentation/pages/subcategories/subcategory_form_page.dart';
import 'package:flowcash/features/categories/presentation/pages/units/unit_form_page.dart';
import 'package:flowcash/features/injection_container.dart';

import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SubcategoriesPage extends StatefulWidget {
  const SubcategoriesPage({super.key});

  @override
  State<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends State<SubcategoriesPage> {
  bool get isDesktop => Platform.isLinux || Platform.isWindows;
  bool _isShowingGeneratingDialog = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    return BlocProvider(
      create: (_) =>
          sl<SubcategoriesBloc>()..add(const LoadSubcategoriesEvent()),
      child: Builder(
        builder: (context) {
          return BlocListener<SubcategoriesBloc, SubcategoriesState>(
            listener: (context, state) async {
              if (state is SubcategoriesLoadFailure) {
                if (_isShowingGeneratingDialog) {
                  Navigator.of(context, rootNavigator: true).pop();
                  _isShowingGeneratingDialog = false;
                }
                error(context: context, toast: state.message);
                return;
              }

              if (state is SubcategoriesLoadSuccess) {
                if (state.isGenerating && !_isShowingGeneratingDialog) {
                  _isShowingGeneratingDialog = true;
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogCtx) => const fluent.ContentDialog(
                      title: fluent.Text('توليد الأصناف'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          fluent.ProgressRing(),
                          SizedBox(height: 16),
                          fluent.Text('جاري توليد الأصناف، يرجى الانتظار...'),
                        ],
                      ),
                    ),
                  ).then((_) {
                    _isShowingGeneratingDialog = false;
                  });
                } else if (!state.isGenerating && _isShowingGeneratingDialog) {
                  Navigator.of(context, rootNavigator: true).pop();
                  _isShowingGeneratingDialog = false;
                }

                if (state.generatedCategoryNames != null) {
                  final names = state.generatedCategoryNames!;
                  await showDialog<void>(
                    context: context,
                    builder: (ctx) => fluent.ContentDialog(
                      title: fluent.Text(
                        names.isEmpty ? 'نتيجة التوليد' : 'الأصناف المولدة',
                      ),
                      content: SizedBox(
                        width: 400,
                        child: names.isEmpty
                            ? const fluent.Text('لا يوجد اصناف تم توليدها')
                            : SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: names
                                      .map((n) => fluent.Text('• $n'))
                                      .toList(),
                                ),
                              ),
                      ),
                      actions: [
                        fluent.Button(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const fluent.Text('حسناً'),
                        ),
                      ],
                    ),
                  );
                  if (context.mounted) {
                    context.read<SubcategoriesBloc>().add(
                      const ClearGeneratedCategoriesEvent(),
                    );
                  }
                  return;
                }

                if (state.statusMessage != null) {
                  successToast(context: context, toast: state.statusMessage!);
                }
              }
            },
            child: fluent.ScaffoldPage(
              header: fluent.PageHeader(
                title: Row(
                  spacing: Spacings.medium,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: fluent.Text('الأصناف الفرعية')),
                    SizedBox(
                      width: isDesktop ? 400.0 : 250.0,
                      child: BlocBuilder<SubcategoriesBloc, SubcategoriesState>(
                        builder: (context, state) {
                          return fluent.TextBox(
                            prefix: Padding(
                              padding: Paddings.smallAll,
                              child: fluent.Icon(
                                fluent.FluentIcons.search,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            placeholder: 'ابحث عن نوع صنف هنا',
                            onChanged: (value) => context
                                .read<SubcategoriesBloc>()
                                .add(SearchSubcategoriesEvent(value)),
                          );
                        },
                      ),
                    ),
                    fluent.Tooltip(
                      message: 'إعادة تحميل البيانات',
                      child: fluent.IconButton(
                        icon: const fluent.Icon(fluent.FluentIcons.refresh),
                        onPressed: () => context.read<SubcategoriesBloc>().add(
                          const RefreshSubcategoriesEvent(),
                        ),
                      ),
                    ),
                    fluent.FilledButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          fluent.Icon(fluent.FluentIcons.add),
                          SizedBox(width: 6),
                          fluent.Text('اضافة صنف فرعي جديد'),
                        ],
                      ),
                      onPressed: () => _onAddSubcategory(context),
                    ),
                  ],
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.all(4),
                child: BlocBuilder<SubcategoriesBloc, SubcategoriesState>(
                  builder: (context, state) {
                    if (state is SubcategoriesLoadInProgress) {
                      return const Center(child: fluent.ProgressRing());
                    }
                    if (state is SubcategoriesLoadFailure) {
                      return Center(child: fluent.Text(state.message));
                    }
                    if (state is SubcategoriesLoadSuccess) {
                      return buildSubcategories(context, state);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onAddSubcategory(BuildContext context) async {
    final newSubcategory = await showDialog<SubcategoryEntity>(
      context: context,
      builder: (ctx) => const SubcategoryFormPage(),
    );

    if (newSubcategory != null && context.mounted) {
      context.read<SubcategoriesBloc>().add(
        AddSubcategoryEvent(newSubcategory),
      );
    }
  }

  Widget buildSubcategories(
    BuildContext context,
    SubcategoriesLoadSuccess state,
  ) {
    final colors = AppStyle.of(context);
    if (state.catalogs.isEmpty) {
      return TextWidget(
        text: 'لا يوجد اي أصناف فرعية',
        alignment: Alignment.center,
        textAlign: TextAlign.center,
        padding: Paddings.mediumAll,
      );
    }
    return Column(
      children: [
        fluent.Table(
          border: fluent.TableBorder.all(width: 0.5, color: colors.outline),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: getWidths(),
          children: [
            TableRow(
              children: [
                TextWidget(
                  text: 'No',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  padding: const EdgeInsets.all(4),
                  style: colors.bodyStrong,
                ),
                TextWidget(
                  text: 'اسم النوع',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(4),
                  style: colors.bodyStrong,
                ),
                TextWidget(
                  text: 'الصنف الرئيسي',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(4),
                  style: colors.bodyStrong,
                ),
                TextWidget(
                  text: 'الخصائص والسمات',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(4),
                  style: colors.bodyStrong,
                ),
                TextWidget(
                  text: 'العمليات',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(4),
                  style: colors.bodyStrong,
                ),
              ],
            ),
          ],
        ),
        Expanded(child: listView(context, state)),
      ],
    );
  }

  Map<int, TableColumnWidth> getWidths() {
    return const {
      0: FixedColumnWidth(50), // No
      1: FixedColumnWidth(150), // اسم النوع
      2: FixedColumnWidth(150), // الصنف الرئيسي
      3: FlexColumnWidth(), // الخصائص والسمات
      4: FixedColumnWidth(80), // العمليات
    };
  }

  Widget listView(BuildContext context, SubcategoriesLoadSuccess state) {
    final filteredSubcategories = state.searchQuery.isEmpty
        ? state.catalogs
        : state.catalogs
              .where(
                (catalog) => catalog.catalogName.contains(state.searchQuery),
              )
              .toList();
    if (filteredSubcategories.isEmpty) {
      return TextWidget(
        text: 'لا يوجد اي نوع',
        alignment: Alignment.center,
        textAlign: TextAlign.center,
        padding: Paddings.mediumAll,
      );
    }
    final style = AppStyle.of(context);
    return Builder(
      builder: (context) {
        return ListView.builder(
          itemCount: filteredSubcategories.length,
          itemBuilder: (rowContext, index) {
            final catalog = filteredSubcategories[index];
            final mainCategoryName = state.mainCategories
                .where((cat) => cat.id == catalog.mainCategoryId)
                .map((cat) => cat.name)
                .firstWhere(
                  (_) => true,
                  orElse: () => 'غير معروف (${catalog.mainCategoryId})',
                );
            final widths = getWidths();
            return fluent.Table(
              border: fluent.TableBorder.all(width: 0.5, color: style.outline),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: widths,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? style.surfaceContainer : null,
                  ),
                  children: [
                    TextWidget(
                      text: '${index + 1}',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      padding: const EdgeInsets.all(4),
                      style: style.body,
                    ),
                    TextWidget(
                      text: catalog.catalogName,
                      padding: const EdgeInsets.all(4),
                      style: style.body,
                    ),
                    TextWidget(
                      text: mainCategoryName,
                      padding: const EdgeInsets.all(4),
                      style: style.body,
                    ),
                    buildPropertiesTable(context, catalog, state),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        fluent.GestureDetector(
                          child: Tooltip(
                            message: 'تعريف اصناف ${catalog.catalogName}',
                            child: fluent.Icon(
                              fluent.FluentIcons.generate,
                              color: style.primary,
                              size: 20,
                            ),
                          ),
                          onTap: () =>
                              _onDefineCategoriesPressed(catalog, context),
                        ),
                        const SizedBox(width: 8),
                        fluent.GestureDetector(
                          child: Tooltip(
                            message: 'حذف نوع الصنف',
                            child: fluent.Icon(
                              fluent.FluentIcons.delete,
                              color: style.error,
                              size: 20,
                            ),
                          ),
                          onTap: () =>
                              _onDeleteSubcategory(rowContext, catalog),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildPropertiesTable(
    BuildContext context,
    SubcategoryEntity catalog,
    SubcategoriesLoadSuccess state,
  ) {
    final colors = AppStyle.of(context);
    final catalogProperties = state.properties
        .where((p) => p.mainCategoryId == catalog.mainCategoryId)
        .toList();

    if (catalogProperties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'لا توجد خصائص معرفة لهذا الصنف',
            style: colors.caption?.copyWith(color: colors.outline),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: fluent.Table(
        border: fluent.TableBorder.all(
          width: 0.5,
          color: colors.outline.withValues(alpha: 0.3),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FixedColumnWidth(120), // اسم الخاصية
          1: FlexColumnWidth(), // القيم / الوحدات
          2: FixedColumnWidth(40), // إضافة
        },
        children: catalogProperties.map((property) {
          final propertyInfos = state.infos
              .where(
                (info) =>
                    info.subcategoryId == catalog.id &&
                    info.propertyId == property.id,
              )
              .toList();
          propertyInfos.sort(
            (a, b) => (a.unitName ?? '').compareTo(b.unitName ?? ''),
          );

          Widget valuesWidget;
          if (propertyInfos.isEmpty) {
            valuesWidget = Text(
              'لم يتم التحديد',
              style: colors.caption.copyWith(color: colors.outline),
              textAlign: TextAlign.center,
            );
          } else if (property.isSingle) {
            valuesWidget = Text(
              property.isCategoryUnit
                  ? property.unitType.fullUnitName
                  : propertyInfos.first.unitName ?? '',
              textAlign: TextAlign.center,
              style: colors.body,
            );
          } else {
            final values = propertyInfos
                .map((info) => info.unitName ?? '')
                .toSet()
                .join(', ');
            valuesWidget = Text(
              values,
              textAlign: TextAlign.center,
              style: colors.body,
            );
          }

          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  property.propertyName,
                  style: colors.bodyStrong,
                  textAlign: TextAlign.start,
                ),
              ),
              Padding(padding: const EdgeInsets.all(6.0), child: valuesWidget),
              Center(
                child: fluent.IconButton(
                  icon: const fluent.Icon(fluent.FluentIcons.add, size: 14),
                  onPressed: () =>
                      _onAddPropertyInfo(context, catalog, property),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _onDeleteSubcategory(
    BuildContext context,
    SubcategoryEntity catalog,
  ) async {
    final sure = await makeSure(
      title: 'حذف نوع الصنف',
      content: 'هل تريد حذف النوع ${catalog.catalogName}?',
      context: context,
    );

    if (sure && context.mounted) {
      context.read<SubcategoriesBloc>().add(DeleteSubcategoryEvent(catalog.id));
    }
  }

  Future<void> _onAddPropertyInfo(
    BuildContext context,
    SubcategoryEntity catalog,
    CategoryPropertyEntity property,
  ) async {
    final bloc = context.read<SubcategoriesBloc>();
    if (context.mounted) {
      final unit = await showDialog<UnitEntity>(
        barrierDismissible: false,
        context: context,
        builder: (_) => UnitFormPage(property: property),
      );
      if (unit != null && context.mounted) {
        bloc.add(
          AddSubcategoryUnitEvent(
            catalogId: catalog.id,
            unitId: unit.id,
            propertyId: property.id,
          ),
        );
      }
    }
  }

  void _onDefineCategoriesPressed(
    SubcategoryEntity subcategory,
    BuildContext context,
  ) async {
    final bloc = context.read<SubcategoriesBloc>();
    final sure = await makeSure(
      title: 'تعريف الأصناف',
      content: 'هل تريد انشاء الأصناف الخاصة ب${subcategory.catalogName}?',
      context: context,
    );
    if (sure && context.mounted) {
      bloc.add(GenerateSubcategoryCategoriesEvent(subcategory.id));
    }
  }
}
