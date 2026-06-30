import 'dart:io';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/category_form/category_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/category_form/category_form_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/category_form/category_form_state.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class CategoryFormPage extends StatelessWidget {
  final CategoryEntity? category;
  const CategoryFormPage({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryFormBloc(
        addCategory: sl(),
        updateCategory: sl(),
        getUnitsUseCase: sl(),
        getSubcategories: sl(),
        checkHasRequestsUseCase: sl(),
        getNewCategoryNumberUseCase: sl(),
        getUnitsBySubcategoryIdsUseCase: sl(),
        getCategoryProperties: sl(),
      )..add(InitCategoryForm(category)),
      child: _CategoryForm(),
    );
  }
}

class _CategoryForm extends StatefulWidget {
  const _CategoryForm();

  @override
  State<_CategoryForm> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<_CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;
  bool _isDataChanged = false;
  late final TextEditingController categoryNameController;
  late final TextEditingController categoryNumberController;
  late final TextEditingController barcodeController;

  final barcodeFocusNode = FocusNode();

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    categoryNameController = TextEditingController();
    categoryNumberController = TextEditingController();
    barcodeController = TextEditingController();
  }

  void _markChanged() {
    if (_initialized && !_isDataChanged) {
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
    if (sure && context.mounted) {
      setState(() => _isDataChanged = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    barcodeFocusNode.dispose();
    categoryNameController.dispose();
    categoryNumberController.dispose();
    barcodeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    return BlocListener<CategoryFormBloc, CategoryFormState>(
      listener: (context, state) async {
        if (state.status == CategoryFormStatus.ready) {
          if (!_initialized) {
            categoryNameController.text = state.categoryName;
            categoryNumberController.text = state.categoryNumber;
            barcodeController.text = state.barcode ?? '';

            _initialized = true;
          } else {
            if (categoryNumberController.text != state.categoryNumber) {
              categoryNumberController.text = state.categoryNumber;
            }
            if (barcodeController.text != (state.barcode ?? '')) {
              barcodeController.text = state.barcode ?? '';
            }
          }
        }
        if (state.status == CategoryFormStatus.saved) {
          final savedCategory = state.toEntity();
          debugPrint(state.status.name);
          if (context.mounted) {
            Navigator.pop(context, savedCategory);
          }
        }
        if (state.status == CategoryFormStatus.failure) {
          // ignore: use_build_context_synchronously
          await errorToast(
            toast: state.messageError ?? 'حدث خطأ',
            context: context,
          );
        }
      },
      child: PopScope(
        canPop: !_isDataChanged,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _onBackPressed();
        },
        child: BlocBuilder<CategoryFormBloc, CategoryFormState>(
          builder: (context, state) {
            final bloc = context.read<CategoryFormBloc>();
            final isEditing = state.id != 0;
            return fluent.ContentDialog(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 450.0 : double.infinity,
              ),
              title: Row(
                children: [
                  fluent.Icon(
                    isEditing
                        ? fluent.FluentIcons.edit_note
                        : fluent.FluentIcons.add_work,
                    color: ColorScheme.of(context).primary,
                  ),
                  const SizedBox(width: 10),
                  fluent.Text(
                    isEditing ? 'تعديل بيانات الصنف' : 'إضافة صنف جديد',
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    spacing: Spacings.small,
                    children: [
                      fluent.InfoLabel(
                        label: 'اسم الصنف',
                        child: fluent.TextFormBox(
                          textInputAction: TextInputAction.next,
                          controller: categoryNameController,
                          autofocus: state.id == 0,
                          enabled: state.status != CategoryFormStatus.saving,
                          cursorHeight: 20.0,
                          onChanged: _onCategoryNameChanged,
                          validator: categoryNameValidator,
                          placeholder: 'ادخل اسم الصنف',
                          prefix: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: fluent.Icon(
                              fluent.FluentIcons.category_classification,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        spacing: Spacings.medium,
                        crossAxisAlignment: .start,
                        children: [
                          Expanded(
                            child: fluent.InfoLabel(
                              label: 'رقم الصنف',
                              child: fluent.TextFormBox(
                                placeholder: 'رقم الصنف',
                                readOnly: true,
                                enabled:
                                    state.status != CategoryFormStatus.saving,
                                textInputAction: TextInputAction.next,
                                controller: categoryNumberController,

                                textDirection: TextDirection.ltr,
                                validator: categoryNumberValidator,
                                suffix: fluent.GestureDetector(
                                  onTap:
                                      state.status == CategoryFormStatus.saving
                                      ? null
                                      : _generateCategoryNumber,
                                  child: fluent.Tooltip(
                                    message: 'تحديث رقم الصنف',
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: fluent.Icon(
                                        fluent.FluentIcons.refresh,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: fluent.InfoLabel(
                              label: 'الباركود',
                              child: fluent.TextFormBox(
                                placeholder: 'ادخل رمز الباركود',
                                enabled:
                                    state.status != CategoryFormStatus.saving,
                                prefix: fluent.Tooltip(
                                  message: 'قراء ماسح الباركود',
                                  child: fluent.IconButton(
                                    icon: fluent.Icon(
                                      fluent.FluentIcons.q_r_code,
                                    ),
                                    onPressed:
                                        state.status ==
                                            CategoryFormStatus.saving
                                        ? null
                                        : _scanBarcode,
                                  ),
                                ),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                textDirection: TextDirection.ltr,
                                controller: barcodeController,
                                focusNode: barcodeFocusNode,
                                cursorHeight: 20.0,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: onBarcodeChanged,
                                validator: barcodeValidator,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!state.hasRequests)
                        Row(
                          crossAxisAlignment: .start,
                          spacing: Spacings.medium,
                          children: [
                            Expanded(
                              child: fluent.InfoLabel(
                                label: 'الوحدة',
                                child: fluent.ComboBox<UnitEntity>(
                                  value: state.selectedUnit,
                                  disabledPlaceholder: fluent.Text(
                                    'لا يوجد وحدات معرفة',
                                  ),
                                  placeholder: fluent.Text('حدد وحدة الصنف'),
                                  isExpanded: true,
                                  items: bloc.units.map((unit) {
                                    return fluent.ComboBoxItem<UnitEntity>(
                                      value: unit,
                                      child: fluent.Text(
                                        unit.unitName,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged:
                                      state.status == CategoryFormStatus.saving
                                      ? null
                                      : _onSelectedCategoryUnit,
                                  selectedItemBuilder: (context) =>
                                      bloc.units.map((unit) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            spacing: Spacings.medium,
                                            crossAxisAlignment: .center,
                                            mainAxisAlignment: .start,
                                            children: [
                                              fluent.Icon(
                                                fluent.FluentIcons.unite_shape,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              fluent.Text(
                                                unit.unitName,
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: fluent.InfoLabel(
                                label: 'النوع',
                                child: fluent.ComboBox<CategoryDefineType>(
                                  value: state.selectedCategoryType,
                                  isExpanded: true,
                                  items: CategoryDefineType.values.map((
                                    categoryType,
                                  ) {
                                    return fluent.ComboBoxItem<
                                      CategoryDefineType
                                    >(
                                      value: categoryType,
                                      child: fluent.Text(
                                        categoryType.displayName(),
                                      ),
                                    );
                                  }).toList(),
                                  selectedItemBuilder: (context) =>
                                      CategoryDefineType.values.map((unit) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            spacing: Spacings.medium,
                                            crossAxisAlignment: .center,
                                            mainAxisAlignment: .start,
                                            children: [
                                              fluent.Icon(
                                                fluent
                                                    .FluentIcons
                                                    .category_classification,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              fluent.Text(
                                                state.selectedCategoryType
                                                    .displayName(),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                  onChanged:
                                      state.status == CategoryFormStatus.saving
                                      ? null
                                      : (belongGroup) {
                                          if (belongGroup == null) return;
                                          context.read<CategoryFormBloc>().add(
                                            ChangeCategoryTypeEvent(
                                              belongGroup,
                                            ),
                                          );
                                          _markChanged();
                                        },
                                ),
                              ),
                            ),
                          ],
                        ),
                      Row(
                        spacing: Spacings.medium,
                        children: [
                          Expanded(
                            child: fluent.InfoLabel(
                              label: 'الصنف الفرعي',
                              child: fluent.ComboBox<SubcategoryEntity?>(
                                value: state.selectedSubcategory,
                                placeholder: fluent.Text('حدد الصنف الفرعي'),
                                isExpanded: true,
                                icon: fluent.Icon(
                                  fluent.FluentIcons.chevron_down,
                                  color: colors.onSurfaceVariant,
                                ),
                                items: [
                                  fluent.ComboBoxItem<SubcategoryEntity?>(
                                    value: null,
                                    child: fluent.Text('بدون صنف فرعي'),
                                  ),
                                  ...bloc.subcategories.map((subcategory) {
                                    return fluent.ComboBoxItem<
                                      SubcategoryEntity?
                                    >(
                                      value: subcategory,
                                      child: fluent.Text(
                                        subcategory.catalogName,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged:
                                    state.status == CategoryFormStatus.saving
                                    ? null
                                    : (selected) {
                                        context.read<CategoryFormBloc>().add(
                                          ChangeCategorySubcategoryEvent(
                                            selected,
                                          ),
                                        );
                                        _markChanged();
                                      },
                                selectedItemBuilder: (context) =>
                                    [
                                      fluent.Text('بدون صنف فرعي'),
                                      ...bloc.subcategories.map((unit) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            spacing: Spacings.medium,
                                            children: [
                                              fluent.Icon(
                                                fluent.FluentIcons.view_list_tree,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              fluent.Text(
                                                unit.catalogName,
                                              ),

                                            ],
                                          ),
                                        );
                                      })
                                    ]
                              ),
                            ),
                          ),
                        ],
                      ),
                        if(state.selectedSubcategory != null) Row(
                          spacing: Spacings.medium,
                          children: [
                            Expanded(
                              child: fluent.InfoLabel(
                                label: 'وحدة السعر',
                                child: fluent.ComboBox<UnitEntity>(
                                  value: state.selectedPricingUnit,
                                  placeholder: const fluent.Text(
                                    'حدد وحدة السعر',
                                  ),
                                  isExpanded: true,
                                  items: bloc.pricingsUnits.map((unit) {
                                    return fluent.ComboBoxItem<UnitEntity>(
                                      value: unit,
                                      child: Row(
                                        mainAxisAlignment: .spaceBetween,
                                        children: [
                                          fluent.Text(
                                            unit.unitType.unitName,
                                          ),
                                          fluent.Text(
                                              unit.unitName,
                                              style: colors.body.copyWith(
                                                  color: colors.onSurfaceVariant
                                              )
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged:
                                      state.status == CategoryFormStatus.saving
                                      ? null
                                      : (selected) {
                                          if (selected == null) return;
                                          context.read<CategoryFormBloc>().add(
                                            ChangeCategoryPricingUnitEvent(
                                              selected,
                                            ),
                                          );
                                          _markChanged();
                                        },
                                  selectedItemBuilder: (context) =>
                                      bloc.pricingsUnits.map((unit) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            spacing: Spacings.medium,
                                            children: [
                                              fluent.Icon(
                                                fluent.FluentIcons.unite_shape,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment: .spaceBetween,
                                                  children: [
                                                    fluent.Text(
                                                      unit.unitType.unitName,
                                                    ),
                                                    fluent.Text(
                                                      unit.unitName,
                                                      style: colors.body.copyWith(
                                                        color: colors.onSurfaceVariant
                                                      )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: fluent.InfoLabel(
                                label: 'وحدة المخزون',
                                child: fluent.ComboBox<UnitEntity>(
                                  value: state.selectedInventoryUnit,
                                  placeholder: const fluent.Text(
                                    'حدد وحدة المخزون',
                                  ),
                                  isExpanded: true,
                                  items: bloc.inventoriesUnits.map((unit) {
                                    return fluent.ComboBoxItem<UnitEntity>(
                                      value: unit,
                                      child: Row(
                                        mainAxisAlignment: .spaceBetween,
                                        children: [
                                          fluent.Text(
                                            unit.unitType.unitName,
                                          ),
                                          fluent.Text(
                                              unit.unitName,
                                              textAlign: .start,
                                              textDirection: .ltr,
                                              style: colors.body.copyWith(
                                                  color: colors.onSurfaceVariant
                                              )
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged:
                                      state.status == CategoryFormStatus.saving
                                      ? null
                                      : (selected) {
                                          if (selected == null) return;
                                          context.read<CategoryFormBloc>().add(
                                            ChangeCategoryInventoryUnitEvent(
                                              selected,
                                            ),
                                          );
                                          _markChanged();
                                        },
                                  selectedItemBuilder: (context) =>
                                      bloc.inventoriesUnits.map((unit) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Row(
                                            spacing: Spacings.medium,
                                            children: [
                                              fluent.Icon(
                                                fluent.FluentIcons.unite_shape,
                                                color: colors.onSurfaceVariant,
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment: .spaceBetween,
                                                  children: [
                                                    fluent.Text(
                                                      unit.unitType.unitName,
                                                    ),
                                                    fluent.Text(
                                                        unit.unitName,
                                                        style: colors.body.copyWith(
                                                            color: colors.onSurfaceVariant
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                            ),
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
                  onPressed: state.status == CategoryFormStatus.saving
                      ? null
                      : () => _onSaveButtonClicked(context),
                  child: state.status == CategoryFormStatus.saving
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
            );
          },
        ),
      ),
    );
  }

  void onBarcodeChanged(String? value) {
    context.read<CategoryFormBloc>().add(ChangeBarcodeEvent(value));
    _markChanged();
  }

  String? barcodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return null;
  }

  String? categoryNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم الصنف فارغ';
    }
    return null;
  }

  String? categoryNumberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الصنف فارغ';
    }
    return null;
  }

  void _onCategoryNameChanged(String? value) {
    if (value == null) return;
    context.read<CategoryFormBloc>().add(ChangeCategoryNameEvent(value));
    _markChanged();
  }

  void _generateCategoryNumber() {
    context.read<CategoryFormBloc>().add(const GenerateCategoryNumberEvent());
    _markChanged();
  }

  void _onSelectedCategoryUnit(UnitEntity? selected) {
    if (selected == null) return;
    context.read<CategoryFormBloc>().add(ChangeCategoryUnitEvent(selected));
    _markChanged();
  }

  void _scanBarcode() async {
    final context = this.context;
    try {
      // final barcode = await Func.scanBarcode();
      // if (barcode.isNotEmpty && context.mounted) {
      //   context.read<CategoryFormBloc>().add(ChangeBarcodeEvent(barcode));
      //   _markChanged();
      // }
    } catch (e) {
      // ignore: use_build_context_synchronously
      error(context: context, toast: e.toString());
      rethrow;
    }
  }

  void _onSaveButtonClicked(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    ctx.read<CategoryFormBloc>().add(SaveCategoryEvent());
  }
}
