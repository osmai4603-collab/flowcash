import 'package:flowcash/core/enums/unit_type_enum.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_state.dart';
import 'package:flowcash/features/categories/presentation/pages/units/linear_meter_unit_data_page.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flowcash/features/categories/presentation/pages/units/meter_unit_data_page.dart';
import 'package:flowcash/features/categories/presentation/pages/units/weight_data_page.dart';
import 'package:flowcash/features/categories/presentation/pages/units/text_unit_data_page.dart';
import 'package:flowcash/features/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;
class UnitFormPage extends StatefulWidget {
  final UnitEntity? unit;
  final CategoryPropertyEntity property;
  UnitFormPage({super.key, this.unit, required this.property})
    : assert(
        (unit != null && unit.unitType == property.unitType) || unit == null,
      );

  @override
  State<UnitFormPage> createState() => _UnitFormPageState();
}

class _UnitFormPageState extends State<UnitFormPage> {
  late final UnitFormBloc _unitFormBloc;
  @override
  void initState() {
    super.initState();
    _unitFormBloc = UnitFormBloc(
      getMainCategory: sl(),
      getUnits: sl(),
      saveUnit: sl(),
    )..add(InitUnitFormEvent(widget.property, widget.unit));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _unitFormBloc,
      child: BlocListener<UnitFormBloc, UnitFormState>(
        listener: (context, state) {
          if (state.status == UnitFormStatus.saved) {
            Navigator.pop(context, state.saved);
          }
          if (state.status == UnitFormStatus.failure) {
            fluent.displayInfoBar(context, builder: (context, close) => fluent.InfoBar(title: const fluent.Text('تنبيه'), content: fluent.Text(state.messageError ?? 'حدث خطأ')));
          }
        },
        child: BlocBuilder<UnitFormBloc, UnitFormState>(
          builder: (context, state) {
            if (state.status == UnitFormStatus.failure) {
              return Center(child: fluent.Text(state.messageError ?? 'حدث خطأ'));
            }
            if (state.status == UnitFormStatus.initial ||
                state.status == UnitFormStatus.saving ||
                state.status == UnitFormStatus.loading) {
              return ShimmerLoadingWidget(
                canShimmer: true,
                freezeScreen: state.status == UnitFormStatus.saving,
                period: const Duration(milliseconds: 900),
                child: _buildUnitForm(state),
              );
            }
            return _buildUnitForm(state);
          },
        ),
      ),
    );
  }

  Widget _buildUnitForm(UnitFormState state) {
    switch (widget.property.unitType) {
      case ModelUnitType():
        return TextUnitDataPage(property: widget.property, unit: widget.unit);
      case PieceUnitType():
        return Container();
      case WeightUnitType():
        return WeightUnitDataPage(property: widget.property, unit: widget.unit);
      case LinearMeterUnitType():
        return LinearMeterUnitDataPage(
          property: widget.property,
          unit: widget.unit,
        );
      case SquareMeterUnitType():
      case SquareMeterStaticUnitType():
      case SquareMeterWidthStaticUnitType():
      case CubitMeterUnitType():
        return MeterUnitDataPage(property: widget.property, unit: widget.unit);
    }
  }
}
