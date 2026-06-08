import 'package:flowcash/features/settings/domain/entities/app_value_entity.dart';
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class SettingTile extends StatefulWidget {
  final AppValueEntity value;
  final ValueChanged<AppValueEntity> onSave;

  const SettingTile({super.key, required this.value, required this.onSave});

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.value);
  }

  @override
  void didUpdateWidget(covariant SettingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value.value != oldWidget.value.value) {
      _controller.text = widget.value.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(
      AppValueEntity(
        id: widget.value.id,
        value: _controller.text,
        valueType: widget.value.valueType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fluent.Text(
              widget.value.valueType.displayName(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Value'),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: fluent.FilledButton(
                onPressed: _save,
                child: const fluent.Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
