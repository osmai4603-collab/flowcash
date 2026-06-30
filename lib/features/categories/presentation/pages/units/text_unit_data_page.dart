import 'dart:io';
import 'package:flowcash/core/theme/spacings.dart';
import 'package:flowcash/features/categories/domain/entities/category_property_entity.dart';
import 'package:flowcash/features/categories/domain/entities/main_category_entity.dart';
import 'package:flowcash/features/categories/domain/entities/unit_entity.dart';
import 'package:flowcash/widgets/message.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_bloc.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_event.dart';
import 'package:flowcash/features/categories/presentation/blocs/unit_form/unit_form_state.dart';

import 'package:fluent_ui/fluent_ui.dart' as fluent;

import '../../../../../core/theme_fluent/app_colors.dart';

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
    // final propertyId = widget.unit?.propertyId ?? widget.property.id;

    context.read<UnitFormBloc>().add(
      SaveUnitFormEvent(
        UnitEntity.text(
          id: widget.unit?.id ?? 0,
          textName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppStyle.of(context);
    return BlocBuilder<UnitFormBloc, UnitFormState>(
      builder: (context, state) {
        final isSaving = state.status == UnitFormStatus.saving;
        final isEditing = widget.unit?.id != null && widget.unit?.id != 0;

        return PopScope(
          canPop: !_isDataChanged,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _onBackPressed();
          },
          child: fluent.ContentDialog(
            constraints: const BoxConstraints(maxWidth: 400.0),
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
                  isEditing
                      ? 'تعديل ${widget.property.propertyName}'
                      : 'إضافة ${widget.property.propertyName} جديدة',
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  spacing: Spacings.medium,
                  children: [
                    TextWidget(
                      text:
                          'ادخال ${widget.property.propertyName} حبة',
                      textAlign: TextAlign.center,
                    ),
                    fluent.TextFormBox(
                      controller: textUnitNameController,
                      onChanged: (_) => _markChanged(),
                      autofocus: true,
                      enabled: !isSaving,
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
                          color: colors.primary,
                        ),
                      ),
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
                onPressed: isSaving ? null : _onSaveButtonClicked,
                child: isSaving
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
    );
  }
}
