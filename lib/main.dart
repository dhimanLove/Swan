import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/components/bottomnav.dart';
import 'package:pinterest/components/pptheme.dart';
import 'package:pinterest/components/themecontrolller.dart';

void main() {
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pinterest Clone',
          theme: PpTheme.lightTheme,
          darkTheme: PpTheme.darkTheme,
          themeMode: ThemeMode.system, 
          home: const GoogleNav(),
        );
      },
    );
  }
}
