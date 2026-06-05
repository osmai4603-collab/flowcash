import 'package:flowcash/core/theme/paddings.dart';
import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flowcash/core/theme_fluent/color_scheme_fluent.dart';
import 'package:flowcash/core/theme_fluent/styles_fluent.dart';
import 'package:fluent_ui/fluent_ui.dart';

sealed class ThemesFluent {
  const ThemesFluent._();

  static FluentThemeData get light => _buildTheme(
    brightness: Brightness.light,
    accentColor: ColorSchemesFluent.lightAccent,
    backgroundColor: const Color(0xFFF5F5F5),
    cardColor: const Color(0xFFF0F0F0),
    secondaryColor: ColorSchemesFluent.lightSecondaryColor,
    tertiaryColor: ColorSchemesFluent.lightTertiaryColor,
  );

  static FluentThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    accentColor: ColorSchemesFluent.darkAccent,
    backgroundColor: const Color(0xFF1C1C1C),
    cardColor: const Color(0xFF242424),
    secondaryColor: ColorSchemesFluent.darkSecondaryColor,
    tertiaryColor: ColorSchemesFluent.darkTertiaryColor,
  );

  static FluentThemeData _buildTheme({
    required Brightness brightness,
    required AccentColor accentColor,
    required Color backgroundColor,
    required Color cardColor,
    required Color secondaryColor,
    required Color tertiaryColor,
  }) {
    return FluentThemeData(
      brightness: brightness,
      accentColor: accentColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      typography: StylesFluent.typography,
      menuColor: cardColor,
      activeColor: accentColor,
      dialogTheme: ContentDialogThemeData(
        decoration: ShapeDecoration(
          color: cardColor,
          shape: ContinuousRectangleBorder(
            side: BorderSide(color: accentColor, width: 1.0),
            borderRadius: Radiuses.largeAll,
          ),
        ),
        padding: Paddings.mediumAll,
      ),
      buttonTheme: ButtonThemeData(
        filledButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(accentColor),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          shape: WidgetStateProperty.all(
            ContinuousRectangleBorder(borderRadius: Radiuses.smallAll),
          ),
        ),
        outlinedButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(secondaryColor),
          foregroundColor: WidgetStateProperty.all(
            brightness == Brightness.light
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFECECEC),
          ),
          shape: WidgetStateProperty.all(
            ContinuousRectangleBorder(
              side: BorderSide(color: tertiaryColor, width: 1.50),
              borderRadius: Radiuses.smallAll,
            ),
          ),
          textStyle: WidgetStateProperty.all(
            StylesFluent.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        iconButtonStyle: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: Radiuses.smallAll,
              side: BorderSide.none,
            ),
          ),
        ),
      ),
      
      
    );
  }

  static FluentThemeData of(BuildContext context) {
    return FluentTheme.of(context);
  }
}
