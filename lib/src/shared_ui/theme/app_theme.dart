import 'package:flutter/material.dart';

final class AppTheme {
  const AppTheme._();

  static const Color _seedColor = Color(0xFFFF6600);

  static ThemeData light() => _build(.light);

  static ThemeData dark() => _build(.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme colorScheme = .fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    final ThemeData base = ThemeData(colorScheme: colorScheme);
    final TextTheme textTheme = base.textTheme.copyWith(
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: .w500,
        height: 1.3,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontFeatures: const <FontFeature>[.tabularFigures()],
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        isDense: true,
        contentPadding: const .symmetric(vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: .all(.circular(28)),
          borderSide: .none,
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: textTheme.titleMedium,
        leadingAndTrailingTextStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
        ),
        minLeadingWidth: 32,
        titleAlignment: .center,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 0.5,
        space: 1,
        indent: 16,
        endIndent: 16,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 2,
        margin: .zero,
        clipBehavior: .antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: .all(.circular(16)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        strokeCap: .round,
      ),
    );
  }
}
