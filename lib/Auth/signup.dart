import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:pinterest/Auth/login.dart';
import 'package:pinterest/components/bottomnav.dart';
import 'package:pinterest/components/pptheme.dart';
import 'package:pinterest/components/textfields.dart';

class SignUpController extends GetxController {
  final supabaseClient = Supabase.instance.client;
  final signupUsernameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  RxBool isLoading = false.obs;

  Future<void> signup(BuildContext context) async {
    final email = signupEmailController.text.trim();
    final password = signupPasswordController.text;
    final username = signupUsernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: const Text("Signup Failed"),
              content: const Text("All fields must be filled."),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Get.back(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    }

    try {
      isLoading.value = true;

      showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => const CupertinoAlertDialog(
              content: CupertinoActivityIndicator(
                radius: 15,
                color: CupertinoColors.white,
              ),
            ),
      );

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': username},
      );
      Get.back();

      if (response.user != null) {
        Get.offAll(() => const GoogleNav());
      } else {
        showCupertinoDialog(
          context: context,
          builder:
              (_) => CupertinoAlertDialog(
                title: const Text("Signup Failed"),
                content: const Text("Something went wrong. Try again."),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () => Get.back(),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      Get.back(); 

      String errorMessage = "Something went wrong. Please try again.";

      if (e.toString().contains("User already registered") ||
          e.toString().contains("duplicate key")) {
        errorMessage = "This email is already registered.";
      } else if (e.toString().contains("Invalid login credentials")) {
        errorMessage = "Incorrect email or password.";
      } else if (e.toString().contains("network")) {
        errorMessage = "Please check your internet connection.";
      }

      showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: const Text("Signup Failed"),
              content: Text(errorMessage),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Get.back(),
                  child: const Text("OK"),
                ),
              ],
            ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    signupUsernameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    super.onClose();
  }
}

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.put(SignUpController());
    final scrh = MediaQuery.of(context).size.height;
    final scrw = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text(
          "Sign Up",
          style: TextStyle(
            fontFamily: "Chillax",
            fontSize: 35,
            color: CupertinoColors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        backgroundColor: CupertinoColors.black,
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset( 
                  'Assets/otter.png',
                  height: scrh * 0.26,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, color: Colors.red);
                  },
                  gaplessPlayback: true,
                ),
                const SizedBox(height: 24),
                Text(
                  "Create your account",
                  style: PpTheme.darkTheme.textTheme.headlineLarge?.copyWith(
                    color: PpTheme.darkTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
                AuthTextFields(
                  usernameController: controller.signupUsernameController,
                  emailController: controller.signupEmailController,
                  passwordController: controller.signupPasswordController,
                  showUsernameField: true,
                ),
                const SizedBox(height: 24),
                Hero(
                  tag: "login",
                  child: SizedBox(
                    width: scrw * 0.4,
                    child: Obx(
                      () => CupertinoButton.filled(
                        onPressed:
                            controller.isLoading.value
                                ? null
                                : () => controller.signup(context),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        borderRadius: BorderRadius.circular(20),
                        child:
                            controller.isLoading.value
                                ? const CupertinoActivityIndicator(
                                  color: CupertinoColors.white,
                                )
                                : const Text(
                                  "Sign Up",
                                  style: TextStyle(fontFamily: "Chillax"),
                                ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed:
                      () => Get.to(
                        () => const Login(),
                        transition: Transition.cupertino,
                      ),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      children: [
                        TextSpan(text: "Account Bana hua h ? "),
                        TextSpan(
                          text: "LogIn",
                          style: TextStyle(
                            fontFamily: "Chillax",
                            color: CupertinoColors.activeBlue,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.lineThrough,
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
