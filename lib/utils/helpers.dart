import 'package:flutter/material.dart';
import 'package:notes/app_themes.dart';

class Helpers {
  /// Calculates the number of items that can fit in the cross axis (e.g., number of columns in a grid).
  ///
  /// The calculation is based on the total number of items.
  ///
  /// - Parameter itemCount: The total number of items.
  /// - Returns: The number of items that can fit in the cross axis.
  static int calculateCrossAxisCount(int itemCount) {
    if (itemCount <= 2) return 1;
    if (itemCount <= 4) return 2;
    if (itemCount <= 6) return 3;
    return 4;
  }

  static double calculateChildAspectRatio(int itemCount) {
    if (itemCount <= 2) return 4 / 3;
    if (itemCount <= 4) return 3 / 2;
    if (itemCount <= 6) return 1;
    return 1;
  }

  /// Returns the default background color for the given [BuildContext].
  ///
  /// This method determines the appropriate background color based on the
  /// current theme and other context-specific factors.
  ///
  /// - Parameter context: The [BuildContext] to use for determining the
  ///   background color.
  /// - Returns: A [Color] object representing the default background color.
  static Color getDefaultBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppThemes.darkBackgroundColor
        : AppThemes.lightBackgroundColor;
  }
}
