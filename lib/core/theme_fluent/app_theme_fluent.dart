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
    final resurces = _buildResources(colors, brightness);
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
      inactiveBackgroundColor: colors.outlineVariant,
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
      resources: resurces,

      navigationPaneTheme: NavigationPaneThemeData.fromResources(
        resources: resurces,
        animationCurve: standardCurve,
        animationDuration: const Duration(milliseconds: 167),
        highlightColor: colors.primary,
        typography: colors.typography,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      iconTheme: IconThemeData(
        color: colors.onSurfaceVariant,

      )
    );
  }

  static ResourceDictionary _buildResources(AppStyle colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final builder = isDark ? ResourceDictionary.dark : ResourceDictionary.light;

    return builder(
      // --- 1. نصوص الواجهة (Text Fill Colors) ---
      textFillColorPrimary: colors.onSurface,
      textFillColorSecondary: colors.onSurfaceVariant,
      textFillColorTertiary: colors.onSurfaceVariant.withValues(alpha: 0.7),
      textFillColorDisabled: colors.onSurface.withValues(alpha: 0.36),
      textFillColorInverse: colors.surfaceContainerLowest,
      accentTextFillColorDisabled: colors.onSurface.withValues(alpha: 0.36),


      // نصوص على الألوان التوكيدية (Accent)
      textOnAccentFillColorPrimary: colors.onPrimary,
      textOnAccentFillColorSecondary: colors.onPrimary.withValues(alpha: 0.8),
      textOnAccentFillColorDisabled: colors.onPrimary.withValues(alpha: 0.4),
      textOnAccentFillColorSelectedText: colors.onPrimary,

      // --- 2. تعبئة عناصر التحكم (Control Fill Colors) ---
      controlFillColorDefault: colors.surface,
      controlFillColorSecondary: colors.surfaceContainerHigh,
      controlFillColorTertiary: colors.surfaceContainerHighest,
      controlFillColorQuarternary:
          colors.surfaceContainerHighest.withValues(alpha: 0.8),
      controlFillColorDisabled: colors.surfaceContainerLow.withValues(alpha: 0.5),
      controlFillColorTransparent: Colors.transparent,
      controlFillColorInputActive: colors.surfaceContainer,

      // عناصر التحكم القوية (مثل أزرار الانتقال)
      controlStrongFillColorDefault: colors.outlineVariant,
      controlStrongFillColorDisabled:
          colors.outlineVariant.withValues(alpha: 0.3),
      controlSolidFillColorDefault: colors.surfaceContainerHighest,

      // الألوان الخفيفة (Subtle) للتفاعل مثل Hover/Press
      subtleFillColorTransparent: colors.surfaceContainer,
      subtleFillColorSecondary: colors.surfaceContainerHighest,
      subtleFillColorTertiary: colors.surfaceContainerHigh,
      subtleFillColorDisabled: colors.surfaceContainerHigh.withValues(alpha: 0.50),


      // الألوان البديلة (Alt)
      controlAltFillColorTransparent: colors.onSurfaceVariant,
      controlAltFillColorSecondary: colors.surfaceContainerLow,
      controlAltFillColorTertiary: colors.surfaceContainer,
      controlAltFillColorQuarternary: colors.surfaceContainerHigh,
      controlAltFillColorDisabled: Colors.transparent,

      // التحكم فوق الصور
      controlOnImageFillColorDefault: colors.surfaceContainerHigh,
      controlOnImageFillColorSecondary:
          isDark ? const Color(0xFF1a1a1a) : const Color(0xFFf3f3f3),
      controlOnImageFillColorTertiary:
          isDark ? const Color(0xFF131313) : const Color(0xFFebebeb),
      controlOnImageFillColorDisabled:
          isDark ? const Color(0xFF1e1e1e) : Colors.transparent,
      accentFillColorDisabled: colors.primary.withValues(alpha: 0.2),

      // --- 3. حدود العناصر (Stroke Colors) ---
      controlStrokeColorDefault: colors.outlineVariant,
      controlStrokeColorSecondary: colors.outline,
      controlStrokeColorOnAccentDefault:
          colors.onPrimary.withValues(alpha: 0.1),
      controlStrokeColorOnAccentSecondary:
          colors.onPrimary.withValues(alpha: 0.2),
      controlStrokeColorOnAccentTertiary:
          colors.onPrimary.withValues(alpha: 0.4),
      controlStrokeColorOnAccentDisabled:
          colors.onPrimary.withValues(alpha: 0.1),
      controlStrokeColorForStrongFillWhenOnImage: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : Colors.white.withValues(alpha: 0.3),

      cardStrokeColorDefault: colors.outlineVariant.withValues(alpha: 0.5),
      cardStrokeColorDefaultSolid: colors.outlineVariant,
      controlStrongStrokeColorDefault: colors.outline,
      controlStrongStrokeColorDisabled: colors.outline.withValues(alpha: 0.3),
      surfaceStrokeColorDefault: colors.outlineVariant,
      surfaceStrokeColorFlyout: colors.outline,
      surfaceStrokeColorInverse: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
      dividerStrokeColorDefault: colors.outlineVariant,

      // التباين العالي للتركيز (Focus)
      focusStrokeColorOuter: colors.primary,
      focusStrokeColorInner: colors.onPrimary,

      // --- 4. البطاقات والطبقات (Card & Layer Backgrounds) ---
      cardBackgroundFillColorDefault: colors.surfaceContainerHigh,
      cardBackgroundFillColorSecondary: colors.surfaceContainerHighest,
      cardBackgroundFillColorTertiary: colors.surfaceContainer,
      smokeFillColorDefault: colors.onSurfaceVariant,

      layerFillColorDefault: colors.surfaceContainerLow.withValues(alpha: 0.5),
      layerFillColorAlt: colors.surfaceContainerLow,
      layerOnAcrylicFillColorDefault:
          colors.surfaceContainer.withValues(alpha: 0.2),
      layerOnAccentAcrylicFillColorDefault:
          colors.primary.withValues(alpha: 0.2),

      // طبقات الميكا (Mica)
      layerOnMicaBaseAltFillColorDefault:
          colors.surfaceContainerLow.withValues(alpha: 0.7),
      layerOnMicaBaseAltFillColorSecondary:
          colors.surfaceContainer.withValues(alpha: 0.1),
      layerOnMicaBaseAltFillColorTertiary: colors.surfaceContainerHigh,
      layerOnMicaBaseAltFillColorTransparent: Colors.transparent,

      // --- 5. الخلفيات الصلبة (Solid Backgrounds) ---
      solidBackgroundFillColorBase: colors.surface,
      solidBackgroundFillColorSecondary: colors.surfaceContainerLow,
      solidBackgroundFillColorTertiary: colors.surfaceContainer,
      solidBackgroundFillColorQuarternary: colors.surfaceContainerHigh,
      solidBackgroundFillColorQuinary: colors.surfaceContainerHighest,
      solidBackgroundFillColorSenary: colors.surfaceContainerHighest,
      solidBackgroundFillColorTransparent: Colors.transparent,
      solidBackgroundFillColorBaseAlt: colors.surfaceContainerLowest,

      // --- 6. ألوان النظام والحالات (System & Status) ---
      systemFillColorSuccess: colors.success,
      systemFillColorCaution: colors.info,
      systemFillColorCritical: colors.error,
      systemFillColorNeutral: colors.onSurfaceVariant,
      systemFillColorSolidNeutral: colors.onSurfaceVariant,

      systemFillColorAttentionBackground: colors.surfaceContainerLow,
      systemFillColorSuccessBackground: colors.successContainer,
      systemFillColorCautionBackground: colors.infoContainer,
      systemFillColorCriticalBackground: colors.errorContainer,
      systemFillColorNeutralBackground: colors.surfaceContainer,
      systemFillColorSolidAttentionBackground: colors.surfaceContainerHigh,
      systemFillColorSolidNeutralBackground: colors.surfaceContainerLow,


    );
  }

  static FluentThemeData of(BuildContext context) {
    return FluentTheme.of(context);
  }
}
