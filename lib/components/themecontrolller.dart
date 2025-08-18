import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  final _storage = GetStorage();
  final _key = 'theme_mode'; 

  ThemeMode themeMode = ThemeMode.system;

  @override
  void onInit() {
    super.onInit();
    String? stored = _storage.read<String>(_key);
    if (stored != null) {
      switch (stored) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          themeMode = ThemeMode.system;
          break;
      }
    }
  }

  /// Whether current effective theme is dark considering system setting
  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  /// Toggle light/dark only; system mode treated as dark for toggle purposes
  void toggleTheme() {
    if (themeMode == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }

  /// Set theme mode explicitly and persist it
  void setTheme(ThemeMode mode) {
    themeMode = mode;
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
      default:
        value = 'system';
        break;
    }
    _storage.write(_key, value);
    update();
  }
}
