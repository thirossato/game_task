import 'package:flutter/material.dart';

class ThemeController {
  static late ValueNotifier<ThemeData> themeNotifier;

  static void init(ThemeData initialTheme) {
    themeNotifier = ValueNotifier(initialTheme);
  }

  static void updateTheme(ThemeData theme) {
    themeNotifier.value = theme;
  }
}
