import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategory_form/catalog_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategory_form/catalog_form_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategory_form/catalog_form_state.dart';
import 'package:flowcash/features/categories/presentation/pages/units/unit_form_page.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SubcategoryFormPage extends StatefulWidget {
  final int mainCategoryId;
  final SubcategoryEntity? subcategory;
  const SubcategoryFormPage({
    super.key,
    required this.mainCategoryId,
    this.subcategory,
  });

  @override
  State<SubcategoryFormPage> createState() => _SubcategoryFormPageState();
}

class _SubcategoryFormPageState extends State<SubcategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final catalogNameController = TextEditingController();
  bool _initialized = false;

  late final SubcategoryFormBloc _catalogFormBloc;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    _catalogFormBloc = sl<SubcategoryFormBloc>()
      ..add(
        InitSubcategoryFormEvent(
          widget.mainCategoryId,
          catalog: widget.subcategory,
        ),
      );
  }

  @override
  void dispose() {
    catalogNameController.dispose();
    super.dispose();
    _catalogFormBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = TextTheme.of(context);
    return fluent.ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      content: Padding(
        padding: Paddings.mediumAll,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: BlocProvider.value(
              value: _catalogFormBloc,
              child: BlocConsumer<SubcategoryFormBloc, SubcategoryFormState>(
                listener: (context, state) async {
                  if (state.status == SubcategoryFormStatus.ready &&
                      !_initialized) {
                    _initialized = true;
                    catalogNameController.text = state.catalogName ?? '';
                  }

                  if (state.status == SubcategoryFormStatus.saved) {
                    await successToast(
                      context: context,
                      toast: 'تم حفظ البيانات بنجاح',
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context, state.savedSubcategory);
                  }

                  if (state.status == SubcategoryFormStatus.failure) {
                    await errorToast(
                      context: context,
                      toast: state.messageError ?? 'حدث خطأ',
                    );
                    if (!context.mounted) return;
                  }
                },
                builder: (context, state) {
                  if (state.status == SubcategoryFormStatus.initial ||
                      state.status == SubcategoryFormStatus.saving) {
                    return const SubcategoryFormShimmer();
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          fluent.Tooltip(
                            message: 'رجوع',
                            child: fluent.IconButton(
                              icon: fluent.Icon(fluent.FluentIcons.back),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          TextWidget(
                            text:
                                'بيانات نوع ${state.mainCategory?.name ?? ''}',
                            padding: EdgeInsets.only(right: 10),
                            expanded: true,
                            textAlign: TextAlign.center,
                          ),
                          fluent.Tooltip(
                            message: 'حفظ البيانات',
                            child: fluent.IconButton(
                              icon: const fluent.Icon(fluent.FluentIcons.save),
                              onPressed: _onSaveButtonClicked,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        textInputAction: TextInputAction.next,
                        controller: catalogNameController,
                        onChanged: (value) => _catalogFormBloc.add(
                          SubcategoryNameChangedEvent(value),
                        ),
                        style: textTheme.labelMedium,
                        autofocus: true,
                        cursorHeight: 20.0,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال اسم النوع';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 12.0,
                          ),
                          hintText: 'ادخل اسم النوع',
                          label: fluent.Text('اسم النوع'),
                          prefixIcon: fluent.Icon(
                            fluent.FluentIcons.category_classification,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (state.catalogProperties.isNotEmpty)
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ...state.catalogProperties.map((catalogProperty) {
                              if (catalogProperty.property.isSingle) {
                                return buildSingleProperty(catalogProperty);
                              }
                              return buildPropertyStruct(catalogProperty);
                            }),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSingleProperty(SubcategoryProperty property) {
    final colors = ColorScheme.of(context);
    final initialValue = property.selectedUnits.isNotEmpty
        ? property.selectedUnits[0]?.unit
        : null;

    final textTheme = TextTheme.of(context);
    return Row(
      spacing: Spacings.medium,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<UnitEntity>(
            key: ValueKey(
              '${property.property.id}_${property.selectedUnits.hashCode}',
            ),
            initialValue: initialValue,
            isExpanded: true,
            style: textTheme.labelMedium,
            decoration: InputDecoration(
              labelText: property.property.propertyName,
              hintText: 'حدد نوع ${property.property.propertyName}',
              prefixIcon: const fluent.Icon(
                fluent.FluentIcons.category_classification,
              ),
            ),
            items: property.subcatgoriesUnits.map((catalogUnit) {
              return DropdownMenuItem<UnitEntity>(
                value: catalogUnit.unit,
                child: fluent.Text(catalogUnit.unitName()),
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'يرجى تحديد ${property.property.propertyName}';
              }
              return null;
            },
            onChanged: (selected) {
              if (selected == null) return;
              _catalogFormBloc.add(
                UpdateSelectedUnitEvent(
                  property: property,
                  index: 0,
                  unit: SubcategoryUnit(
                    property: property.property,
                    unit: selected,
                  ),
                ),
              );
            },
          ),
        ),
        if (!property.property.unitType.isPiece)
          fluent.Tooltip(
            message: 'إضافة ${property.property.propertyName} جديد',
            child: fluent.IconButton(
              style: fluent.ButtonStyle(
                backgroundColor: fluent.WidgetStatePropertyAll(
                  colors.surfaceContainerLow,
                ),
                shape: fluent.WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: Radiuses.xsmallAll,
                    side: BorderSide(
                      color: colors.outline.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              icon: fluent.Icon(
                fluent.FluentIcons.add,
                color: colors.onSurface,
              ),
              onPressed: () => _onAddNewSubcategoryUnit(property),
            ),
          ),
      ],
    );
  }

  Widget buildPropertyStruct(SubcategoryProperty property) {
    final colors = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    return FormField<List<SubcategoryUnit?>>(
      key: ValueKey(
        '${property.property.id}_${property.selectedUnits.hashCode}',
      ),
      initialValue: property.selectedUnits,
      validator: (value) {
        final nonNullList = value?.where((e) => e != null).toList() ?? [];
        if (nonNullList.isEmpty) {
          return 'يرجى تحديد ${property.property.propertyName} واحد على الأقل';
        }
        return null;
      },
      builder: (formState) {
        final selectedList = property.selectedUnits;
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: formState.hasError
                        ? colors.error
                        : colors.outline.withValues(alpha: 0.5),
                    width: formState.hasError ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: Paddings.mediumAll,
                child: Column(
                  children: [
                    Row(
                      children: [
                        fluent.Tooltip(
                          message:
                              'اضافة ${property.property.propertyName} جديد',
                          child: fluent.IconButton(
                            icon: fluent.Icon(
                              fluent.FluentIcons.add,
                              color: colors.onSurface,
                            ),
                            onPressed: () async {
                              final unitEntity = await showDialog<UnitEntity>(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) =>
                                    UnitFormPage(property: property.property),
                              );
                              if (!mounted) return;
                              if (unitEntity == null) return;
                              final newSubcategoryUnit = SubcategoryUnit(
                                property: property.property,
                                unit: unitEntity,
                              );
                              _catalogFormBloc.add(
                                AddUnitToPropertyEvent(
                                  catalogProperty: property,
                                  catalogUnit: newSubcategoryUnit,
                                ),
                              );
                              formState.didChange([
                                ...selectedList,
                                newSubcategoryUnit,
                              ]);
                            },
                          ),
                        ),
                        TextWidget(
                          text: 'انواع ${property.property.propertyName}',
                          alignment: Alignment.center,
                          expanded: true,
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      textDirection: TextDirection.rtl,
                      alignment: WrapAlignment.center,
                      children: selectedList.map((subcategoryUnit) {
                        return SizedBox(
                          width: 120,
                          child: PopupMenuButton<UnitEntity>(
                            tooltip: subcategoryUnit?.unit.unitName,
                            itemBuilder: (context) => property.subcatgoriesUnits
                                .map(
                                  (u) => PopupMenuItem<UnitEntity>(
                                    padding: const EdgeInsets.all(1),
                                    value: u.unit,
                                    height: 40,
                                    child: TextWidget(
                                      text: u.unitName(),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.all(5),
                                    ),
                                  ),
                                )
                                .toList(),
                            onSelected: (selected) {
                              final idx = selectedList.indexOf(subcategoryUnit);
                              final updated = List<SubcategoryUnit?>.from(
                                selectedList,
                              );
                              final updatedInfo = SubcategoryUnit(
                                id: subcategoryUnit?.id ?? 0,
                                property: property.property,
                                unit: selected,
                              );
                              if (idx != -1) {
                                updated[idx] = updatedInfo;
                                formState.didChange(updated);
                              }
                              _catalogFormBloc.add(
                                UpdateSelectedUnitEvent(
                                  property: property,
                                  index: idx,
                                  unit: updatedInfo,
                                ),
                              );
                            },
                            initialValue: subcategoryUnit?.unit,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                TextWidget(
                                  style: textTheme.bodyMedium,
                                  text: subcategoryUnit?.unit.unitName ?? '',
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(5),
                                  backColor: colors.surfaceContainerLow,
                                ),
                                PositionedDirectional(
                                  top: isDesktop ? -10 : -15,
                                  end: isDesktop ? -10 : -15,
                                  child: fluent.Tooltip(
                                    message: 'ازالة',
                                    child: fluent.IconButton(
                                      icon: fluent.Icon(
                                        fluent.FluentIcons.remove_link,
                                        color: Colors.red.shade400,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        final idx = selectedList.indexOf(
                                          subcategoryUnit,
                                        );
                                        final updated =
                                            List<SubcategoryUnit?>.from(
                                              selectedList,
                                            );
                                        if (idx != -1) {
                                          updated.removeAt(idx);
                                          formState.didChange(updated);
                                        }
                                        _catalogFormBloc.add(
                                          UpdateSelectedUnitEvent(
                                            property: property,
                                            index: idx,
                                            unit: null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    fluent.FilledButton(
                      child: fluent.Text(
                        'تحديد ${property.property.propertyName} جديد',
                      ),
                      onPressed: () async {
                        final selectedUnitIds = selectedList
                            .whereType<SubcategoryUnit>()
                            .map((u) => u.unit.id)
                            .toSet();
                        final availableUnits = property.subcatgoriesUnits
                            .where((u) => !selectedUnitIds.contains(u.unit.id))
                            .toList();

                        if (availableUnits.isEmpty) {
                          final unitEntity = await showDialog<UnitEntity>(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) =>
                                UnitFormPage(property: property.property),
                          );
                          if (!mounted) return;
                          if (unitEntity == null) return;
                          final newSubcategoryUnit = SubcategoryUnit(
                            property: property.property,
                            unit: unitEntity,
                          );
                          _catalogFormBloc.add(
                            AddUnitToPropertyEvent(
                              catalogProperty: property,
                              catalogUnit: newSubcategoryUnit,
                            ),
                          );
                          formState.didChange([
                            ...selectedList,
                            newSubcategoryUnit,
                          ]);
                          return;
                        }

                        _catalogFormBloc.add(AddSelectedSlotEvent(property));
                        formState.didChange([
                          ...selectedList,
                          availableUnits.first,
                        ]);
                      },
                    ),
                  ],
                ),
              ),
              if (formState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 5, right: 12),
                  child: fluent.Text(
                    formState.errorText!,
                    style: TextStyle(color: colors.error, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Selection handled via bloc events.

  void _onSaveButtonClicked() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final state = _catalogFormBloc.state;
    if (state.status != SubcategoryFormStatus.ready) return;

    final catalog = SubcategoryEntity(
      id: widget.subcategory?.id ?? 0,
      mainCategoryId: widget.mainCategoryId,
      catalogName: catalogNameController.text,
    );

    final unitsPerProperty = <int, List<int>>{};
    for (final catalogProperty in state.catalogProperties) {
      final selectedList = catalogProperty.selectedUnits
          .where((u) => u != null)
          .map((u) => u!.unit.id)
          .toList();
      if (selectedList.isNotEmpty) {
        unitsPerProperty[catalogProperty.propertyId] = selectedList;
      }
    }

    _catalogFormBloc.add(
      SaveSubcategoryEvent(
        catalog: catalog,
        unitsPerProperty: unitsPerProperty,
      ),
    );
  }

  void _onAddNewSubcategoryUnit(SubcategoryProperty property) async {
    final unitEntity = await showDialog<UnitEntity>(
      barrierDismissible: false,
      context: context,
      builder: (_) => UnitFormPage(property: property.property),
    );
    if (!mounted) return;
    if (unitEntity != null) {
      _catalogFormBloc.add(
        AddUnitToPropertyEvent(
          catalogProperty: property,
          catalogUnit: property.createSubcategoryUnit(unit: unitEntity),
        ),
      );
    }
  }
}

class SubcategoryFormShimmer extends StatelessWidget {
  const SubcategoryFormShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        spacing: Spacings.medium,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: Spacings.medium,
            children: [
              const ShimmerPlaceholder(height: 35, width: 50),
              const ShimmerPlaceholder(height: 40, width: 250),
              const ShimmerPlaceholder(height: 35, width: 50),
            ],
          ),
          const ShimmerPlaceholder(height: 2),
          const ShimmerPlaceholder(),
          const ShimmerPlaceholder(),
          const ShimmerPlaceholder(height: 100),
        ],
      ),
    );
  }
}
