import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = 'isDarkMode';

  ThemeMode themeMode = ThemeMode.system;

  @override
  void onInit() {
    super.onInit();
    bool? isDark = _storage.read(_key);
    if (isDark != null) {
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  void toggleTheme() {
    isDarkMode ? _storage.write(_key, false) : _storage.write(_key, true);
    themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    update();
  }
}
