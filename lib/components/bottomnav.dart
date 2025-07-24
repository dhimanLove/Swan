import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pinterest/Pages/homescreen.dart';
import 'package:pinterest/Pages/messages.dart';
import 'package:pinterest/Pages/post.dart';
import 'package:pinterest/Pages/profile.dart';
import 'package:pinterest/Pages/search.dart';

class GoogleNav extends StatefulWidget {
  const GoogleNav({super.key});

  @override
  State<GoogleNav> createState() => _GoogleNavState();
}

class _GoogleNavState extends State<GoogleNav> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    Homescreen(),
    Messages(),
    PostScreen(),
    SearchScreen(),
    CupertinoProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            backgroundColor: theme.colorScheme.surface,
            selectedIndex: _selectedIndex,
            gap: 8,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            tabBackgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            activeColor: theme.colorScheme.primary,
            color: theme.iconTheme.color,
            iconSize: 24,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
                _pageController.jumpToPage(index);
              });
            },
            tabs: const [
              GButton(icon: CupertinoIcons.home),
              GButton(icon: CupertinoIcons.chat_bubble),
              GButton(icon: CupertinoIcons.add_circled),
              GButton(icon: CupertinoIcons.search),
              GButton(icon: CupertinoIcons.person),
            ],
          ),
        ),
      ),
    );
  }
}
