
import 'package:get/get.dart';
import 'package:pinterest/Pages/onboarding.dart';
import 'package:pinterest/Auth/login.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  static final List<GetPage> pages = [
    GetPage(name: onboarding, page: () => const Onboarding()),
    GetPage(name: login, page: () => const Login()),
  ];
}
