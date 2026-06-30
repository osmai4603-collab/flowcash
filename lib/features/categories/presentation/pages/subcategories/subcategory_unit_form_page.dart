import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_entity.dart';
import 'package:flowcash/features/categories/domain/entities/subcategory_unit_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/subcategories/subcategory_unit_form_cubit.dart';
import 'package:flowcash/features/categories/presentation/pages/units/unit_form_page.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SubcategoryUnitFormPage extends StatelessWidget {
  final SubcategoryEntity subcategory;
  final CategoryPropertyEntity property;

  const SubcategoryUnitFormPage({
    super.key,
    required this.subcategory,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SubcategoryUnitFormCubit>()
        ..loadUnits(
          property: property,
          subcategoryId: subcategory.id,
        ),
      child: _SubcategoryUnitFormView(subcategory: subcategory, property: property),
    );
  }
}

class _SubcategoryUnitFormView extends StatelessWidget {
  final SubcategoryEntity subcategory;
  final CategoryPropertyEntity property;

  const _SubcategoryUnitFormView({
    required this.subcategory,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    
    return BlocBuilder<SubcategoryUnitFormCubit, SubcategoryUnitFormState>(
      builder: (context, state) {
        return fluent.ContentDialog(
          constraints: const BoxConstraints(maxWidth: 400),
          title: Row(
            children: [
              fluent.Icon(
                fluent.FluentIcons.add_connection,
                color: colors.primary,
              ),
              const SizedBox(width: 10),
              fluent.Text('إضافة ${property.propertyName}'),
            ],
          ),
          content: fluent.SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status == SubcategoryUnitFormStatus.loading)
                  const Center(child: fluent.ProgressRing())
                else if (state.status == SubcategoryUnitFormStatus.failure)
                  fluent.Text(
                    state.errorMessage ?? 'حدث خطأ ما',
                    style: TextStyle(color: colors.error),
                  )
                else ...[
                  fluent.InfoLabel(
                    label: 'اختر نوع ال${property.propertyName} من القائمة',
                    child: Row(
                      children: [
                        Expanded(
                          child: fluent.ComboBox<UnitEntity>(
                            value: state.selectedUnit,
                            items: state.units.map((unit) {
                              return fluent.ComboBoxItem<UnitEntity>(
                                value: unit,
                                child: fluent.Text(unit.unitName),
                              );
                            }).toList(),
                            onChanged: (unit) {
                              context.read<SubcategoryUnitFormCubit>().selectUnit(unit);
                            },
                            placeholder: const fluent.Text('حدد النوع'),
                            isExpanded: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        fluent.Tooltip(
                          message: 'إنشاء نوع جديد',
                          child: fluent.IconButton(
                            icon: fluent.Icon(
                              fluent.FluentIcons.add,
                              color: colors.primary,
                            ),
                            onPressed: () async {
                              final newUnit = await showDialog<UnitEntity>(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => UnitFormPage(property: property),
                              );
                              if (newUnit != null && context.mounted) {
                                context.read<SubcategoryUnitFormCubit>().addAndSelectUnit(newUnit);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (state.units.isEmpty && state.status == SubcategoryUnitFormStatus.success)
                     const fluent.Text(
                      'لا يوجد أنواع معرفة مسبقاً لهذا الخاصية، يرجى إضافة نوع جديد.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            fluent.Button(
              onPressed: () => Navigator.pop(context),
              child: const fluent.Text('إلغاء'),
            ),
            fluent.FilledButton(
              onPressed: state.selectedUnit == null
                  ? null
                  : () {
                      final selectedUnit = state.selectedUnit!;
                      Navigator.pop(
                        context,
                        SubcategoryUnitEntity(
                          id: 0,
                          subcategoryId: subcategory.id,
                          unitId: selectedUnit.id,
                          propertyId: property.id,
                          unitName: selectedUnit.unitName,
                        ),
                      );
                    },
              child: const fluent.Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }
}
