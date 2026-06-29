import 'package:fluent_ui/fluent_ui.dart';

class AppStyle extends ThemeExtension<AppStyle> {
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color outlineVariant;
  final Color surfaceScrim;
  final Color surfaceShadow;

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color successOutline;
  final Color successOutlineVariant;

  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color errorOutline;
  final Color errorOutlineVariant;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color infoOutline;
  final Color infoOutlineVariant;

  AppStyle._({
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.surfaceScrim,
    required this.surfaceShadow,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.successOutline,
    required this.successOutlineVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.errorOutline,
    required this.errorOutlineVariant,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.infoOutline,
    required this.infoOutlineVariant,
  });

  static final AppStyle light = AppStyle._(
    surface: const Color(0xFFF4F6F9),
    onSurface: const Color(0xFF1A1D21),
    onSurfaceVariant: const Color(0xFF5C636A),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF7F9FC),
    surfaceContainer: const Color(0xFFF0F3F8),
    surfaceContainerHigh: const Color(0xFFE8ECF2),
    surfaceContainerHighest: const Color(0xFFDDE3EA),
    outline: const Color(0xFFAFB6C0),
    outlineVariant: const Color(0xFFC8CED5),
    surfaceScrim: const Color(0x66000000),
    surfaceShadow: const Color(0x33000000),
    primary: const Color(0xFF1565C0),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFE3F2FD),
    onPrimaryContainer: const Color(0xFF1E1E1E),
    success: const Color(0xFFC8E6C9),
    onSuccess: const Color(0xFF1B5E20),
    successContainer: const Color(0xFF81C784),
    onSuccessContainer: const Color(0xFF1E1E1E),
    successOutline: const Color(0xFFB0B0B0),
    successOutlineVariant: const Color(0xFFCFD0D1),
    error: const Color(0xFFB00020),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFCF6679),
    onErrorContainer: const Color(0xFF1E1E1E),
    errorOutline: const Color(0xFFB0B0B0),
    errorOutlineVariant: const Color(0xFFCFD0D1),
    info: const Color(0xFFE8F5E9),
    onInfo: const Color(0xFF1B5E20),
    infoContainer: const Color(0xFFB9F6CA),
    onInfoContainer: const Color(0xFF1B5E20),
    infoOutline: const Color(0xFFB0B0B0),
    infoOutlineVariant: const Color(0xFFCFD0D1),
  );

  static final AppStyle dark = AppStyle._(
    surface: const Color(0xFF1A1D24),
    onSurface: const Color(0xFFE6E9EE),
    onSurfaceVariant: const Color(0xFFA8ADB5),
    surfaceContainerLowest: const Color(0xFF0C0E12),
    surfaceContainerLow: const Color(0xFF14171D),
    surfaceContainer: const Color(0xFF20242B),
    surfaceContainerHigh: const Color(0xFF292E36),
    surfaceContainerHighest: const Color(0xFF333842),
    outline: const Color(0xFF6A707A),
    outlineVariant: const Color(0xFF464B53),
    surfaceScrim: const Color(0xCC000000),
    surfaceShadow: const Color(0x8A000000),
    primary: const Color(0xFF1565C0),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFF0D47A1),
    onPrimaryContainer: const Color(0xFFFFFFFF),
    success: const Color(0xFF1B5E20),
    onSuccess: const Color(0xFFFFFFFF),
    successContainer: const Color(0xFF2E7D32),
    onSuccessContainer: const Color(0xFFFFFFFF),
    successOutline: const Color(0xFF6E6E6E),
    successOutlineVariant: const Color(0xFF4A4A4A),
    error: const Color(0xFFB00020),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0x3DCF6679),
    onErrorContainer: const Color(0xFF1E1E1E),
    errorOutline: const Color(0xFF6E6E6E),
    errorOutlineVariant: const Color(0xFF4A4A4A),
    info: const Color(0xFF1976D2),
    onInfo: const Color(0xFFFFFFFF),
    infoContainer: const Color(0xFF0D47A1),
    onInfoContainer: const Color(0xFFFFFFFF),
    infoOutline: const Color(0xFF6E6E6E),
    infoOutlineVariant: const Color(0xFF4A4A4A),
  );

  @override
  AppStyle copyWith({
    Color? surface,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? surfaceOutline,
    Color? surfaceOutlineVariant,
    Color? surfaceScrim,
    Color? surfaceShadow,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? successOutline,
    Color? successOutlineVariant,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? errorOutline,
    Color? errorOutlineVariant,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? infoOutline,
    Color? infoOutlineVariant,
  }) {
    return AppStyle._(
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      outline: surfaceOutline ?? this.outline,
      outlineVariant: surfaceOutlineVariant ?? this.outlineVariant,
      surfaceScrim: surfaceScrim ?? this.surfaceScrim,
      surfaceShadow: surfaceShadow ?? this.surfaceShadow,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      successOutline: successOutline ?? this.successOutline,
      successOutlineVariant:
          successOutlineVariant ?? this.successOutlineVariant,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      errorOutline: errorOutline ?? this.errorOutline,
      errorOutlineVariant: errorOutlineVariant ?? this.errorOutlineVariant,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      infoOutline: infoOutline ?? this.infoOutline,
      infoOutlineVariant: infoOutlineVariant ?? this.infoOutlineVariant,
    );
  }

  @override
  AppStyle lerp(covariant ThemeExtension<AppStyle>? other, double t) {
    if (other is! AppStyle) {
      return this;
    }

    return AppStyle._(
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      onSurface: Color.lerp(onSurface, other.onSurface, t) ?? onSurface,
      onSurfaceVariant:
          Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t) ??
          onSurfaceVariant,
      surfaceContainerLowest:
          Color.lerp(surfaceContainerLowest, other.surfaceContainerLowest, t) ??
          surfaceContainerLowest,
      surfaceContainerLow:
          Color.lerp(surfaceContainerLow, other.surfaceContainerLow, t) ??
          surfaceContainerLow,
      surfaceContainer:
          Color.lerp(surfaceContainer, other.surfaceContainer, t) ??
          surfaceContainer,
      surfaceContainerHigh:
          Color.lerp(surfaceContainerHigh, other.surfaceContainerHigh, t) ??
          surfaceContainerHigh,
      surfaceContainerHighest:
          Color.lerp(
            surfaceContainerHighest,
            other.surfaceContainerHighest,
            t,
          ) ??
          surfaceContainerHighest,
      outline: Color.lerp(outline, other.outline, t) ?? outline,
      outlineVariant:
          Color.lerp(outlineVariant, other.outlineVariant, t) ?? outlineVariant,
      surfaceScrim:
          Color.lerp(surfaceScrim, other.surfaceScrim, t) ?? surfaceScrim,
      surfaceShadow:
          Color.lerp(surfaceShadow, other.surfaceShadow, t) ?? surfaceShadow,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t) ??
          primaryContainer,
      onPrimaryContainer:
          Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t) ??
          onPrimaryContainer,
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t) ??
          successContainer,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t) ??
          onSuccessContainer,
      successOutline:
          Color.lerp(successOutline, other.successOutline, t) ?? successOutline,
      successOutlineVariant:
          Color.lerp(successOutlineVariant, other.successOutlineVariant, t) ??
          successOutlineVariant,
      error: Color.lerp(error, other.error, t) ?? error,
      onError: Color.lerp(onError, other.onError, t) ?? onError,
      errorContainer:
          Color.lerp(errorContainer, other.errorContainer, t) ?? errorContainer,
      onErrorContainer:
          Color.lerp(onErrorContainer, other.onErrorContainer, t) ??
          onErrorContainer,
      errorOutline:
          Color.lerp(errorOutline, other.errorOutline, t) ?? errorOutline,
      errorOutlineVariant:
          Color.lerp(errorOutlineVariant, other.errorOutlineVariant, t) ??
          errorOutlineVariant,
      info: Color.lerp(info, other.info, t) ?? info,
      onInfo: Color.lerp(onInfo, other.onInfo, t) ?? onInfo,
      infoContainer:
          Color.lerp(infoContainer, other.infoContainer, t) ?? infoContainer,
      onInfoContainer:
          Color.lerp(onInfoContainer, other.onInfoContainer, t) ??
          onInfoContainer,
      infoOutline: Color.lerp(infoOutline, other.infoOutline, t) ?? infoOutline,
      infoOutlineVariant:
          Color.lerp(infoOutlineVariant, other.infoOutlineVariant, t) ??
          infoOutlineVariant,
    );
  }

  Typography? _typography;
  Typography get typography {
    return _typography ??= Typography.raw(
      display: TextStyle(
        fontSize: 68,
        height: 92 / 68,
        color: onSurface,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto_Naskh_Arabic',
      ),
      titleLarge: TextStyle(
        fontSize: 40,
        height: 52 / 40,
        color: onSurface,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto_Naskh_Arabic',
      ),
      title: TextStyle(
        fontSize: 28,
        height: 36 / 28,
        color: onSurface,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto_Naskh_Arabic',
      ),
      subtitle: TextStyle(
        fontSize: 20,
        height: 28 / 20,
        color: onSurfaceVariant,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto_Naskh_Arabic',
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        height: 24 / 18,
        color: onSurface,
        fontWeight: FontWeight.normal,
        fontFamily: 'Noto_Naskh_Arabic',
      ),
      bodyStrong: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        color: onSurface,
        fontWeight: FontWeight.w600,
        fontFamily: 'Noto_Naskh_Arabic',
      ),
      body: TextStyle(
        fontSize: 12,
        height: 18 / 12,
        color: onSurface,
        fontWeight: FontWeight.normal,
        fontFamily: 'Noto_Naskh_Arabic',
      ),
      caption: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        color: onSurface,
        fontWeight: FontWeight.w300,
        fontFamily: 'Noto_Naskh_Arabic',
      ),
    );
  }

  TextStyle get caption {
    return typography.caption!;
  }

  TextStyle get display {
    return typography.display!;
  }

  TextStyle get titleLarge {
    return typography.titleLarge!;
  }

  TextStyle get title {
    return typography.title!;
  }

  TextStyle get subTitle {
    return typography.subtitle!;
  }

  TextStyle get bodyLarge {
    return typography.bodyLarge!;
  }

  TextStyle get body {
    return typography.body!;
  }

  TextStyle get bodyStrong {
    return typography.bodyStrong!;
  }

  static AppStyle of(BuildContext context) {
    return FluentTheme.of(context).extension<AppStyle>()!;
  }
}
