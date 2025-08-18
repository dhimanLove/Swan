import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pinterest/Auth/signup.dart';
import 'package:pinterest/components/bottomnav.dart';
import 'package:pinterest/components/pptheme.dart';
import 'package:pinterest/components/textfields.dart';

class LoginController extends GetxController {
  final supabaseClient = Supabase.instance.client;
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  RxBool isLoading = false.obs;

  Future<void> login(BuildContext context) async {
    final email = loginEmailController.text.trim();
    final password = loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showDialog(context, "Login Failed", "Email and password cannot be empty.");
      return;
    }

    try {
      isLoading.value = true;

      final AuthResponse res = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        Get.offAll(() => const GoogleNav());
      } else {
        _showDialog(context, "Login Failed", "Invalid login. Please try again.");
      }
    } on AuthException catch (e) {
      final errorMessage = e.message.contains("email not confirmed")
          ? "Your email is not confirmed. Try resetting your password or contact support."
          : e.message;
      _showDialog(context, "Login Failed", errorMessage);
    } catch (_) {
      _showDialog(context, "Login Failed", "Something went wrong. Try again.");
    } finally {
      isLoading.value = false;
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.onClose();
    
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    final scrh = MediaQuery.of(context).size.height;
    final scrw = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text(
          "Login",
          style: TextStyle(
            fontFamily: "Chillax",
            fontSize: 35,
            color: CupertinoColors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        backgroundColor: CupertinoColors.systemFill,
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'Assets/oldage.png',
                  height: scrh * 0.26,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 24),
                Text(
                  "Welcome Back",
                  style: PpTheme.darkTheme.textTheme.headlineLarge?.copyWith(
                    color: PpTheme.darkTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                AuthTextFields(
                  emailController: controller.loginEmailController,
                  passwordController: controller.loginPasswordController,
                  showUsernameField: false,
                ),
                const SizedBox(height: 24),
                Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: scrw * 0.4,
                      child: Hero(
                        tag: "login",
                        child: CupertinoButton.filled(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.login(context),
                          child: controller.isLoading.value
                              ? const CupertinoActivityIndicator(
                                  color: CupertinoColors.white,
                                  radius: 14,
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(fontFamily: "Chillax"),
                                ),
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Get.to(
                    () => const Signup(),
                    transition: Transition.cupertino,
                  ),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            fontFamily: "Chillax",
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
