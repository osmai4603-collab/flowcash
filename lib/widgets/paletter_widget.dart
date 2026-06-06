
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flowcash/widgets/my_text_widget.dart';
import 'package:flowcash/core/theme/styles.dart';

class PaletteWidget extends StatefulWidget {
  final Color color;
  const PaletteWidget({super.key, required this.color});

  @override
  State<PaletteWidget> createState() => _PaletteWidgetState();

}

class _PaletteWidgetState extends State<PaletteWidget> {
  Color colorSelected = Colors.white;
  PaletteType paletteTypeSelected = PaletteType.hueWheel;

  @override
  void initState() {
    super.initState();
    setState(() => colorSelected = widget.color);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Platform.isWindows || Platform.isLinux ? Alignment.center : const Alignment(0, -0.5),
      child: SizedBox(
        height: 730.0,
        width: 500.0,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                PopupMenuButton<PaletteType>(
                  initialValue: paletteTypeSelected,
                  itemBuilder: (_) => PaletteType.values.map((palette) {
                    return PopupMenuItem<PaletteType>(
                      value: palette,
                      height: 30,
                      child: TextWidget(
                        text: palette.name,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.start,
                        alignment: Alignment.centerLeft,
                      ),
                    );
                  }).toList(),
                  onSelected: (value) => setState(() => paletteTypeSelected = value),
                  child: TextWidget(
                    text: 'Palette Type: ${paletteTypeSelected.name}',
                    textDirection: TextDirection.ltr,
                    style: Styles.titleSmall,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  ),
                ),
                const SizedBox(height: 5),
                ColorPicker(
                  onColorChanged: (color2) async {
                    colorSelected = color2;
                  },
                  colorPickerWidth: Platform.isWindows || Platform.isLinux ? 350.0 : 300.0,
                  pickerColor: colorSelected,
                  enableAlpha: false,
                  paletteType: paletteTypeSelected,
                  hexInputBar: true,
                  portraitOnly: true,
                  displayThumbColor: true,
                ),
                ElevatedButton(
                  child: const TextWidget(
                    text: 'حفظ بيانات اللون',
                  ),
                  onPressed: () => Navigator.pop(context, colorSelected),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
