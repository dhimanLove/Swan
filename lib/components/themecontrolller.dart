import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  ThemeMode themeMode = ThemeMode.system; // 🌙 Use system theme by default

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  void toggleTheme() {
    themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    update();
  }

  void setSystemTheme() {
    themeMode = ThemeMode.system;
    update();
  }
}
