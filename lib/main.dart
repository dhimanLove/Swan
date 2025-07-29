import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pinterest/Pages/homescreen.dart';
import 'package:pinterest/Pages/onboarding.dart';
import 'package:pinterest/components/bottomnav.dart';
import 'package:pinterest/components/themecontrolller.dart';
import 'package:pinterest/components/pptheme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  await GetStorage.init();
  Get.put(ThemeController());
  await Supabase.initialize(
    url: 'https://otojejsgathgnzpsghyq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90b2planNnYXRoZ256cHNnaHlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0MzI5NzgsImV4cCI6MjA2OTAwODk3OH0.837zMPqn8YXi25u8mcb_LdGGHrCcEmfehJHm7mUhXMo',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pinterest',
          theme: PpTheme.lightTheme,
          darkTheme: PpTheme.darkTheme,
          themeMode: controller.themeMode,
          home: const GoogleNav(),
        );
      },
    );
  }
}

// Session != null ? const GoogleNav() :