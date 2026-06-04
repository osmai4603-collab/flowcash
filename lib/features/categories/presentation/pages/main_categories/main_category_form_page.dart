import 'package:flowcash/core/enums/category_type_enum.dart';
import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_form/main_category_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_form/main_category_form_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_form/main_category_form_state.dart';
import 'package:flowcash/features/injection_container.dart';

import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainCategoryFormPage extends StatefulWidget {
  final int? id;
  const MainCategoryFormPage({super.key, this.id});

  @override
  State<MainCategoryFormPage> createState() => _MainCategoryFormPageState();
}

class _MainCategoryFormPageState extends State<MainCategoryFormPage> {
  final categoryNameController = TextEditingController();
  final unitNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final MainCategoryFormBloc _bloc;
  bool _initialized = false;
  bool _isDataChanged = false;

  UnitType unitSelected = UnitType.piece;
  CategoryDefineType categoryTypeSelected = CategoryDefineType.commodities;
  List<_PropertyModel> properties = [];

  bool get hasNotDescriptive {
    return properties.indexWhere(
              (pro) => pro.unitTypeSelected != UnitType.model,
            ) >
            -1 &&
        properties.length > 1;
  }

  List<UnitType> getPropertiesTypes(_PropertyModel currentProperty) {
    final measureUnitType = currentProperty.unitTypeSelected;
    final unitsTypes = UnitType.values
        .where((unitType) => unitType.isVisible)
        .toList();
    unitsTypes.removeWhere(
      (unitType) =>
          properties.indexWhere(
                (property) =>
                    property != currentProperty &&
                    property.unitTypeSelected == unitType,
              ) >
              -1 &&
          unitType.isMeasurable,
    );
    if (unitSelected.isLinearMeter) {
      unitsTypes.removeWhere(
        (unitType) =>
            unitType.isSquareMeter ||
            unitType.isSquareMeterStatic ||
            unitType.isCubitMeter,
      );
    }
    if (unitSelected.isSquareMeter) {
      unitsTypes.removeWhere(
        (unitType) =>
            (unitType.hasSquareMeter && !unitType.isSquareMeter) ||
            unitType.isCubitMeter,
      );
    }
    if (unitSelected.isCubitMeter) {
      unitsTypes.removeWhere(
        (unitType) => unitType.isLinearMeter || unitType.hasSquareMeter,
      );
    }
    if (properties.indexWhere(
              (property) =>
                  property != currentProperty &&
                  (property.unitTypeSelected?.isMeterMeasurable ?? false),
            ) >
            -1 &&
        !(measureUnitType?.isMeterMeasurable ?? false)) {
      unitsTypes.removeWhere((unitType) => unitType.isMeterMeasurable);
    }
    unitsTypes.removeWhere((unitType) => unitType == unitSelected);
    if (measureUnitType != null && !unitsTypes.contains(measureUnitType)) {
      unitsTypes.add(measureUnitType);
    }
    return unitsTypes;
  }

