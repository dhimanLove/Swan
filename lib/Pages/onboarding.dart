import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pinterest/Auth/login.dart';
import 'package:pinterest/Auth/signup.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController pageController = PageController();
  final List<Map<String, String>> pages = [
    {
      'title': 'Interest',
      'description':
          'Swagat nahi karoge hamara?\nBas app kholo aur chill maro!',
      'type': 'asset',
      'animation': 'Assets/Cat Movement.json',
    },
    {
      'title': 'Scene Check ',
      'description': 'Tere vibe ka full setup ready hai \n - dekh lo zara!',
      'type': 'asset',
      'animation': 'Assets/Brown Bear.json',
    },
    {
      'title': 'Vibe Milegi ',
      'description': 'Apne log, apni vibe \n bas tu hi missing tha!',
      'type': 'asset',
      'animation': 'Assets/Dance cat.json',
    },
  ];

  int currentPage = 0;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget buildLottieOrImage(String type, String path, double height) {
    if (path.endsWith('.json')) {
      return Lottie.asset(
        path,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red);
        },
      );
    } else {
      return Image.asset(
        path,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red);
        },
      );
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder:
          (_) => CupertinoAlertDialog(
            title: const Text("Oops!"),
            content: Text(
              message,
              style: const TextStyle(fontFamily: "Chillax"),
            ),

            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => currentPage = index),
                itemBuilder: (context, index) {
                  final item = pages[index];
                  final isNetworkImage = item['type'] == 'network';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: buildLottieOrImage(
                            item['type']!,
                            item['animation']!,
                            isNetworkImage && (index == 1 || index == 2)
                                ? screenHeight * 0.30
                                : screenHeight * 0.30,
                          ),
                        ),

                        const SizedBox(height: 30),
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .navLargeTitleTextStyle
                              .copyWith(color: Colors.white,fontFamily: "Chillax",fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Chillax",
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: BottomControls(
                controller: pageController,
                currentPage: currentPage,
                totalPages: pages.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomControls extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final int totalPages;

  const BottomControls({
    super.key,
    required this.controller,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        children: [
          SmoothPageIndicator(
            controller: controller,
            count: totalPages,
            effect: const WormEffect(
              dotColor: Colors.white30,
              activeDotColor: CupertinoColors.systemRed,
              dotHeight: 15,
              dotWidth: 15,
              spacing: 20,
            ),
          ),
          const SizedBox(height: 30),
          Hero(
            tag: "login",
            child: CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
              borderRadius: BorderRadius.circular(20),
              child: Text(
                isLast ? "Get Started" : "Next",
                style: const TextStyle(fontSize: 18, fontFamily: "Chillax"),
              ),
              onPressed: () {
                if (isLast) {
                  Get.to(
                    () => const Signup(),
                    transition: Transition.cupertinoDialog,
                  );
                } else {
                  controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
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
                  TextSpan(text: "Already have an account? "),
                  TextSpan(
                    text: "Login",
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
    );
  }
}
