import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinterest/Pages/onboarding.dart';
import 'package:pinterest/Pages/settings.dart';

class ProfileController extends GetxController {
  final SupabaseClient supabaseClient = Supabase.instance.client;
  Rx<User?> user = Rx<User?>(null);
  RxString name = 'No Name'.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) {
        Get.offAll(() => const Onboarding());
      } else {
        user.value = authUser;
        name.value = authUser.userMetadata?['name'] ?? 'No Name';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load user data: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      Get.offAll(() => const Onboarding());
    } catch (e) {
      errorMessage.value = 'Logout failed: $e';
    }
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Obx(() {
      if (controller.user.value == null &&
          controller.errorMessage.value.isEmpty) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Get.to(() => const SettingsScreen()),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: controller.fetchUser,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Avatar
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.person, color: Colors.white, size: 50),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    Text(
                      controller.name.value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Email
                    Text(
                      controller.user.value?.email ?? 'No Email',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Error Message
                    if (controller.errorMessage.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: controller.signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