  @override
  void initState() {
    super.initState();
    _bloc = MainCategoryFormBloc(initUseCase: sl(), saveUseCase: sl());
    _bloc.add(InitMainCategoryFormEvent(id: widget.id));
    _initializeFromState(_bloc.state);
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    unitNameController.dispose();
    _bloc.close();
    for (var property in properties) {
      property.propertyName.dispose();
    }
    super.dispose();
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
    if (sure && mounted) {
      setState(() => _isDataChanged = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
    }
  }

  void _initializeFromState(MainCategoryFormState state) {
    if (_initialized || state.status != MainCategoryFormStatus.ready) return;

    _initialized = true;
    categoryNameController.text = state.name;
    categoryTypeSelected = state.type;
    unitSelected = state.unitType;
    unitNameController.text = state.unitName;
    properties = state.properties
        .map((p) => _PropertyModel.fromEntity(p))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.of(context);
    return BlocProvider.value(
      value: _bloc,
      child: PopScope(
        canPop: !_isDataChanged,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _onBackPressed();
        },
        child: Dialog(
          constraints: BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: Paddings.mediumAll,
            child: SingleChildScrollView(
              child: BlocConsumer<MainCategoryFormBloc, MainCategoryFormState>(
                listener: (context, state) {
                  if (state.status == MainCategoryFormStatus.saved) {
                    Navigator.of(context).pop(state.entity);
                  }
                  if (state.status == MainCategoryFormStatus.failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.messageError ?? 'حدث خطأ في حفظ الصنف',
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // Show shimmer during initial load and while saving; freeze screen when saving.
                  
                  if (state.status == MainCategoryFormStatus.initial || state.status == MainCategoryFormStatus.saving) {
                    return MainCategoryFormShimmer(
                      countItems: state.properties.length,
                    );
                  }
                  return _buildForm(context, colors);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ColorScheme colors) {
    final textTheme = TextTheme.of(context);
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: _formKey,
      child: Column(
        spacing: Spacings.medium,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_outlined),
                tooltip: 'رجوع',
                onPressed: () => Navigator.pop(context),
              ),
              TextWidget(
                text: 'اضافة صنف رئيسي',
                expanded: true,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'حفظ البيانات',
                onPressed: _onSaveButtonClicked,
              ),
            ],
          ),
          Row(
            spacing: Spacings.medium,
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: categoryNameController,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  autofocus: true,
                  cursorHeight: 20.0,
                  decoration: InputDecoration(
                    hintText: 'ادخل اسم الصنف الرئيسي',
                    label: Text('اسم الصنف'),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  onChanged: (value) {
                    _markChanged();
                    _bloc.add(MainCategoryNameChangedEvent(value));
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اسم الصنف الرئيسي مطلوب';
                    }
                    return null;
                  },
                ),
              ),
              Expanded(
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  controller: unitNameController,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  cursorHeight: 20.0,
                  decoration: InputDecoration(
                    hintText: 'ادخل اسم الوحدة',
                    label: Text('اسم الوحدة'),
                    prefixIcon: Icon(
                      Icons.circle_outlined,
                      color: colors.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اسم الوحدة مطلوب';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          Row(
            spacing: Spacings.medium,
            children: [
              Expanded(
                child: DropdownButtonFormField<UnitType>(
                  initialValue: unitSelected,
                  disabledHint: Text(
                    'لا يوجد وحدات معرفة',
                    style: textTheme.labelMedium,
                  ),

                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: colors.onSurfaceVariant,
                  ),
                  isExpanded: true,
                  validator: (value) {
                    return null;
                  },
                  decoration: InputDecoration(
                    label: Text('الوحدة'),
                    hint: Text('حدد وحدة الصنف'),

                    prefixIcon: Icon(Icons.ac_unit),
                  ),
                  items: UnitType.values.where((type) => type.isBasic).map((
                    unit,
                  ) {
                    return DropdownMenuItem<UnitType>(
                      value: unit,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(unit.fullUnitName),
                          const SizedBox(width: 10),
                          Text(
                            unit.symbolUnit,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _markChanged();
                      setState(() => unitSelected = value);
                    }
                  },
                ),
              ),
              Expanded(
                child: DropdownButtonFormField<CategoryDefineType>(
                  initialValue: categoryTypeSelected,
                  decoration: InputDecoration(
                    label: Text('نوع الصنف'),

                    prefixIcon: Icon(
                      Icons.circle_outlined,
                      color: colors.primary,
                    ),
                  ),
                  isExpanded: true,
                  items: CategoryDefineType.values.map((type) {
                    return DropdownMenuItem<CategoryDefineType>(
                      value: type,
                      child: Text(type.displayName()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _markChanged();
                      setState(() => categoryTypeSelected = value);
                      _bloc.add(MainCategoryTypeChangedEvent(value));
                    }
                  },
                  disabledHint: Text('لا يوجد انواع اصناف '),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacings.medium),
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: colors.onSurfaceVariant, width: 1),
              borderRadius: Radiuses.smallAll,
            ),
            padding: Paddings.mediumAll,
            child: Column(
              spacing: Spacings.medium,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: categoryNameController,
                  builder: (context, textValue, child) {
                    return TextWidget(
                      text: 'خصائص ${textValue.text}',
                      alignment: Alignment.center,
                      style: textTheme.titleMedium,
                    );
                  },
                ),
                if (properties.isNotEmpty) const SizedBox(height: 10),
                if (properties.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: properties.length,
                    itemBuilder: (_, index) {
                      return _buildUnitModelDismissibleWidget(
                        properties[index],
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 10);
                    },
                  ),
                if (properties.isEmpty)
                  const TextWidget(text: 'لا يوجد اي خصائص'),
                const SizedBox(height: Spacings.medium),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: ColorScheme.of(context).primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: Radiuses.xsmallAll,
                    ),
                  ),
                  onPressed: _onAddNewProperty,
                  child: Text(
                    'اضافة خصائص جديدة',
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProperty(_PropertyModel property) {
    final colors = ColorScheme.of(context);
    final textTheme = TextTheme.of(context);
    return Container(
      padding: Paddings.mediumAll,
      decoration: BoxDecoration(
        borderRadius: Radiuses.smallAll,
        border: Border.all(width: 0.50, color: colors.outline.withValues(alpha: 0.80)),
      ),
      child: Column(
        spacing: Spacings.medium,
        children: [
          Row(
            crossAxisAlignment: .start,
            spacing: Spacings.medium,
            children: [
              Expanded(
                child: TextFormField(
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textInputAction: TextInputAction.next,
                  controller: property.propertyName,
                  cursorHeight: 20.0,
                  decoration: InputDecoration(
                    hintText: 'ادخل اسم الخاصية',
                    label: Text('اسم الخاصية'),
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  onChanged: (_) => _markChanged(),
                ),
              ),
              Expanded(
                child: DropdownButtonFormField<UnitType>(
                  initialValue: property.unitTypeSelected,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.ac_unit_rounded),
                    label: Text('نوع الوحدة'),
                    hint: Text('حدد نوع الوحدة'),
                  ),
                  disabledHint: Text('لا يوجد اي وحدات متاحة'),
                  isExpanded: true,
                  items: getPropertiesTypes(property).map((unitType) {
                    return DropdownMenuItem<UnitType>(
                      value: unitType,
                      child: Text(unitType.propertyData),
                    );
                  }).toList(),
                  onChanged: (unitType) {
                    if (unitType != null) {
                      property.isInventoryUnit = false;
                      setState(() => property.unitTypeSelected = unitType);
                      _markChanged();
                    }
                  },
                ),
              ),
            ],
          ),
          CheckboxListTile(
            tileColor: colors.surfaceContainerHigh,
            title: ValueListenableBuilder<TextEditingValue>(
              valueListenable: property.propertyName,
              builder: (_, value, _) {
                return TextWidget(
                  text:
                      '${value.text} واحد لكل ${categoryTypeSelected.displayName()}',
                );
              },
            ),
            value: property.isSingle,
            onChanged: (value) {
              setState(() => property.isSingle = value ?? false);
              _markChanged();
            },
            activeColor: ColorScheme.of(context).primary,
            side: BorderSide(color: colors.onSurface, width: 1),
            controlAffinity: .leading,
          ),
        ],
      ),
    );
  }

  Widget _buildUnitModelDismissibleWidget(_PropertyModel property) {
    final colors = ColorScheme.of(context);
    return Dismissible(
      key: ObjectKey(property),
      background: Container(
        padding: Paddings.mediumAll,
        decoration: BoxDecoration(
          borderRadius: Radiuses.smallAll,
          color: ColorScheme.of(context).error,
          border: Border.all(width: 0.50),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(Icons.delete_outline, color: colors.onError),
            const SizedBox(width: 5),
            TextWidget(
              text: 'ازالة',
              style: TextTheme.of(
                context,
              ).titleSmall?.copyWith(color: colors.onError),
            ),
          ],
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: buildProperty(property),
      confirmDismiss: (dismiss) async {
        return await makeSure(
          context: context,
          title: 'إزالة الخاصية',
          content:
              'هل انت متأكد من إزالة الخاصية ${property.propertyName.text}',
        );
      },
      onDismissed: (_) {
        setState(() => properties.remove(property));
      },
    );
  }

  void _onAddNewProperty() {
    properties.add(_PropertyModel(id: 0));
    if (hasNotDescriptive) {
      properties.last.unitTypeSelected = UnitType.values.first;
    }
    setState(() {});
  }

  void _onSaveButtonClicked() {
    if (!_formKey.currentState!.validate()) return;

    for (var property in properties) {
      if (property.unitTypeSelected == null) {
        error(toast: 'لم يتم تحديد نوع الخاصية', context: context);
        return;
      }
      if (property.propertyName.text.replaceAll(' ', '').isEmpty) {
        error(toast: 'لم يتم تحديد اسم الخاصية', context: context);
        return;
      }
    }

    final category = MainCategoryEntity(
      id: _bloc.state.id,
      name: categoryNameController.text.trim(),
      type: categoryTypeSelected,
      unitName: unitNameController.text.trim(),
      unitType: unitSelected,
      properties: properties.map(_toCategoryPropertyEntity).toList(),
    );
    _bloc.add(SaveMainCategoryEvent(category));
  }

  CategoryPropertyEntity _toCategoryPropertyEntity(_PropertyModel property) {
    return CategoryPropertyEntity(
      id: property.id,
      mainCategoryId: _bloc.state.id,
      propertyName: property.propertyName.text.isEmpty
          ? property.unitTypeSelected?.propertyName ?? ''
          : property.propertyName.text,
      unitType: property.unitTypeSelected ?? UnitType.piece,
      isSingle: property.isSingle,
      isCategoryUnit: property.isCategoryUnit(unitSelected),
      isInventoryUnit: property.isInventoryUnit,
      isPricingUnit: property.isPricingUnit,
    );
  }
}

class MainCategoryFormShimmer extends StatelessWidget {
  final int countItems;
  const MainCategoryFormShimmer({super.key, required this.countItems});

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
              ShimmerPlaceholder(height: 40, width: 40),
              ShimmerPlaceholder(height: 40, width: 250),
              ShimmerPlaceholder(height: 40, width: 50),
            ],
          ),
          ShimmerPlaceholder(height: 2),
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
          const SizedBox(height: Spacings.medium),
          Container(
            decoration: BoxDecoration(
              borderRadius: Radiuses.smallAll,
              border: Border.all(
                color: ColorScheme.of(
                  context,
                ).onSurface.withValues(alpha: 0.80),
                width: 1.50,
              ),
            ),
            padding: Paddings.mediumAll,
            child: Column(
              spacing: Spacings.medium,
              children: [
                ShimmerPlaceholder(
                  height: 30,
                  width: 300,
                  borderRadius: Radiuses.small,
                ),
                const SizedBox(height: Spacings.medium),
                ...List.generate(countItems, (index) {
                  return ShimmerPlaceholder(height: 100);
                }),
                ShimmerPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyModel {
  int id;
  final propertyName = TextEditingController();
  UnitType? unitTypeSelected;
  bool isSingle = false;
  bool isInventoryUnit = false;
  bool isPricingUnit = false;

  _PropertyModel({required this.id});

  factory _PropertyModel.fromEntity(CategoryPropertyEntity entity) {
    final property = _PropertyModel(id: entity.id);
    property.propertyName.text = entity.propertyName;
    property.unitTypeSelected = entity.unitType;
    property.isSingle = entity.isSingle;
    property.isInventoryUnit = entity.isInventoryUnit;
    property.isPricingUnit = entity.isPricingUnit;
    return property;
  }

  bool isCategoryUnit(UnitType unitType) {
    if (unitTypeSelected == null) return false;
    return unitTypeSelected! == unitType;
  }
}
