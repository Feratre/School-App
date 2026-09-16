import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const String disp = 'Oswald';
  static const String sans = 'IBM Plex Sans';

  static ThemeData get dark => _build(Brightness.dark, SchoolColors.dark);
  static ThemeData get light => _build(Brightness.light, SchoolColors.light);

  static ThemeData _build(Brightness brightness, SchoolColors sc) {
    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: sans,
    );
    return base.copyWith(
      scaffoldBackgroundColor: sc.bg,
      colorScheme: base.colorScheme.copyWith(
        surface: sc.bgRaised,
        primary: sc.accent,
        onPrimary: sc.onEmber,
        onSurface: sc.text,
        error: sc.danger,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: sans,
        bodyColor: sc.text,
        displayColor: sc.text,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      dividerColor: sc.border,
      extensions: [sc],
    );
  }

  static TextStyle d(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? letterSpacing,
    double height = 1.0,
  }) =>
      TextStyle(
        fontFamily: disp,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle s(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double height = 1.35,
  }) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
}
