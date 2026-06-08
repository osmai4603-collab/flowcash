import 'package:flutter/material.dart';
import 'package:flowcash/core/theme/styles.dart';

class CardButton extends StatelessWidget {
  final String image;
  final String text;
  final Color? color;
  final TextStyle? textStyle;
  final void Function() onPressed;
  final void Function()? onLongPressed;
  final Size? cardSize;
  final Size? imageSize;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? imageColor;
  final String? balance;
  final TextDirection? textDirection;

  const CardButton({
    super.key,
    required this.image,
    required this.text,
    required this.onPressed,
    this.textStyle,
    this.color,
    this.cardSize,
    this.margin,
    this.padding,
    this.imageColor,
    this.imageSize,
    this.balance,
    this.onLongPressed,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: margin ?? const EdgeInsets.all(0.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        onLongPress: onLongPressed,
        child: SizedBox(
          width: cardSize?.width ?? 170,
          height: cardSize?.height ?? 162,
          child: Padding(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
            child: Column(
              children: [
                Text(
                  text,
                  style: textStyle ?? Styles.titleSmall,
                  overflow: TextOverflow.ellipsis,
                  textDirection: textDirection,
                ),
                Image.asset(
                  image,
                  width: imageSize?.width ?? 120,
                  height: imageSize?.height ?? 80,
                  color: imageColor,
                ),
                if (balance != null)
                  Text(
                    balance!,
                    style:
                        textStyle ??
                        Styles.bodyMedium.copyWith(color: Colors.red.shade600),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
