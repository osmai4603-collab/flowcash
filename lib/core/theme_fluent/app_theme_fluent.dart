import 'package:flowcash/core/theme/color_schemes.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme/styles.dart';
import 'package:flutter/material.dart' as material;
import 'package:flowcash/core/theme_fluent/color_scheme_fluent.dart';
import 'package:flowcash/core/theme_fluent/styles_fluent.dart';
import 'package:fluent_ui/fluent_ui.dart';

sealed class ThemesFluent {
  const ThemesFluent._();

  static FluentThemeData get light => _buildTheme(
    brightness: Brightness.light,
    accentColor: ColorSchemesFluent.lightAccent,
    colorScheme: ColorSchemes.light,
    typography: Typography.fromBrightness(
      brightness: Brightness.dark,
      color: ColorSchemes.light.onSurface,
    ),
  );

  static FluentThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    accentColor: ColorSchemesFluent.darkAccent,
    colorScheme: ColorSchemes.dark,
    typography: Typography.fromBrightness(
      brightness: Brightness.dark,
      color: ColorSchemes.dark.onSurface,
    ),
  );

  static FluentThemeData _buildTheme({
    required Brightness brightness,
    required AccentColor accentColor,
    required Typography typography,
    required material.ColorScheme colorScheme
  }) {
    return FluentThemeData(
      brightness: brightness,
      accentColor: accentColor,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: colorScheme.surfaceContainerHigh,
      typography: typography,
      shadowColor: colorScheme.shadow,
      acrylicBackgroundColor: colorScheme.surfaceContainerHighest,
      inactiveBackgroundColor: colorScheme.outlineVariant,
      fontFamily: 'Noto_Naskh_Arabic',
      micaBackgroundColor: colorScheme.surfaceContainerLowest,
      menuColor: colorScheme.surfaceContainerHigh,
      activeColor: accentColor,
      infoBarTheme: InfoBarThemeData(
        decoration: (info) => BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: Radiuses.xsmallAll,
        ),
        padding: Paddings.smallAll,

      ),
      
      dialogTheme: ContentDialogThemeData(
        decoration: ShapeDecoration(
          color: colorScheme.surfaceContainerHigh,
          shape: ContinuousRectangleBorder(
            side: BorderSide(color: accentColor, width: 1.0),
            borderRadius: Radiuses.mediumAll,
          ),
        ),
        actionsDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: Radiuses.xsmallAll,
        ),
        padding: Paddings.mediumAll,
      ),

      
      
      // buttonTheme: ButtonThemeData(
      //   defaultButtonStyle: ButtonStyle(
      //     backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
      //     foregroundColor: WidgetStateProperty.all(colorScheme.onSurface),
      //     shape: WidgetStateProperty.all(
      //       ContinuousRectangleBorder(borderRadius: Radiuses.smallAll),
      //     ),
      //   ),
      //   filledButtonStyle: ButtonStyle(
      //     backgroundColor: WidgetStateProperty.all(accentColor),
      //     foregroundColor: WidgetStateProperty.all(colorScheme.onSurface),
      //     shape: WidgetStateProperty.all(
      //       ContinuousRectangleBorder(borderRadius: Radiuses.smallAll),
      //     ),
      //   ),
        
      //   outlinedButtonStyle: ButtonStyle(
      //     backgroundColor: WidgetStateProperty.all(colorScheme.secondary),
      //     foregroundColor: WidgetStateProperty.all(
      //       colorScheme.onSurface,
      //     ),
      //     shape: WidgetStateProperty.all(
      //       ContinuousRectangleBorder(
      //         side: BorderSide(color: colorScheme.tertiary, width: 1.50),
      //         borderRadius: Radiuses.xsmallAll,
      //       ),
      //     ),
      //     textStyle: WidgetStateProperty.all(
      //       typography.subtitle?.copyWith(fontWeight: FontWeight.bold),
      //     ),
      //   ),
      //   iconButtonStyle: ButtonStyle(
      //     shape: WidgetStateProperty.all(
      //       RoundedRectangleBorder(
      //         borderRadius: Radiuses.none,
      //         side: BorderSide.none,
      //       ),
      //     ),
          
      //     padding: WidgetStateProperty.all(
      //       Paddings.xsmallAll,
      //     )
      //   ),
        
      // ),
      
      
    );
  }

  static FluentThemeData of(BuildContext context) {
    return FluentTheme.of(context);
  }
}
