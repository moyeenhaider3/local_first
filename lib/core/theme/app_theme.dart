import 'package:flutter/material.dart';
import 'package:local_first/core/theme/design_tokens.dart';

/// App theme definitions wrapping DesignTokens into Flutter ThemeData.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: DesignTokens.colorBgDark,
      colorScheme: const ColorScheme.light(
        primary: DesignTokens.colorPrimary,
        secondary: DesignTokens.colorSecondary,
        surface: DesignTokens.colorSurface,
        error: DesignTokens.colorDanger,
      ),
      textTheme: const TextTheme(
        displayLarge: DesignTokens.h1,
        headlineMedium: DesignTokens.h2,
        titleMedium: DesignTokens.titleMedium,
        bodyLarge: DesignTokens.bodyLarge,
        bodySmall: DesignTokens.bodySmall,
        labelLarge: DesignTokens.labelBold,
        labelSmall: DesignTokens.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignTokens.colorSurface,
        foregroundColor: DesignTokens.colorTextMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: DesignTokens.titleMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.colorPrimary,
          foregroundColor: DesignTokens.colorSurface,
          disabledBackgroundColor: DesignTokens.colorPrimary.withValues(alpha: 0.4),
          disabledForegroundColor: DesignTokens.colorSurface,
          textStyle: DesignTokens.labelBold,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size.fromHeight(DesignTokens.kTouchMin),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignTokens.colorPrimary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.colorSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.kSpace16,
          vertical: 12.0,
        ),
        hintStyle: DesignTokens.bodySmall,
        errorStyle: DesignTokens.caption.copyWith(color: DesignTokens.colorDanger),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.colorTextMuted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.colorTextMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.colorPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.colorDanger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DesignTokens.colorDanger, width: 2),
        ),
      ),
      extensions: [
        const AppSpacingExtension(),
      ],
    );
  }
}

/// Custom spacing theme extension to avoid hardcoding spacing values.
class AppSpacingExtension extends ThemeExtension<AppSpacingExtension> {
  final double space4 = DesignTokens.kSpace4;
  final double space8 = DesignTokens.kSpace8;
  final double space16 = DesignTokens.kSpace16;
  final double space24 = DesignTokens.kSpace24;
  final double space32 = DesignTokens.kSpace32;
  final double space48 = DesignTokens.kSpace48;
  final double edgeMargin = DesignTokens.kEdgeMargin;

  const AppSpacingExtension();

  @override
  ThemeExtension<AppSpacingExtension> copyWith() => this;

  @override
  ThemeExtension<AppSpacingExtension> lerp(
    covariant ThemeExtension<AppSpacingExtension>? other,
    double t,
  ) =>
      this;
}

/// Utility extension on BuildContext to quickly access theme spacing.
extension AppSpacingExtensionX on BuildContext {
  AppSpacingExtension get spacing => Theme.of(this).extension<AppSpacingExtension>()!;
}
