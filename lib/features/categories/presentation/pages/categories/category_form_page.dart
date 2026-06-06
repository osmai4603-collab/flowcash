import 'dart:io';
import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/category_form/category_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/category_form/category_form_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/category_form/category_form_state.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';

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
        checkHasRequestsUseCase: sl(),
        getNewCategoryNumberUseCase: sl(),
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
  final bool _initialized = false;
  bool _isDataChanged = false;
  final categoryNameController = TextEditingController();

  final barcodeFocusNode = FocusNode();

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    return BlocListener<CategoryFormBloc, CategoryFormState>(
      listener: (context, state) async {
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
        child: fluent.ContentDialog(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 500.0 : double.infinity,
          ),
          title: Row(
            children: [
              IconButton(
                icon: Icon(fluent.FluentIcons.back_to_window),
                tooltip: 'رجوع',
                onPressed: _onBackPressed,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: fluent.Text(
                    'بيانات الصنف',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(fluent.FluentIcons.save),
                tooltip: 'حفظ البيانات',
                onPressed: () => _onSaveButtonClicked(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: BlocBuilder<CategoryFormBloc, CategoryFormState>(
              builder: (context, state) {
                if (state.status == CategoryFormStatus.initial ||
                    state.status == CategoryFormStatus.saving) {
                  return AppShimmer(
                    child: Column(
                      spacing: Spacings.medium,
                      children: [
                        ShimmerPlaceholder(height: 50),
                        ShimmerPlaceholder(),
                        Row(
                          spacing: Spacings.medium,
                          children: [
                            Expanded(child: ShimmerPlaceholder()),
                            Expanded(child: ShimmerPlaceholder()),
                          ],
                        ),
                        Row(
                          spacing: Spacings.medium,
                          children: [
                            Expanded(child: ShimmerPlaceholder()),
                            Expanded(child: ShimmerPlaceholder()),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return ShimmerLoadingWidget(
                  canShimmer:
                      state.status == CategoryFormStatus.saving ||
                      state.status == CategoryFormStatus.initial,
                  freezeScreen: state.status == CategoryFormStatus.saving,
                  period: const Duration(milliseconds: 900),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      spacing: Spacings.medium,
                      children: [
                        fluent.InfoLabel(
                          label: 'اسم الصنف',
                          child: fluent.TextFormBox(
                            textInputAction: TextInputAction.next,
                            initialValue: state.categoryName,
                            style: textTheme.bodyLarge,
                            autofocus: state.id == 0,
                            cursorHeight: 20.0,
                            onChanged: _onCategoryNameChanged,
                            validator: categoryNameValidator,
                            placeholder: 'ادخل اسم الصنف',

                            prefix: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(fluent.FluentIcons.category_classification),
                            ),
                          ),
                        ),
                        Row(
                          spacing: Spacings.medium,
                          children: [
                            Expanded(
                              child: fluent.InfoLabel(
                                label: 'رقم الصنف',
                                child: fluent.TextFormBox(
                                  placeholder: 'رقم الصنف',
                                  readOnly: true,
                                  textInputAction: TextInputAction.next,
                                  initialValue: state.categoryNumber,
                                  style: textTheme.bodyLarge,
                                  cursorHeight: 20.0,
                                  textDirection: .ltr,
                                  validator: categoryNumberValidator,
                                  suffix: Tooltip(
                                    message: 'تحديث رقم الصنف',
                                    child: IconButton(
                                      iconSize: 20,
                                      onPressed: _generateCategoryNumber,
                                      icon: Icon(
                                        fluent.FluentIcons.refresh,
                                        color: colors.onSurfaceVariant,
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
                                  prefix: IconButton(
                                    icon: Icon(fluent.FluentIcons.q_r_code),
                                    tooltip: 'قراء ماسح الباركود',
                                    onPressed: _scanBarcode,
                                  ),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  textDirection: TextDirection.ltr,
                                  initialValue: state.barcode,
                                  focusNode: barcodeFocusNode,
                                  cursorHeight: 20.0,
                                  style: textTheme.bodyLarge,
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
                            spacing: Spacings.medium,
                            children: [
                              Expanded(
                                child: fluent.InfoLabel(
                                  label: 'الوحدة',
                                  child: Tooltip(
                                    message:
                                        'نوع وحدة الصنف: ${state.selectedUnit?.unitType.fullUnitName ?? 'غير محدد'}',
                                    child: fluent.ComboBox<UnitEntity>(
                                      value: state.selectedUnit,
                                      disabledPlaceholder: fluent.Text(
                                        'لا يوجد وحدات معرفة',
                                        style: textTheme.labelMedium,
                                      ),
                                      placeholder: fluent.Text(
                                        'حدد وحدة الصنف',
                                        style: textTheme.labelMedium,
                                      ),
                                      isExpanded: true,
                                      icon: Icon(
                                        fluent.FluentIcons.chevron_down,
                                        color: colors.onSurfaceVariant,
                                      ),

                                      style: textTheme.bodyLarge,
                                      items: state.units.map((unit) {
                                        return fluent.  ComboBoxItem<UnitEntity>(
                                          value: unit,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              fluent.Text(
                                                unit.unitType.fullUnitName,
                                                style: textTheme.bodyLarge,
                                              ),
                                              const SizedBox(width: 10),
                                              fluent.Text(
                                                unit.unitType.symbolUnit,
                                                style: textTheme.bodyMedium
                                                    ?.copyWith(
                                                      color: colors
                                                          .onSurfaceVariant,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: _onSelectedCategoryUnit,
                                      selectedItemBuilder: (context) =>
                                          state.units.map((unit) {
                                            return Align(
                                              alignment: AlignmentDirectional
                                                  .centerStart,
                                              child: fluent.Text(
                                                unit.unitType.fullUnitName,
                                                style: textTheme.bodyLarge,
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: fluent.InfoLabel(
                                  label: 'النوع',
                                  child:  fluent.ComboBox<CategoryDefineType>(
                                    value: state.selectedCategoryType,

                                    isExpanded: true,
                                    icon: Icon(
                                      fluent.FluentIcons.chevron_down,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    style: textTheme.bodyLarge,
                                    items: CategoryDefineType.values.map((
                                      categoryType,
                                    ) {
                                      return fluent.  ComboBoxItem<CategoryDefineType>(
                                        value: categoryType,
                                        child: fluent.Text(
                                          categoryType.displayName(),
                                          style: textTheme.titleSmall,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (belongGroup) {
                                      if (belongGroup == null) return;
                                      context.read<CategoryFormBloc>().add(
                                        ChangeCategoryTypeEvent(belongGroup),
                                      );
                                      _markChanged();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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
