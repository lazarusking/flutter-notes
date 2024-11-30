import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Contains light and dark themes based on user-provided visuals.
class AppThemes {
  // Colors extracted from the images for both modes.
  static const Color lightPrimaryColor =
      Color(0xFF1E88E5); // Blue from light mode
  static const Color lightBackgroundColor =
      Color(0xFFF3F7FA); // Light grey/white

  // static const Color darkPrimaryColor =
  //     Color(0xFF121212); // Purple from dark mode
  static const Color darkPrimaryColor =
      Color(0xFF202124); // Purple from dark mode
  static const Color darkBackgroundColor =
      Color(0xFF202124); // Very dark grey/black

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFF5F5F5), // Background white tone
    scaffoldBackgroundColor: lightBackgroundColor,
    splashColor: Colors.transparent,
    // scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      color: lightBackgroundColor, // Match light background      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black87),
      systemOverlayStyle: SystemUiOverlayStyle
          .dark, // Ensures dark icons and text in the status bar

      // titleTextStyle: TextStyle(
      //   color: Colors.white,
      //   fontSize: 20,
      //   // fontWeight: FontWeight.bold,
      // ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: lightPrimaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: lightPrimaryColor,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black87),
      headlineSmall: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerColor: Colors.grey.shade300,
    inputDecorationTheme: const InputDecorationTheme(
      // filled: true,
      // fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.black54),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
    splashColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      color: darkPrimaryColor,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        // fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E), // Slightly lighter than the background
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: darkPrimaryColor,
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor:
          Color(0xFFBB86FC), // A lighter purple for better contrast
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.grey.shade200),
      bodySmall: TextStyle(color: Colors.grey.shade200),
      headlineSmall: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    dividerColor: Colors.grey.shade600,
    inputDecorationTheme: const InputDecorationTheme(
      // filled: true,
      // fillColor: Color(0xFF1E1E1E), // Matches the card theme
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        borderSide: BorderSide.none,
      ),
      // hintStyle: TextStyle(color: Colors.grey),
    ),
  );
}
