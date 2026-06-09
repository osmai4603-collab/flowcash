import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
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
  final SubcategoryEntity? subcategory;
  const SubcategoryFormPage({super.key, this.subcategory});

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
      ..add(InitSubcategoryFormEvent(catalog: widget.subcategory));
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
    final isReadOnlyMainCategory = widget.subcategory != null;
    return fluent.ContentDialog(
      constraints: const BoxConstraints(maxWidth: 500),
      content: SingleChildScrollView(
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
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop(state.savedSubcategory);
                  }
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
                  spacing: Spacings.small,
                  children: [
                    Row(
                      children: [
                        fluent.Tooltip(
                          message: 'رجوع',
                          child: fluent.IconButton(
                            icon: fluent.Icon(fluent.FluentIcons.back_to_window),
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
                    Row(
                      spacing: Spacings.small,
                      children: [
                        Expanded(
                          child: fluent.InfoLabel(
                            label: 'الصنف الرئيسي',
                            child: fluent.ComboboxFormField<MainCategoryEntity>(
                              value: state.mainCategory,
                              items: state.mainCategories
                                  .map(
                                    (category) => fluent.ComboBoxItem(
                                      value: category,
                                      child: fluent.Text(category.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isReadOnlyMainCategory
                                  ? null
                                  : (selected) {
                                      if (selected != null) {
                                        context.read<SubcategoryFormBloc>().add(
                                          MainCategorySelectedEvent(selected),
                                        );
                                      }
                                    },
                              placeholder: const fluent.Text(
                                'اختر الصنف الرئيسي',
                              ),
                              isExpanded: true,
                              validator: (value) {
                                if (value == null) {
                                  return 'يرجى تحديد الصنف الرئيسي';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          child: fluent.InfoLabel(
                            label: 'اسم النوع',
                            child: fluent.TextFormBox(
                              controller: catalogNameController,
                              placeholder: 'ادخل اسم النوع',
                              prefix: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: const fluent.Icon(
                                  fluent.FluentIcons.category_classification,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال اسم النوع';
                                }
                                return null;
                              },
                              onChanged: (value) => _catalogFormBloc.add(
                                SubcategoryNameChangedEvent(value),
                              ),
                              style: textTheme.labelMedium,
                              autofocus: true,
                            ),
                          ),
                        ),
                      ],
                    ),
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
    );
  }

  Widget buildSingleProperty(SubcategoryProperty property) {
    final colors = AppStyle.of(context);
    final initialValue = property.selectedUnits.isNotEmpty
        ? property.selectedUnits[0]?.unit
        : null;

    return Row(
      spacing: Spacings.medium,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: fluent.InfoLabel(
            label: property.property.propertyName,
            child: FormField<UnitEntity?>(
              
              key: ValueKey(
                '${property.property.id}_${property.selectedUnits.hashCode}',
              ),
              initialValue: initialValue,
              validator: (value) {
                if (value == null) {
                  return 'يرجى تحديد ${property.property.propertyName}';
                }
                return null;
              },
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MenuBar(
                            children: [
                              SubmenuButton(
                                menuChildren: property.subcatgoriesUnits
                                    .map(
                                      (catalogUnit) => MenuItemButton(
                                        onPressed: () {
                                          final selected = catalogUnit.unit;
                                          field.didChange(selected);
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
                                        child: Text(
                                          catalogUnit.unitName(),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                child: Text(
                                  field.value?.getCategoryName() ??
                                      'حدد نوع ${property.property.propertyName}',
                                  style: colors.bodyStrong,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, right: 8),
                        child: Text(
                          field.errorText ?? '',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        if (!property.property.unitType.isPiece)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: fluent.Tooltip(
              message: 'إضافة ${property.property.propertyName} جديد',
              child: fluent.IconButton(
                icon: fluent.Icon(
                  fluent.FluentIcons.add,
                  color: colors.onSurface,
                ),
                onPressed: () => _onAddNewSubcategoryUnit(property),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildPropertyStruct(SubcategoryProperty property) {
    final colors = AppStyle.of(context);
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
        final selectedList = property.selectedUnits.isEmpty
            ? [null]
            : property.selectedUnits;
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
                          child: Stack(
                            children: [
                              FormField<UnitEntity?>(
                                key: ValueKey(
                                  '${property.property.id}_${subcategoryUnit?.id ?? 0}_${selectedList.hashCode}',
                                ),
                                initialValue: subcategoryUnit?.unit,
                                builder: (field) {
                                  return MenuBar(
                                    children: [
                                      SubmenuButton(
                                        child: Text(
                                          field.value?.unitName ?? 'اختر',
                                        ),
                                        menuChildren: property.subcatgoriesUnits
                                            .map(
                                              (u) => MenuItemButton(
                                                onPressed: () {
                                                  final idx = selectedList.indexOf(
                                                    subcategoryUnit,
                                                  );
                                                  final updated =
                                                      List<SubcategoryUnit?>.from(
                                                    selectedList,
                                                  );
                                                  final updatedInfo = SubcategoryUnit(
                                                    id: subcategoryUnit?.id ?? 0,
                                                    property: property.property,
                                                    unit: u.unit,
                                                  );
                                                  if (idx != -1) {
                                                    updated[idx] = updatedInfo;
                                                    formState.didChange(updated);
                                                  }
                                                  field.didChange(u.unit);
                                                  _catalogFormBloc.add(
                                                    UpdateSelectedUnitEvent(
                                                      property: property,
                                                      index: idx,
                                                      unit: updatedInfo,
                                                    ),
                                                  );
                                                },
                                                child: Text(u.unitName()),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              PositionedDirectional(
                                top: 0,
                                end: 0,
                                child: fluent.Tooltip(
                                  message: 'ازالة',
                                  child: fluent.IconButton(
                                    icon: fluent.Icon(
                                      fluent.FluentIcons.remove_link,
                                      color: Colors.red.shade400,
                                      size: 16,
                                    ),
                                    onPressed: subcategoryUnit == null
                                        ? null
                                        : () {
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
      mainCategoryId: state.mainCategory?.id ?? 0,
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
