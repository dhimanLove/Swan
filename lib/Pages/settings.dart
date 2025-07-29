import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/components/themecontrolller.dart'; // ThemeController

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool isClearingCache = false;

  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              title: Text(
                "Settings",
                style: theme.appBarTheme.titleTextStyle,
              ),
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text("ACCOUNT", style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(CupertinoIcons.lock_shield, size: 20),
                            title: Text("Privacy & Security", style: theme.textTheme.bodyMedium),
                            trailing: const Icon(CupertinoIcons.right_chevron, size: 16),
                            onTap: () {},
                          ),
                          ListTile(
                            leading: const Icon(CupertinoIcons.refresh, size: 20),
                            title: Text("Clear Cache", style: theme.textTheme.bodyMedium),
                            trailing: isClearingCache
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(CupertinoIcons.right_chevron, size: 16),
                            onTap: handleClearCache,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("PREFERENCES", style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Card(
                      child: Column(
                        children: [
                          GetBuilder<ThemeController>(
                            builder: (controller) {
                              final isDark = controller.isDarkMode;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Dark Mode", style: theme.textTheme.bodyMedium),
                                    CupertinoSwitch(
                                      value: isDark,
                                      onChanged: (value) => controller.toggleTheme(),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Notifications", style: theme.textTheme.bodyMedium),
                                CupertinoSwitch(
                                  value: notificationsEnabled,
                                  onChanged: (value) {
                                    setState(() => notificationsEnabled = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            leading: const Icon(CupertinoIcons.globe, size: 20),
                            title: Text("Language", style: theme.textTheme.bodyMedium),
                            trailing: const Icon(CupertinoIcons.right_chevron, size: 16),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text("APP", style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Card(
                      child: ListTile(
                        leading: const Icon(CupertinoIcons.info, size: 20),
                        title: Text("About", style: theme.textTheme.bodyMedium),
                        trailing: const Icon(CupertinoIcons.right_chevron, size: 16),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: ListTile(
                        title: Text(
                          "Logout",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          CupertinoIcons.square_arrow_right,
                          color: theme.colorScheme.error,
                        ),
                        onTap: showLogoutDialog,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleClearCache() async {
    if (isClearingCache) return;
    setState(() => isClearingCache = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isClearingCache = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Cache cleared successfully",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Logout"),
            onPressed: () {
              Navigator.of(context).pop();
              // Add logout logic here
            },
          ),
        ],
      ),
    );
  }
}
