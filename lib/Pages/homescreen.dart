import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/Pages/settings.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.search),
          onPressed: () {
            // You can show a Cupertino search bar here later
          },
        ),
        title: const Text('Love Interest'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.settings),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: const SafeArea(
        child: Column(
          children: [
            // Add your main UI here
          ],
        ),
      ),
    );
  }
}
