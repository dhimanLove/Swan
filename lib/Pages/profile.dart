import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoProfile extends StatelessWidget {
  const CupertinoProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Your Profile"),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Photo + Name + Email
              const CircleAvatar(
                radius: 45,
                backgroundColor: CupertinoColors.systemGrey,
                child: Icon(CupertinoIcons.person, size: 50),
              ),
              const SizedBox(height: 12),
              const Text(
                "Loveraj",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "loveraj@example.com",
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 24),

              // About Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Hey! I'm Loveraj, a CSE student and the founder of Love Interest ❤️.\n"
                  "This is where I share the cutest hampers and gift ideas starting from ₹250.\n"
                  "Stay tuned for more magic! ✨",
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 24),

              // Hashtags
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "🔥 Trending Hashtags",
                  style: theme.textTheme.navTitleTextStyle,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(6, (index) {
                  final tags = ["#cutegifts", "#hampers", "#diypackaging", "#loveinterest", "#giftideas", "#aesthetic"];
                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: CupertinoColors.systemPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    child: Text(tags[index], style: const TextStyle(fontSize: 14)),
                    onPressed: () {},
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Posts Grid (2 per row)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "🖼️ Your Posts",
                  style: theme.textTheme.navTitleTextStyle,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            child: const Icon(CupertinoIcons.photo, size: 50),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Post #${index + 1}",
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
