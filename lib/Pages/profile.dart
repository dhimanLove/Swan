// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinterest/Pages/settings.dart';
import 'package:pinterest/Pages/storypage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:pinterest/Pages/onboarding.dart';

/// ===========================
/// Production constants (no magic strings)
/// ===========================
class _ProfileConsts {
  static const String bucketName = 'profile_pics';
  static const String profilePicsTable = 'profile_pics';
  static const String userMetaNameKey = 'name';
  static const String userMetaAvatarKey = 'avatar_url';
}

/// ===========================
/// Controller
/// ===========================
class ProfileController extends GetxController {
  final SupabaseClient supabaseClient = Supabase.instance.client;

  final Rx<User?> user = Rx<User?>(null);
  final RxString name = 'No Name'.obs;
  final RxString avatarUrl = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUploading = false.obs;

  final ImagePicker picker = ImagePicker();

  StreamSubscription<AuthState>? _authSub;
  bool _pickLock = false; // simple debounce so user can’t spam the picker

  @override
  void onInit() {
    super.onInit();
    _listenAuthChanges();
    fetchUser();
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  void _listenAuthChanges() {
    // If user signs out in another part of the app or token expires,
    // keep this screen in sync.
    _authSub = supabaseClient.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      if (session == null) {
        // no session = logged out
        Get.offAll(() => const Onboarding());
      } else {
        // refresh user data
        fetchUser();
      }
    });
  }

  Future<void> fetchUser() async {
    try {
      final authUser = supabaseClient.auth.currentUser;
      if (authUser == null) {
        Get.offAll(() => const Onboarding());
        return;
      }
      user.value = authUser;

      // Defensive reads from user metadata
      final metadata = authUser.userMetadata ?? {};
      name.value =
          (metadata[_ProfileConsts.userMetaNameKey] as String?)
                      ?.trim()
                      .isNotEmpty ==
                  true
              ? metadata[_ProfileConsts.userMetaNameKey] as String
              : 'No Name';

      avatarUrl.value =
          (metadata[_ProfileConsts.userMetaAvatarKey] as String?)?.trim() ?? '';
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = "Failed to load profile.";
    }
  }

  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      Get.offAll(() => const Onboarding());
    } catch (e) {
      Get.snackbar(
        "Sign out failed",
        "Please try again.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> pickImage(BuildContext context) async {
    if (_pickLock) return; // prevent double dialogs
    _pickLock = true;

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        _pickLock = false;
        return;
      }

      final imageFile = File(pickedFile.path);

      await showCupertinoDialog(
        context: context,
        builder:
            (_) => CupertinoAlertDialog(
              title: const Text("Confirm Profile Picture"),
              content: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(imageFile, height: 150, fit: BoxFit.cover),
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text("Upload"),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await uploadImage(imageFile);
                  },
                ),
              ],
            ),
      );
    } finally {
      // release debounce lock after dialog completes
      _pickLock = false;
    }
  }

  Future<void> uploadImage(File imageFile) async {
    try {
      isUploading.value = true;

      // Safer, more unique file name (userId + timestamp)
      final uid = supabaseClient.auth.currentUser?.id ?? 'anon';
      final fileName =
          "profile_${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Upload to storage
      final res = await supabaseClient.storage
          .from(_ProfileConsts.bucketName)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );
      // Supabase may return the path or throw; if empty, treat as failure
      if (res.isEmpty) {
        throw "Upload failed — empty response.";
      }

      // Public URL (assumes bucket is public)
      final publicUrl = supabaseClient.storage
          .from(_ProfileConsts.bucketName)
          .getPublicUrl(fileName);

      // Update auth metadata (keeps your original logic)
      avatarUrl.value = publicUrl;
      await supabaseClient.auth.updateUser(
        UserAttributes(data: {_ProfileConsts.userMetaAvatarKey: publicUrl}),
      );

      // Persist record (keeps your original logic)
      await supabaseClient.from(_ProfileConsts.profilePicsTable).insert({
        'user_id': supabaseClient.auth.currentUser?.id,
        'image_url': publicUrl,
        'uploaded_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        "Success",
        "Profile picture updated!",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.dialog(
        CupertinoAlertDialog(
          title: const Text("Upload Failed"),
          content: Text("Error: $e"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    } finally {
      isUploading.value = false;
    }
  }
}

/// ===========================
/// Screen
/// ===========================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return CupertinoPageScaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Semantics(
                          label: 'Profile picture. Double tap to change.',
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.pickImage(context),
                            child: ClipOval(
                              child: _Avatar(
                                url: controller.avatarUrl.value,
                                size: 100,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.name.value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                controller.user.value?.email ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Get.to(() => const SettingsScreen()),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Icon(
                              CupertinoIcons.settings,
                              size: 35,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Stats row (still placeholders; production-safe UI)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _StatItem(label: "Posts", value: "30"),
                        _StatItem(label: "Followers", value: "120"),
                        _StatItem(label: "Following", value: "80"),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Error message (if any)
                    if (controller.errorMessage.value.isNotEmpty)
                      Center(
                        child: Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CupertinoColors.systemRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Fullscreen uploading veil
              if (controller.isUploading.value)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CupertinoActivityIndicator(radius: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar widget with cached image + graceful placeholders
class _Avatar extends StatelessWidget {
  final String url;
  final double size;
  const _Avatar({required this.url, this.size = 100});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      color: CupertinoColors.systemGrey2,
      child: const Icon(
        CupertinoIcons.person_fill,
        color: CupertinoColors.white,
        size: 50,
      ),
    );

    if (url.isEmpty) return placeholder;

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder:
          (context, _) => Container(
            width: size,
            height: size,
            color: CupertinoColors.systemGrey2,
            child: const Center(child: CupertinoActivityIndicator()),
          ),
      errorWidget: (context, _, __) => placeholder,
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: CupertinoColors.white, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
