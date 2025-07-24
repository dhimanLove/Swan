import 'package:flutter/material.dart';

class PpTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    fontFamily: 'Helvetica Neue',
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFE60023),
      secondary: Color(0xFF767676),
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onSurface: Colors.black87,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0.5,
      iconTheme: IconThemeData(color: Color(0xFF767676)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1F1F1F),
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Helvetica Neue',
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF767676)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFFE60023),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: 'Helvetica Neue',
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE60023),
      secondary: Color(0xFFAAAAAA),
      surface: Color(0xFF1F1F1F),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      ),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF1F1F1F),
      elevation: 2,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF000000),
      elevation: 0.5,
      iconTheme: IconThemeData(color: Colors.white70),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Helvetica Neue',
      ),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFFE60023),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
