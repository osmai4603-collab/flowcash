import 'dart:io';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/core/widgets/shimmer_loading_widget.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flowcash/core/theme/styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

class TextUnitDataPage extends StatefulWidget {
  final CategoryPropertyEntity property;
  final UnitEntity? unit;

  const TextUnitDataPage({super.key, required this.property, this.unit});

  @override
  State<TextUnitDataPage> createState() => _TextUnitDataPageState();
}

class _TextUnitDataPageState extends State<TextUnitDataPage> {
  final _formKey = GlobalKey<FormState>();
  final textUnitNameController = TextEditingController();
  MainCategoryEntity? category;
  bool _isDataChanged = false;

  bool get isDesktop => Platform.isLinux || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    final state = context.read<UnitFormBloc>().state;
    category = state.category;
    textUnitNameController.text = state.initialName;
  }

  @override
  void dispose() {
    textUnitNameController.dispose();
    super.dispose();
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
    if (sure && context.mounted) {
      setState(() => _isDataChanged = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
    }
  }

  void _onSaveButtonClicked() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final name = textUnitNameController.text
        .split(' ')
        .where((e) => e.isNotEmpty && e != ' ')
        .join(' ');
    final propertyId = widget.unit?.propertyId ?? widget.property.id;

    context.read<UnitFormBloc>().add(
      SaveUnitFormEvent(
        UnitEntity.text(
          id: widget.unit?.id ?? 0,
          textName: name,
          propertyId: propertyId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.of(context);
    return BlocBuilder<UnitFormBloc, UnitFormState>(
      builder: (context, state) {
        final isLoading =
            state.status == UnitFormStatus.initial ||
            state.status == UnitFormStatus.loading ||
            state.status == UnitFormStatus.saving;
        final isSaving = state.status == UnitFormStatus.saving;
        return PopScope(
          canPop: !_isDataChanged,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onBackPressed();
          },
          child: fluent.ContentDialog(
            constraints: const BoxConstraints(maxWidth: 400.0),
            content: ShimmerLoadingWidget(
              canShimmer: isLoading,
              freezeScreen: isSaving,
              period: const Duration(milliseconds: 900),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    spacing: Spacings.medium,
                    children: [
                      Row(
                        children: [
                          fluent.Tooltip(
                            message: 'رجوع',
                            child: fluent.IconButton(
                              icon: fluent.Icon(fluent.FluentIcons.back_to_window, size: 20,),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          TextWidget(
                            text:
                                'ادخال ${widget.property.propertyName} ${category?.unitName ?? 'حبة'}',
                            expanded: true,
                            textAlign: TextAlign.center,
                          ),
                          fluent.Tooltip(
                            message: 'حفظ البيانات',
                            child: fluent.IconButton(
                              icon: fluent.Icon(fluent.FluentIcons.save, size: 20,),
                              onPressed: _onSaveButtonClicked,
                            ),
                          ),
                        ],
                      ),
                      fluent.TextFormBox(
                        controller: textUnitNameController,
                        onChanged: (_) => _markChanged(),
                        autofocus: true,
                        onFieldSubmitted: (_) => _onSaveButtonClicked(),
                        cursorHeight: 20.0,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'اسم ال${widget.property.propertyName} فارغ';
                          }
                          return null;
                        },
                        placeholder: 'ادخل اسم ال${widget.property.propertyName}',
                        prefix: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: fluent.Icon(
                            fluent.FluentIcons.modeling_view,
                            color: ColorScheme.of(context).primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
