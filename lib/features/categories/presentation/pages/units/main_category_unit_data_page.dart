import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_unit_data/main_category_unit_data_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_unit_data/main_category_unit_data_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/main_category_unit_data/main_category_unit_data_state.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flowcash/core/theme/styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' show ContentDialog, FluentIcons;
class MainCategoryUnitDataPage extends StatefulWidget {
  final MainCategoryEntity mainCategory;
  const MainCategoryUnitDataPage({super.key, required this.mainCategory});

  @override
  State<MainCategoryUnitDataPage> createState() =>
      _MainCategoryUnitDataPageState();
}

class _MainCategoryUnitDataPageState extends State<MainCategoryUnitDataPage> {
  final _formKey = GlobalKey<FormState>();
  MainCategoryEntity get category => widget.mainCategory;
  final categoryNameController = TextEditingController();
  bool _isDataChanged = false;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  void _markChanged() {
    if (!_isDataChanged) setState(() => _isDataChanged = true);
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MainCategoryUnitDataBloc()
            ..add(InitMainCategoryUnitDataEvent(widget.mainCategory)),
      child: BlocConsumer<MainCategoryUnitDataBloc, MainCategoryUnitDataState>(
        listener: (context, state) {
          if (state is MainCategoryUnitDataFailure) {
            error(context: context, toast: state.message);
          }
          if (state is MainCategoryUnitDataLoadSuccess &&
              categoryNameController.text.isEmpty) {
            categoryNameController.text = state.category.name;
          }
          if (state is MainCategoryUnitDataSaveSuccess) {
            Navigator.pop(context, state.result);
          }
        },
        builder: (context, state) {
          if (state is MainCategoryUnitDataLoadInProgress ||
              state is MainCategoryUnitDataInitial ||
              state is MainCategoryUnitDataSaveInProgress) {
            final isSaving = state is MainCategoryUnitDataSaveInProgress;
            return ShimmerLoadingWidget(
              canShimmer: true,
              freezeScreen: isSaving,
              period: const Duration(milliseconds: 900),
              child: const SizedBox(
                height: 220,
                width: double.infinity,
                child: Card(),
              ),
            );
          }
          if (state is MainCategoryUnitDataLoadSuccess) {
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MainCategoryUnitDataLoadSuccess state,
  ) {
    final colors = ColorScheme.of(context);
    return PopScope(
      canPop: !_isDataChanged,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed();
      },
      child: ContentDialog(
        constraints: const BoxConstraints(maxWidth: 500.0),
        content: Padding(
          padding: Paddings.mediumAll,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                spacing: Spacings.medium,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(FluentIcons.back),
                        tooltip: 'رجوع',
                        onPressed: _onBackPressed,
                      ),
                      const TextWidget(
                        text: 'بيانات الصنف الرئيسي',
                        expanded: true,
                        alignment: Alignment.center,
                      ),
                      IconButton(
                        icon: const Icon(FluentIcons.save),
                        tooltip: 'حفظ البيانات',
                        onPressed: () => _onSaveButtonClicked(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacings.small),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: categoryNameController,
                    onChanged: (_) => _markChanged(),
                    textAlignVertical: isDesktop
                        ? TextAlignVertical.top
                        : TextAlignVertical.center,
                    style: Styles.titleMedium,
                    cursorHeight: 20.0,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم الصنف';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'ادخل اسم الصنف',
                      hintStyle: Styles.titleSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      labelText: 'اسم الصنف',
                      labelStyle: Styles.titleMedium.copyWith(
                        color: colors.primary,
                      ),

                      prefixIcon: Icon(FluentIcons.category_classification,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Row(
                    spacing: Spacings.medium,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<CategoryPropertyEntity>(
                          initialValue: state.pricingPropertySelected,
                          decoration: InputDecoration(
                            labelText: 'وحدة السعر',
                            labelStyle: Styles.titleMedium.copyWith(
                              color: colors.primary,
                            ),
                          ),
                          items: state.properties.map((property) {
                            return DropdownMenuItem<CategoryPropertyEntity>(
                              value: property,
                              child: Text(property.unitType.fullUnitName),
                            );
                          }).toList(),
                          onChanged: (belongGroup) {
                            if (belongGroup != null) {
                              context.read<MainCategoryUnitDataBloc>().add(
                                UpdatePricingPropertyEvent(belongGroup),
                              );
                              _markChanged();
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'يرجى اختيار وحدة السعر';
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<CategoryPropertyEntity>(
                          initialValue: state.inventoryPropertySelected,
                          decoration: InputDecoration(
                            labelText: 'وحدة الجرد',
                            labelStyle: Styles.titleMedium.copyWith(
                              color: colors.primary,
                            ),
                          ),
                          items: state.properties.map((property) {
                            return DropdownMenuItem<CategoryPropertyEntity>(
                              value: property,
                              child: Text(
                                property.unitType.fullUnitName,
                                style: Styles.titleMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (belongGroup) {
                            if (belongGroup != null) {
                              context.read<MainCategoryUnitDataBloc>().add(
                                UpdateInventoryPropertyEvent(belongGroup),
                              );
                              _markChanged();
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'يرجى اختيار وحدة الجرد';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSaveButtonClicked(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    context.read<MainCategoryUnitDataBloc>().add(
      SaveMainCategoryUnitDataEvent(categoryNameController.text),
    );
  }
}
