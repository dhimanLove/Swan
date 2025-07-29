import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pinterest/Auth/signup.dart';
import 'package:pinterest/Pages/homescreen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final List<Map<String, String>> _pages = [
    {
      'title': 'Connect & Share',
      'description':
          'Discover amazing content, connect with friends, and share your moments.',
      'type': 'asset',
      'animation': 'Assets/Cat Movement.json',
    },
    {
      'title': 'Discover More',
      'description':
          'Explore a world of ideas and inspiration tailored to you.',
      'type': 'network',
      'animation':
          'https://lottie.host/ab3c34ff-dc3c-4c90-8d8e-d7e13aa0b1e7/XnT3H4.json',
    },
    {
      'title': 'Join the Community',
      'description': 'Be part of a vibrant community and make new connections.',
      'type': 'network',
      'animation':
          'https://lottie.host/5e9f82ae-b07e-4cbd-8c53-52b3454c44b7/hhUSGl.json',
    },
  ];
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueAccent],
            stops: [0.0, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged:
                      (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      title: _pages[index]['title']!,
                      description: _pages[index]['description']!,
                      animationAsset: _pages[index]['animation']!,
                      screenHeight: screenHeight,
                      textTheme: textTheme,
                      colorScheme: colorScheme,
                    );
                  },
                ),
              ),
              Expanded(
                flex: 2,
                child: BottomSection(
                  currentPage: _currentPage,
                  totalPages: _pages.length,
                  onGetStarted: () => Get.off(HomePage()),
                  onSignIn: () => Get.to(Signup()),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String animationAsset;
  final double screenHeight;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.animationAsset,
    required this.screenHeight,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            animationAsset,
            height: screenHeight * 0.35,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              description,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                height: 1.5,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const BottomSection({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onGetStarted,
    required this.onSignIn,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SmoothPageIndicator(
            controller: PageController(initialPage: currentPage),
            count: totalPages,
            effect: WormEffect(
              dotColor: Colors.white.withOpacity(0.3),
              activeDotColor: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onSignIn,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text(
              "I already have an account",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "By continuing, you agree to our Terms of Service and Privacy Policy",
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
