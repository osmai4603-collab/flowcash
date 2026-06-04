import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
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
import 'package:flowcash/core/theme/styles.dart';

class SubcategoriesPage extends StatefulWidget {
  final MainCategoryEntity mainCategory;

  const SubcategoriesPage({super.key, required this.mainCategory});

  @override
  State<SubcategoriesPage> createState() => _SubcategoriesPageState();
}

class _SubcategoriesPageState extends State<SubcategoriesPage> {
  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SubcategoriesBloc>()..add(LoadSubcategoriesEvent(widget.mainCategory.id)),
      child: BlocListener<SubcategoriesBloc, SubcategoriesState>(
        listener: (context, state) async {
          if (state is SubcategoriesLoadFailure) {
            error(context: context, toast: state.message);
            return;
          }

          if (state is SubcategoriesLoadSuccess && state.generatedCategoryNames != null) {
            final names = state.generatedCategoryNames!;
            await showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(names.isEmpty ? 'نتيجة التوليد' : 'الأصناف المولدة'),
                content: SizedBox(
                  width: 400,
                  child: names.isEmpty
                      ? const Text('لا يوجد اصناف تم توليدها')
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: names.map((n) => Text('• $n')).toList(),
                          ),
                        ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('حسناً'),
                  ),
                ],
              ),
            );
            if (context.mounted) {
              context.read<SubcategoriesBloc>().add(const ClearGeneratedCategoriesEvent());
            }
            return;
          }

          if (state is SubcategoriesLoadSuccess && state.statusMessage != null) {
            successToast(context: context, toast: state.statusMessage!);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(widget.mainCategory.name)),
                SizedBox(
                  height: 40.0,
                  width: isDesktop ? 400.0 : 250.0,
                  child: BlocBuilder<SubcategoriesBloc, SubcategoriesState>(
                    builder: (context, state) {
                      return SearchBar(
                        elevation: const WidgetStatePropertyAll(0.0),
                        backgroundColor: WidgetStatePropertyAll(
                          ColorScheme.of(
                            context,
                          ).secondary.withValues(alpha: 0.25),
                        ),
                        leading: const Icon(
                          Icons.search_outlined,
                          color: Colors.white70,
                        ),
                        hintText: 'ابحث عن نوع صنف هنا',
                        onChanged: (value) => context
                            .read<SubcategoriesBloc>()
                            .add(SearchSubcategoriesEvent(value)),
                        textStyle: isDesktop
                            ? WidgetStatePropertyAll(
                                Styles.titleMedium.copyWith(
                                  color: Colors.white,
                                ),
                              )
                            : WidgetStatePropertyAll(
                                Styles.titleSmall.copyWith(color: Colors.white),
                              ),
                        shape: const WidgetStatePropertyAll(
                          RoundedRectangleBorder(),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          tooltip: 'اضافة نوع صنف جديد',
                          onPressed: () async {
                            final catalog = await showDialog<SubcategoryEntity>(
                              context: context,
                              builder: (_) => SubcategoryFormPage(
                                mainCategoryId: widget.mainCategory.id,
                              ),
                            );
                            if (catalog != null && context.mounted) {
                              context.read<SubcategoriesBloc>().add(
                                AddSubcategoryEvent(catalog),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(4),
            child: BlocBuilder<SubcategoriesBloc, SubcategoriesState>(
              builder: (context, state) {
                if (state is SubcategoriesLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SubcategoriesLoadFailure) {
                  return Center(
                    child: Text(state.message),
                  );
                }
                if (state is SubcategoriesLoadSuccess) {
                  return buildSubcategories(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSubcategories(BuildContext context, SubcategoriesLoadSuccess state) {
    final textTheme = TextTheme.of(context);
    final colors = ColorScheme.of(context);
    if (state.catalogs.isEmpty) {
      return TextWidget(
        text: 'لا يوجد اي نوع صنف ${widget.mainCategory.name}',
        alignment: Alignment.center,
        textAlign: TextAlign.center,
        padding: Paddings.mediumAll,
      );
    }
    return Column(
      children: [
        Table(
          border: TableBorder.all(width: 0.5, color: colors.onSurface),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: getWidths(state.properties),
          children: [
            TableRow(
              children: [
                TextWidget(
                  text: 'No',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  padding: const EdgeInsets.all(4),
                  style: textTheme.labelMedium,
                ),
                TextWidget(
                  text: 'اسم النوع',
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(4),
                  style: textTheme.labelMedium,
                ),
                ...state.properties.map(
                  (property) => TextWidget(
                    text: 'ال${property.propertyName}',
                    textAlign: TextAlign.center,
                    padding: const EdgeInsets.all(4),
                    style: textTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 1),
              ],
            ),
          ],
        ),
        Expanded(child: listView(context, state)),
      ],
    );
  }

  Map<int, TableColumnWidth> getWidths(
    List<CategoryPropertyEntity> properties,
  ) {
    final widths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(40),
      1: const FixedColumnWidth(150),
    };
    for (var index = 0; index < properties.length; index++) {
      widths.addAll({
        widths.length: FlexColumnWidth(1 / (properties.length + 1)),
      });
    }
    widths.addAll({widths.length: const FixedColumnWidth(40)});
    return widths;
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
        text: 'لا يوجد اي نوع للصنف ${widget.mainCategory.name}',
        alignment: Alignment.center,
        textAlign: TextAlign.center,
        padding: Paddings.mediumAll,
      );
    }
    final textTheme = TextTheme.of(context);
    final colors = ColorScheme.of(context);
    return Builder(
      builder: (context) {
        return ListView.builder(
          itemCount: filteredSubcategories.length,
          itemBuilder: (rowContext, index) {
            final catalog = filteredSubcategories[index];
            final widths = getWidths(state.properties);
            return Table(
              textDirection: TextDirection.rtl,
              border: TableBorder.all(width: 0.5, color: colors.onSurface),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: widths,
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? colors.primaryContainer : null,
                  ),
                  children: [
                    TextWidget(
                      text: '${index + 1}',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      padding: const EdgeInsets.all(4),
                      style: textTheme.bodyMedium,
                    ),
                    InkWell(
                      child: TextWidget(
                        text: catalog.catalogName,
                        padding: const EdgeInsets.all(4),
                        style: textTheme.bodySmall,
                      ),
                      onLongPress: () => _onDeleteSubcategory(rowContext, catalog),
                    ),
                    ...state.properties.map(
                      (property) =>
                          buildPropertyData(context, property, catalog, state),
                    ),
                    InkWell(
                      child: Tooltip(
                        message: 'تعريف اصناف ${catalog.catalogName}',
                        child: Icon(
                          Icons.generating_tokens,
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                      onTap: () => _onDefineCategoriesPressed(catalog, context),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }
    );
  }

  void _onDeleteSubcategory(
    BuildContext context,
    SubcategoryEntity catalog,
  ) async {
    final sure = await makeSure(
      title: 'حذف نوع صنف ${widget.mainCategory.name}',
      content: 'هل تريد حذف النوع ${catalog.catalogName}',
      context: context,
    );

    if (sure && context.mounted) {
      context.read<SubcategoriesBloc>().add(DeleteSubcategoryEvent(catalog.id));
    }
  }

  Widget buildPropertyData(
    BuildContext context,
    CategoryPropertyEntity property,
    SubcategoryEntity catalog,
    SubcategoriesLoadSuccess state,
  ) {
    final textTheme = TextTheme.of(context);

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
    if (propertyInfos.isEmpty) {
      return InkWell(
        child: const Icon(Icons.add),
        onTap: () => _onAddPropertyInfo(context, catalog, property),
      );
    }

    if (property.isSingle) {
      return TextWidget(
        text: property.isCategoryUnit
            ? property.unitType.fullUnitName
            : propertyInfos.first.unitName ?? '',
        textAlign: TextAlign.center,
        padding: const EdgeInsets.all(4),
        style: textTheme.titleSmall,
      );
    }

    final values = propertyInfos.reversed
        .map((info) => info.unitName ?? '')
        .toSet()
        .map((value) => '($value)')
        .join('   ');
    return Container(
      height: 35.0,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Tooltip(
            textAlign: TextAlign.center,
            margin: const EdgeInsets.only(top: 20),
            message:
                'انواع ${property.propertyName} ${catalog.catalogName}\n$values',
            child: IconButton(
              icon: const Icon(Icons.info, size: 20),
              onPressed: () => successMessage(
                context: context,
                title: '${property.propertyName} (${catalog.catalogName})',
                toast: values,
              ),
            ),
          ),
          TextWidget(
            text: '${propertyInfos.length} ${property.propertyName}',
            textAlign: TextAlign.center,
            padding: const EdgeInsets.all(4),
            style: textTheme.bodyMedium,
            expanded: true,
            overflow: TextOverflow.ellipsis,
          ),
          InkWell(
            child: Tooltip(
              message: 'اضافة ${property.propertyName} جديد',
              child: Icon(Icons.add, size: isDesktop ? 20 : 16.00),
            ),
            onTap: () => _onAddPropertyInfo(context, catalog, property),
          ),
        ],
      ),
    );
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
      title: 'تعريف الاًصناف',
      content:
          'هل تريد انشاء الاصناف الخاصة بال${widget.mainCategory.name} ${subcategory.catalogName}',
      context: context,
    );
    if (sure && context.mounted) {
      bloc.add(
        GenerateSubcategoryCategoriesEvent(subcategory.id),
      );
    }
  }
}
