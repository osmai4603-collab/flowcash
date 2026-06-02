
import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextDirection? textDirection;
  final TextAlign? textAlign;
  final Color? backColor;
  final EdgeInsets? padding;
  final Size? size;
  final bool selectable;
  final bool expanded;
  final AlignmentGeometry? alignment;
  final TextOverflow? overflow;

  const TextWidget({super.key,
    required this.text,
    this.style,
    this.textDirection,
    this.textAlign,
    this.backColor,
    this.padding,
    this.size,
    this.selectable = false,
    this.expanded = false,
    this.alignment,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return buildExpanded();
  }

  Widget buildSizedBox() {
    if(size == null) return buildBackColor();
    return SizedBox(
      height: size?.height == double.infinity ? null : size?.height,
      width: size?.width == double.infinity ? null : size?.width,
      child: buildBackColor(),
    );
  }

  Widget buildExpanded() {
    if(!expanded) return buildSizedBox();
    return Expanded(
      child: buildSizedBox(),
    );
  }

  Widget buildBackColor() {
    if(backColor == null) return buildPadding();
    return ColoredBox(
      color: backColor!,
      child: buildPadding(),
    );
  }

  Widget buildPadding() {
    if(padding == null) return buildAlign();
    return Padding(
      padding: padding!,
      child: buildAlign(),
    );
  }

  Widget buildAlign() {
    if(alignment == null) return buildText();
    return Align(
      alignment: alignment!,
      child: buildText(),
    );
  }

  Widget buildText() {
    if(selectable) {
      return SelectableText(
        text,
        style: style,
        textDirection: textDirection,
        textAlign: textAlign,
      );
    }
    return Text(
      text,
      style: style,
      textDirection: textDirection,
      textAlign: textAlign,
      overflow: overflow,
    );
  }

}
