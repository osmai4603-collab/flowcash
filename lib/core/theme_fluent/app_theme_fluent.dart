import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flowcash/core/theme_fluent/color_scheme_fluent.dart';
import 'package:fluent_ui/fluent_ui.dart';

sealed class ThemesFluent {
  const ThemesFluent._();

  static FluentThemeData get light =>
      _buildTheme(brightness: Brightness.light, colors: AppStyle.light);

  static FluentThemeData get dark =>
      _buildTheme(brightness: Brightness.dark, colors: AppStyle.dark);

  static FluentThemeData _buildTheme({
    required Brightness brightness,
    required AppStyle colors,
  }) {
    return FluentThemeData(fontFamily: 'Noto_Naskh_Arabic').copyWith(
      extensions: [colors],
      brightness: brightness,
      accentColor: ColorSchemesFluent.createAccentColor(colors.primary),
      scaffoldBackgroundColor: colors.surface,
      cardColor: colors.surfaceContainerHigh,
      typography: colors.typography,
      shadowColor: colors.surfaceShadow,
      inactiveColor: colors.onSurfaceVariant,
      acrylicBackgroundColor: colors.surfaceContainerHighest,
      inactiveBackgroundColor: colors.surfaceOutlineVariant,
      micaBackgroundColor: colors.surfaceContainerLowest,
      menuColor: colors.surfaceContainerHigh,

      activeColor: colors.primary,
      infoBarTheme: InfoBarThemeData(
        decoration: (info) => BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: Radiuses.xsmallAll,
        ),
        padding: Paddings.smallAll,
      ),

      dialogTheme: ContentDialogThemeData(
        decoration: ShapeDecoration(
          color: colors.surfaceContainerHigh,
          shape: ContinuousRectangleBorder(
            side: BorderSide(color: colors.primary, width: 1.0),
            borderRadius: Radiuses.mediumAll,
          ),
        ),
        actionsDecoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: Radiuses.xsmallAll,
        ),
        padding: Paddings.mediumAll,
      ),
    );
  }

  static FluentThemeData of(BuildContext context) {
    return FluentTheme.of(context);
  }
}
