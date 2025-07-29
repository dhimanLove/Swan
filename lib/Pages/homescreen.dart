import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/Pages/settings.dart';
import 'package:pinterest/components/iossearch.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> items = [];
  bool isLoading = false;
  bool hasMore = true;
  int limit = 10;
  int offset = 0;

  @override
  void initState() {
    super.initState();
    loadItems();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        loadItems();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadItems() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('interest')
          .select()
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      if (response is! List) {
        setState(() {
          isLoading = false;
          hasMore = false;
        });
        return;
      }

      final List data = response;
      setState(() {
        items.addAll(data.cast<Map<String, dynamic>>());
        offset += limit;
        isLoading = false;
        if (data.length < limit) hasMore = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleRefresh() async {
    try {
      final response = await supabase
          .from('interest')
          .select()
          .range(0, limit - 1)
          .order('created_at', ascending: false);

      setState(() {
        items = response.cast<Map<String, dynamic>>();
        offset = limit;
        hasMore = response.length >= limit;
      });
        } catch (e) {
          //
        }
  }

  Widget buildShimmerCard(BuildContext context) {
    final theme = Get.theme;
    return Shimmer.fromColors(
      baseColor: theme.cardColor,
      highlightColor: theme.cardColor.withOpacity(0.7),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                height: 20,
                width: double.infinity,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 180).floor().clamp(2, 4);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Love Interest',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color:
                Get.isDarkMode ? const Color.fromARGB(201, 255, 255, 255) :const Color(0xBA000000),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: GestureDetector(
          onTap: () => showCupertinoSearchPopup(),
          child: const Icon(CupertinoIcons.search),
        ),
        trailing: GestureDetector(
          onTap:
              () => Get.to(
                () => const SettingsScreen(),
                transition: Transition.cupertino,
              ),
          child: const Icon(CupertinoIcons.settings),
        ),
      ),
      child: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: handleRefresh),
          SliverPadding(
            padding: const EdgeInsets.only(top: 30, left: 6, right: 6),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childCount: items.length + (isLoading ? 10 : 0),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return buildShimmerCard(context);
                }
                final item = items[index];
                final imageUrl = item['image_url'];
                final description = item['description'] ?? '';

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    child,
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        description,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return buildShimmerCard(context);
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Icon(
                                    CupertinoIcons.exclamationmark_triangle,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            description,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
