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
      iconTheme: IconThemeData(color: colors.onSurfaceVariant),
    );
  }

  static ResourceDictionary _buildResources(
    AppStyle colors,
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    final builder = isDark ? ResourceDictionary.dark : ResourceDictionary.light;

    return builder(
      // --- 1. نصوص الواجهة (Text Fill Colors) ---
      // النص الأساسي في التطبيق. يُستخدم للنصوص العادية والعناوين، وهو اللون ذو التباين الأعلى مع الخلفية (مثلاً: أسود على أبيض).
      textFillColorPrimary: colors.onSurface,

      // النص الثانوي. يُستخدم للنصوص الفرعية أو الوصف الذي يحتاج أهمية أقل وتركيزاً بصرياً أقل من النص الأساسي (مثلاً: الرمادي).
      textFillColorSecondary: colors.onSurfaceVariant,

      // النص الثالثي (الأقل أهمية). يُستخدم للنصوص غير الهامة جداً مثل التلميحات (Hints) أو النصوص الإرشادية المخففة.
      textFillColorTertiary: colors.onSurfaceVariant.withValues(alpha: 0.7),

      // لون النص المعطل (Disabled). يُستخدم عندما يكون العنصر (مثل زر أو حقل إدخال) غير قابل للتفاعل.
      textFillColorDisabled: colors.onSurface.withValues(alpha: 0.36),

      // لون النص المعكوس. يُستخدم للنصوص التي تظهر فوق خلفيات داكنة جداً في الوضع الفاتح، أو خلفيات فاتحة جداً في الوضع الداكن.
      textFillColorInverse: colors.surfaceContainerLowest,

      // لون النص المعطل فوق الألوان التوكيدية (Accent).
      accentTextFillColorDisabled: colors.onSurface.withValues(alpha: 0.36),

      // نصوص على الألوان التوكيدية (Accent)
      // النص الأساسي فوق العناصر التي تمتلك خلفية بلون التوكيد (Primary). (مثلاً: نص "تأكيد" باللون الأبيض فوق زر أزرق).
      textOnAccentFillColorPrimary: colors.onPrimary,

      // النص الثانوي فوق خلفيات التوكيد. يُستخدم لتخفيف بروز النص قليلاً.
      textOnAccentFillColorSecondary: colors.onPrimary.withValues(alpha: 0.8),

      // لون النص المعطل فوق خلفيات التوكيد.
      textOnAccentFillColorDisabled: colors.onPrimary.withValues(alpha: 0.4),

      // النص المظلل أو المحدد (Selected text). يُستخدم عند تظليل النص للنسخ مثلاً فوق خلفية ملونة.
      textOnAccentFillColorSelectedText: colors.onPrimary,

      // --- 2. تعبئة عناصر التحكم (Control Fill Colors) ---
      // اللون الافتراضي لتعبئة عناصر التحكم (مثل الأزرار العادية، أو خلفيات حقول الإدخال غير المفعلة).
      controlFillColorDefault: colors.surface,
      // اللون الثانوي لتعبئة عناصر التحكم. يُستخدم غالباً لتمثيل حالة التمرير (Hover) أو للتمييز البسيط بين العناصر المتجاورة.
      controlFillColorSecondary: colors.surfaceContainerHigh,
      // اللون الثالث لتعبئة عناصر التحكم. يُستخدم غالباً عند الضغط (Pressed) على العنصر.
      controlFillColorTertiary: colors.surfaceContainerHighest,

      // اللون الرابع لعناصر التحكم. يُستخدم في حالات محددة أو لزيادة التباين البصري عن المستوى الثالث.
      controlFillColorQuarternary: colors.surfaceContainerHighest.withValues(
        alpha: 0.8,
      ),

      // لون تعبئة العنصر عندما يكون معطلاً (Disabled).
      controlFillColorDisabled: colors.surfaceContainerLow.withValues(
        alpha: 0.5,
      ),

      // تعبئة شفافة بالكامل. تُستخدم للعناصر التي لا يجب أن تمتلك خلفية افتراضياً حتى يتم التفاعل معها.
      controlFillColorTransparent: Colors.transparent,

      // لون حقل الإدخال (TextField) عندما يكون نشطاً (Focused).
      controlFillColorInputActive: colors.surfaceContainer,

      // عناصر التحكم القوية (مثل أزرار الانتقال)
      // لون التحكم القوي الافتراضي. يُستخدم كخلفية للمسارات الدائمة (مثل مسار شريط التمرير أو مفتاح التبديل Toggle Switch في حالته المغلقة).
      controlStrongFillColorDefault: colors.outline,

      // لون التحكم القوي عندما يكون معطلاً.
      controlStrongFillColorDisabled: colors.outlineVariant.withValues(
        alpha: 0.3,
      ),

      // تعبئة قوية وصلبة (Solid). تُستخدم لعناصر التحكم البارزة جداً.
      controlSolidFillColorDefault: colors.surfaceContainerHighest,

      // الألوان الخفيفة (Subtle) للتفاعل مثل Hover/Press
      // لون شفاف خفيف. يُستخدم كحالة افتراضية للعناصر الشفافة (مثل ListTiles).
      subtleFillColorTransparent: Colors.transparent,
      // اللون الخفيف الثانوي. يُستخدم عادةً عند تمرير الماوس (Hover) على عنصر خفي أو شفاف في الأصل.
      subtleFillColorSecondary: colors.surfaceContainerLow,
      // اللون الخفيف الثالث. يُستخدم عادةً عند الضغط (Pressed) على العنصر الشفاف.
      subtleFillColorTertiary: colors.surfaceContainer,
      // اللون الخفيف المعطل. يجب أن يكون شفافاً لعدم إظهار أي تفاعل.
      subtleFillColorDisabled: Colors.transparent,

      // الألوان البديلة (Alt)
      // تستخدم الألوان البديلة كبديل (Fallback) لعناصر التحكم عند عدم تطابق الألوان الأساسية. هنا الحالة الشفافة.
      controlAltFillColorTransparent: Colors.transparent,
      // اللون البديل الثانوي (للـ Hover).
      controlAltFillColorSecondary: colors.surfaceContainerLow,
      // اللون البديل الثالث (للـ Pressed).
      controlAltFillColorTertiary: colors.surfaceContainer,
      // اللون البديل الرابع.
      controlAltFillColorQuarternary: colors.surfaceContainerHigh,
      // اللون البديل المعطل.
      controlAltFillColorDisabled: Colors.transparent,

      // التحكم فوق الصور
      // لون خلفية عناصر التحكم (مثل الأزرار) عند وضعها فوق صورة لضمان التباين وقابلية القراءة.
      controlOnImageFillColorDefault: colors.surfaceContainerHigh,
      // لون خلفية عناصر التحكم فوق الصورة (الحالة الثانوية/Hover).
      controlOnImageFillColorSecondary: isDark
          ? const Color(0xFF1a1a1a)
          : const Color(0xFFf3f3f3),
      // لون خلفية عناصر التحكم فوق الصورة (الحالة الثالثة/Pressed).
      controlOnImageFillColorTertiary: isDark
          ? const Color(0xFF131313)
          : const Color(0xFFebebeb),
      // لون تعبئة العنصر فوق الصورة عندما يكون معطلاً.
      controlOnImageFillColorDisabled: isDark
          ? const Color(0xFF1e1e1e)
          : Colors.transparent,
      // لون التعبئة التوكيدي (Accent) المعطل.
      accentFillColorDisabled: colors.primary.withValues(alpha: 0.2),

      // --- 3. حدود العناصر (Stroke Colors) ---
      // اللون الافتراضي لحدود (Border) عناصر التحكم مثل حقول الإدخال أو الأزرار.
      controlStrokeColorDefault: colors.outlineVariant,
      // اللون الثانوي للحدود. يُستخدم للحدود الأكثر وضوحاً أو عند تفاعل المستخدم معها (Hover).
      controlStrokeColorSecondary: colors.outline,
      // لون الحدود لعنصر التحكم الموجود فوق خلفية توكيدية (Accent).
      controlStrokeColorOnAccentDefault: colors.onPrimary.withValues(
        alpha: 0.1,
      ),
      // لون الحدود الثانوي لعنصر فوق خلفية توكيدية (مثل الضغط).
      controlStrokeColorOnAccentSecondary: colors.onPrimary.withValues(
        alpha: 0.2,
      ),
      // لون الحدود الثالث لعنصر فوق خلفية توكيدية.
      controlStrokeColorOnAccentTertiary: colors.onPrimary.withValues(
        alpha: 0.4,
      ),
      // لون الحدود لعنصر معطل فوق خلفية توكيدية.
      controlStrokeColorOnAccentDisabled: colors.onPrimary.withValues(
        alpha: 0.1,
      ),
      // حدود العناصر القوية الموجودة فوق صورة لتوفير تباين كافٍ.
      controlStrokeColorForStrongFillWhenOnImage: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : Colors.white.withValues(alpha: 0.3),

      // حدود البطاقات (Cards) في الواجهة. يُستخدم لإبراز حافة البطاقة وفصلها عن الخلفية.
      cardStrokeColorDefault: colors.outlineVariant.withValues(alpha: 0.5),
      // الحدود الصلبة الافتراضية للبطاقة.
      cardStrokeColorDefaultSolid: colors.outlineVariant,
      // حدود قوية وبارزة. تستخدم للعناصر التي تحتاج تحديداً أقوى.
      controlStrongStrokeColorDefault: colors.outline,
      // حدود قوية معطلة.
      controlStrongStrokeColorDisabled: colors.outline.withValues(alpha: 0.3),
      // حدود المسطحات أو الطبقات الكبيرة.
      surfaceStrokeColorDefault: colors.outlineVariant,
      // حدود القوائم المنسدلة (Flyouts/Popups).
      surfaceStrokeColorFlyout: colors.outline,
      // حدود المسطحات المعكوسة (الداكنة في الفاتح والعكس).
      surfaceStrokeColorInverse: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
      // الفواصل الخطية (Dividers) بين العناصر والقوائم.
      dividerStrokeColorDefault: colors.outlineVariant,

      // التباين العالي للتركيز (Focus)
      // لون الإطار الخارجي لحلقة التركيز (Focus Ring) التي تظهر عند التنقل بلوحة المفاتيح (Tab).
      focusStrokeColorOuter: colors.primary,
      // لون الإطار الداخلي لحلقة التركيز، للتباين مع اللون الخارجي.
      focusStrokeColorInner: colors.onPrimary,

      // --- 4. البطاقات والطبقات (Card & Layer Backgrounds) ---
      // اللون الأساسي لخلفية البطاقات (Cards). يُستخدم للبطاقات المرتفعة قليلاً عن الخلفية الأم.
      cardBackgroundFillColorDefault: colors.surfaceContainerHigh,
      // اللون الثانوي للبطاقات، يُستخدم عند الحاجة إلى طبقة أو ارتفاع مختلف للبطاقة.
      cardBackgroundFillColorSecondary: colors.surfaceContainerHighest,
      // اللون الثالث للبطاقات، لحالات التمييز.
      cardBackgroundFillColorTertiary: colors.surfaceContainer,
      // لون الظل الدخاني (Backdrop/Smoke) الذي يظهر خلف النوافذ المنبثقة (Dialogs) للتركيز عليها وتعتيم باقي التطبيق.
      smokeFillColorDefault: colors.surfaceScrim,

      // خلفية الطبقات (Layers) الافتراضية، تستخدم في تجميع المحتوى أو الحاويات.
      layerFillColorDefault: colors.surfaceContainerLow.withValues(alpha: 0.5),
      // خلفية بديلة للطبقات لزيادة التباين.
      layerFillColorAlt: colors.surfaceContainerLow,
      // لون الطبقات التي توضع فوق خامات الـ Acrylic (الشفافة).
      layerOnAcrylicFillColorDefault: colors.surfaceContainer.withValues(
        alpha: 0.2,
      ),
      // لون الطبقات التي توضع فوق خامات الأكريليك الملونة بلون الـ Accent.
      layerOnAccentAcrylicFillColorDefault: colors.primary.withValues(
        alpha: 0.2,
      ),

      // طبقات الميكا (Mica) - وهي المادة التي تمزج ألوان الشاشة بالخلفية
      // لون الطبقة الأساسية المعتمة الموضوعة على الميكا.
      layerOnMicaBaseAltFillColorDefault: colors.surfaceContainerLow.withValues(
        alpha: 0.7,
      ),
      // اللون الثانوي للطبقة فوق الميكا.
      layerOnMicaBaseAltFillColorSecondary: colors.surfaceContainer.withValues(
        alpha: 0.1,
      ),
      // اللون الثالث للطبقة فوق الميكا.
      layerOnMicaBaseAltFillColorTertiary: colors.surfaceContainerHigh,
      // الطبقة الشفافة بالكامل الموضوعة على الميكا.
      layerOnMicaBaseAltFillColorTransparent: Colors.transparent,

      // --- 5. الخلفيات الصلبة (Solid Backgrounds) ---
      // لون الخلفية الأولي الصلب (مثلاً: خلفية التطبيق الرئيسية).
      solidBackgroundFillColorBase: colors.surface,
      // لون الخلفية الصلب الثانوي (لصفحات فرعية أو أجزاء مجمعة).
      solidBackgroundFillColorSecondary: colors.surfaceContainerLow,
      // لون الخلفية الثالثي.
      solidBackgroundFillColorTertiary: colors.surfaceContainer,
      // لون الخلفية الرباعي، للتباين المتدرج.
      solidBackgroundFillColorQuarternary: colors.surfaceContainerHigh,
      // التدرج الخامس من الخلفية.
      solidBackgroundFillColorQuinary: colors.surfaceContainerHighest,
      // التدرج السادس.
      solidBackgroundFillColorSenary: colors.surfaceContainerHighest,
      // خلفية صلبة وشفافة (لا لون لها).
      solidBackgroundFillColorTransparent: Colors.transparent,
      // خلفية أولية بديلة للأساس.
      solidBackgroundFillColorBaseAlt: colors.surfaceContainerLowest,

      // --- 6. ألوان النظام والحالات (System & Status) ---
      // لون رسائل وحالات النجاح (Success) مثل إشعارات الحفظ بنجاح أو العلامات الخضراء.
      systemFillColorSuccess: colors.success,
      // لون رسائل الحذر والتنبيهات المعلوماتية (Info/Caution).
      systemFillColorCaution: colors.info,
      // لون الأخطاء والأمور الحرجة (Error/Critical) مثل رسائل الحذف العنيف أو الخطأ.
      systemFillColorCritical: colors.error,
      // اللون المحايد للحالات القياسية (Neutral).
      systemFillColorNeutral: colors.onSurfaceVariant,
      // اللون المحايد الصلب.
      systemFillColorSolidNeutral: colors.onSurfaceVariant,

      // خلفية الإشعارات/النوافذ التي تطلب لفت الانتباه.
      systemFillColorAttentionBackground: colors.surfaceContainerLow,
      // خلفية رسائل النجاح (الخضراء الفاتحة/الشفافة قليلاً).
      systemFillColorSuccessBackground: colors.successContainer,
      // خلفية رسائل التحذير (الصفراء/الزرقاء).
      systemFillColorCautionBackground: colors.infoContainer,
      // خلفية رسائل الأخطاء (الحمراء).
      systemFillColorCriticalBackground: colors.errorContainer,
      // خلفية رسائل النظام العادية أو المحايدة.
      systemFillColorNeutralBackground: colors.surfaceContainer,
      // خلفيات الانتباه الصلبة وغير الشفافة.
      systemFillColorSolidAttentionBackground: colors.surfaceContainerHigh,
      // الخلفية المحايدة الصلبة.
      systemFillColorSolidNeutralBackground: colors.surfaceContainerLow,
    );
  }

  static FluentThemeData of(BuildContext context) {
    return FluentTheme.of(context);
  }
}
