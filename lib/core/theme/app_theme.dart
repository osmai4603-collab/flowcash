import 'package:flowcash/core/theme/color_schemes.dart';
import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme/styles.dart';
import 'package:flutter/material.dart';

sealed class Themes {
  const Themes._();

  static ThemeData get light =>
      _buildTheme(colorScheme: ColorSchemes.light, textTheme: Styles.textTheme);
  static ThemeData get dark =>
      _buildTheme(colorScheme: ColorSchemes.dark, textTheme: Styles.textTheme);

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,

      appBarTheme: AppBarTheme(
        elevation: 0.0,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actionsIconTheme: IconThemeData(color: colorScheme.surfaceBright),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,
        margin: Paddings.smallAll,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: colorScheme.primary, width: 0.50),
          borderRadius: Radiuses.smallAll,
        ),
        elevation: 0.0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: ContinuousRectangleBorder(
            borderRadius: Radiuses.smallAll,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSurface,
          alignment: Alignment.centerRight,
          side: BorderSide(color: colorScheme.primary, width: 0.50),
          padding: Paddings.xsmallAll,
          shape: ContinuousRectangleBorder(
            side: BorderSide(color: colorScheme.tertiary, width: 1.50),
            borderRadius: Radiuses.smallAll,
          ),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: colorScheme.onPrimary,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: colorScheme.outline,
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),

        unselectedLabelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        insetPadding: Paddings.mediumAll,
        alignment: Alignment.center,
        shape: ContinuousRectangleBorder(
          side: BorderSide(color: colorScheme.primary),
          borderRadius: Radiuses.largeAll,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainer),
          surfaceTintColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainer,
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colorScheme.surface,
        headerBackgroundColor: colorScheme.primary,
        headerForegroundColor: colorScheme.surface,
        dayStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: Radiuses.smallAll,
            side: BorderSide.none,
          ),
        ),
      ),

      

      inputDecorationTheme: InputDecorationThemeData(
        contentPadding: Paddings.smallAll,
        hintStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.50),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
        isDense: true,
        filled: true,
        constraints: null, // BoxConstraints(maxHeight: 42, minHeight: 40),
        fillColor: colorScheme.surfaceContainerLow,
        // prefixIconConstraints: BoxConstraints(maxHeight: 50.0, maxWidth: 40.0),
        // suffixIconConstraints: BoxConstraints(maxHeight: 40.0, maxWidth: 40.0),
        border: OutlineInputBorder(
          borderRadius: Radiuses.xsmallAll,
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 0.50),
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surfaceContainer,
        textStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  static ThemeData of(BuildContext context) {
    return Theme.of(context);
  }
}
