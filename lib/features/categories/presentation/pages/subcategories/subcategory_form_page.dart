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

  late final SubcategoryFormBloc _catalogFormBloc;

  bool _initialized = false;
  bool _isDataChanged = false;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    _catalogFormBloc = sl<SubcategoryFormBloc>()
      ..add(InitSubcategoryFormEvent(catalog: widget.subcategory));
  }

  void _markChanged() {
    if (!_isDataChanged) {
      setState(() => _isDataChanged = true);
    }
  }

  void _onBackPressed() async {
    if (!_isDataChanged) {
      if (context.mounted) Navigator.pop(context);
      return;
    }
    final sure = await makeSure(
      context: context,
      title: 'تأكيد الخروج',
      content: 'هل تريد الخروج؟ سيتم فقدان البيانات غير المحفوظة',
    );
    if (sure && mounted) {
      setState(() => _isDataChanged = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    catalogNameController.dispose();
    super.dispose();
    _catalogFormBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    final textTheme = TextTheme.of(context);
    final isReadOnlyMainCategory = widget.subcategory != null;
    return BlocProvider.value(
      value: _catalogFormBloc,
      child: BlocConsumer<SubcategoryFormBloc, SubcategoryFormState>(
        listener: (context, state) async {
          if (state.status == SubcategoryFormStatus.ready) {
            if (!_initialized && state.catalogName != null) {
              catalogNameController.text = state.catalogName!;
              _initialized = true;
            }
          }
          if (state.status == SubcategoryFormStatus.saved) {
            if (context.mounted) {
              Navigator.of(context).pop(state.savedSubcategory);
            }
          }

          if (state.status == SubcategoryFormStatus.failure) {
            await errorToast(
              context: context,
              toast: state.messageError ?? 'حدث خطأ',
            );
          }
        },
        builder: (context, state) {
          if (state.status == SubcategoryFormStatus.initial) {
            return Center(child: fluent.ProgressRing());
          }
          final isEditing =
              widget.subcategory?.id != null && widget.subcategory?.id != 0;
          return PopScope(
            canPop: !_isDataChanged,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              _onBackPressed();
            },
            child: fluent.ContentDialog(
              constraints: const BoxConstraints(maxWidth: 500),
              title: Row(
                children: [
                  fluent.Icon(
                    isEditing
                        ? fluent.FluentIcons.edit_note
                        : fluent.FluentIcons.add_work,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 10),
                  fluent.Text(
                    isEditing ? 'تعديل صنف فرعي' : 'إضافة صنف فرعي جديد',
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    spacing: Spacings.small,
                    children: [
                      Row(
                        spacing: Spacings.small,
                        children: [
                          Expanded(
                            child: fluent.InfoLabel(
                              label: 'اسم النوع',
                              child: fluent.TextFormBox(
                                controller: catalogNameController,
                                placeholder: 'ادخل اسم النوع',
                                enabled:
                                    state.status !=
                                    SubcategoryFormStatus.saving,
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
                                onChanged: (value) {
                                  _markChanged();
                                  _catalogFormBloc.add(
                                    SubcategoryNameChangedEvent(value),
                                  );
                                },
                                style: textTheme.labelMedium,
                                autofocus: true,
                              ),
                            ),
                          ),
                          Expanded(
                            child: fluent.InfoLabel(
                              label: 'الصنف الرئيسي',
                              child: fluent.ComboboxFormField<MainCategoryEntity>(
                                value: state.mainCategory,
                                // enabled:
                                //     state.status != SubcategoryFormStatus.saving,
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
                                          _markChanged();
                                          context
                                              .read<SubcategoryFormBloc>()
                                              .add(
                                                MainCategorySelectedEvent(
                                                  selected,
                                                ),
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
                        ],
                      ),
                      if (state.catalogProperties.isNotEmpty)
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ...state.catalogProperties
                                .where(
                                  (catalogProperty) => catalogProperty.isSingle,
                                )
                                .map((catalogProperty) {
                                  return buildSingleProperty(catalogProperty);
                                }),
                            ...state.catalogProperties
                                .where(
                                  (catalogProperty) =>
                                      !catalogProperty.isSingle,
                                )
                                .map((catalogProperty) {
                                  return buildPropertyStruct(catalogProperty);
                                }),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                fluent.Button(
                  onPressed: _onBackPressed,
                  child: const fluent.Text('إلغاء'),
                ),
                fluent.FilledButton(
                  onPressed: state.status == SubcategoryFormStatus.saving
                      ? null
                      : _onSaveButtonClicked,
                  child: state.status == SubcategoryFormStatus.saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: fluent.ProgressRing(
                            strokeWidth: 2,
                            activeColor: Colors.white,
                          ),
                        )
                      : const fluent.Text('حفظ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildSingleProperty(SubcategoryProperty property) {
    final colors = AppStyle.of(context);
    final initialValue = property.selectedUnits.isNotEmpty
        ? property.selectedUnits[0].unit
        : null;

    return Row(
      spacing: Spacings.medium,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: fluent.InfoLabel(
            label: 'ال${property.property.propertyName}',
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
                      crossAxisAlignment: .end,
                      children: [
                        Expanded(
                          child: MenuAnchor(
                            builder: (context, controller, child) {
                              return fluent.Button(
                                onPressed: () {
                                  if (controller.isOpen) {
                                    controller.close();
                                  } else {
                                    controller.open();
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        field.value?.unitName ??
                                            'حدد نوع ${property.property.propertyName}',
                                        style: colors.bodyStrong,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_drop_down, size: 20),
                                  ],
                                ),
                              );
                            },
                            menuChildren: property.subcatgoriesUnits
                                .map(
                                  (catalogUnit) => MenuItemButton(
                                    onPressed: () {
                                      final selected = catalogUnit.unit;
                                      field.didChange(selected);
                                      _markChanged();
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
                                    child: Text(catalogUnit.unitName()),
                                  ),
                                )
                                .toList(),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 3.0),
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
        final selectedList = List.of(property.selectedUnits);
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
                              _markChanged();
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
                            },
                          ),
                        ),
                        Expanded(
                          child: TextWidget(
                            text: 'انواع ال${property.property.propertyName}',
                            alignment: Alignment.center,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (property.selectedUnits.isNotEmpty)
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        textDirection: TextDirection.rtl,
                        alignment: WrapAlignment.center,
                        children: List.generate(property.selectedUnits.length, (
                          indexOfUnit,
                        ) {
                          final subcategoryUnit =
                              property.selectedUnits[indexOfUnit];
                          return SizedBox(
                            width: 120,
                            child: Stack(
                              children: [
                                FormField<UnitEntity?>(
                                  key: ValueKey(
                                    '${property.property.id}_${subcategoryUnit.id}_${selectedList.hashCode}',
                                  ),
                                  initialValue: subcategoryUnit.unit,
                                  builder: (field) {
                                    return MenuAnchor(
                                      builder: (context, controller, child) {
                                        return fluent.Button(
                                          onPressed: () {
                                            if (controller.isOpen) {
                                              controller.close();
                                            } else {
                                              controller.open();
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  field.value
                                                          ?.unitName ??
                                                      'اختر',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_drop_down,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      menuChildren: List.generate(
                                        property.availableUnits.length,
                                        (idx) {
                                          final unit =
                                              property.availableUnits[idx];
                                          return MenuItemButton(
                                            onPressed: () {
                                              _markChanged();
                                              _catalogFormBloc.add(
                                                UpdateSelectedUnitEvent(
                                                  property: property,
                                                  index: indexOfUnit,
                                                  unit: unit,
                                                ),
                                              );
                                            },
                                            child: Text(unit.unitName()),
                                          );
                                        },
                                      ),
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
                                        _markChanged();
                                        _catalogFormBloc.add(
                                          UpdateSelectedUnitEvent(
                                            property: property,
                                            index: indexOfUnit,
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
                        }),
                      ),
                    const SizedBox(height: 20),
                    fluent.FilledButton(
                      child: fluent.Text(
                        'تحديد ${property.property.propertyName} جديد',
                      ),
                      onPressed: () async {
                        if (property.availableUnits.isEmpty) {
                          final unitEntity = await showDialog<UnitEntity>(
                            barrierDismissible: false,
                            context: context,
                            builder: (_) =>
                                UnitFormPage(property: property.property),
                          );
                          if (!mounted) return;
                          if (unitEntity == null) return;
                          _markChanged();
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
                          return;
                        }

                        _markChanged();
                        _catalogFormBloc.add(AddSelectedSlotEvent(property));
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
    if (state.status != SubcategoryFormStatus.ready) {
      _catalogFormBloc.add(
        SubcategoryNameChangedEvent(catalogNameController.text),
      );
    }

    final catalog = SubcategoryEntity(
      id: widget.subcategory?.id ?? 0,
      mainCategoryId: state.mainCategory?.id ?? 0,
      catalogName: catalogNameController.text,
    );

    final unitsPerProperty = <int, List<int>>{};
    for (final catalogProperty in state.catalogProperties) {
      final selectedList = catalogProperty.selectedUnits
          .map((u) => u.unit.id)
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
      _markChanged();
      _catalogFormBloc.add(
        AddUnitToPropertyEvent(
          catalogProperty: property,
          catalogUnit: property.createSubcategoryUnit(unit: unitEntity),
        ),
      );
    }
  }
}
