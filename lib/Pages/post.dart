import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

// Controller
class PostController extends GetxController {
  File? selectedImage;
  final descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      selectedImage = File(pickedImage.path);
      update(); // refresh UI
    }
  }

  void postImage() {
    final desc = descriptionController.text.trim();

    if (selectedImage != null && desc.isNotEmpty) {
      Get.dialog(
        CupertinoAlertDialog(
          title: const Text("Success"),
          content: const Text("Image and description uploaded!"),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("OK"),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );

      selectedImage = null;
      descriptionController.clear();
      update(); // refresh UI
    } else {
      Get.dialog(
        CupertinoAlertDialog(
          title: const Text("Error"),
          content: const Text("Please select an image and add a description!"),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    }
  }
}

// Screen
class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller once
    final controller = Get.put(PostController());
    final scrh = MediaQuery.of(context).size.height;
    final scrw = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Pin'), centerTitle: true),
      body: GetBuilder<PostController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(scrw * 0.05),
            child: Column(
              children: [
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: scrh * 0.3,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                    child: controller.selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.photo,
                                size: scrw * 0.1,
                                color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap to select an image',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              controller.selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controller.descriptionController,
                  maxLines: 3,
                  maxLength: 250,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    hintText: 'Add a description',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  borderRadius: BorderRadius.circular(24),
                  onPressed: controller.postImage,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(CupertinoIcons.cloud_upload),
                      SizedBox(width: 8),
                      Text('Save Pin'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
