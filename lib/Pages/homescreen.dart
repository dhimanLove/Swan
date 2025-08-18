import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinterest/Pages/details.dart';
import 'package:pinterest/Pages/settings.dart';
import 'package:pinterest/Pages/storypage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  final ScrollController scrollController = ScrollController();

  List<Map<String, dynamic>> items = [];
  Map<String, Size> imageSizes = {};
  bool isLoading = false;
  bool hasMore = true;
  int limit = 10;
  int offset = 0;

  @override
  void initState() {
    super.initState();
    loadItems();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 100 &&
        !isLoading &&
        hasMore) {
      loadItems();
    }
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

      if (response.isEmpty) {
        setState(() {
          isLoading = false;
          hasMore = false;
        });
        return;
      }

      setState(() {
        items.addAll(response.cast<Map<String, dynamic>>());
        offset += limit;
        isLoading = false;
        hasMore = response.length >= limit;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasMore = false;
        });
        _showErrorDialog(e.toString());
      }
    }
  }

  Future<void> handleRefresh() async {
    try {
      final response = await supabase
          .from('interest')
          .select()
          .range(0, limit - 1)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          items = response.cast<Map<String, dynamic>>();
          imageSizes.clear();
          offset = limit;
          hasMore = response.length >= limit;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    if (!mounted) return;

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            "Error Found",
            style: TextStyle(
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            error,
            style: TextStyle(
              color: Get.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Get.back(),
              child: Text(
                "OK",
                style: TextStyle(
                  color: Get.isDarkMode ? Colors.blue[300] : Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildShimmerCard(BuildContext context, {double? height}) {
    final theme = Get.theme;
    final shimmerHeight =
        height ?? (180 + (DateTime.now().millisecondsSinceEpoch % 150));

    return Shimmer.fromColors(
      baseColor: theme.cardColor,
      highlightColor: theme.cardColor.withOpacity(0.7),
      child: Container(
        height: shimmerHeight,
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
      ),
    );
  }

  double _calculateImageHeight(String imageUrl, double containerWidth) {
    final size = imageSizes[imageUrl];
    if (size != null && size.width > 0) {
      final aspectRatio = size.height / size.width;
      return containerWidth * aspectRatio;
    }
    return (200 + (imageUrl.hashCode % 150).abs()).toDouble();
  }

  Widget _buildLazyImageCard(String imageUrl, String description, int index) {
    return VisibilityDetector(
      key: Key('lazy_image_$index'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1) {}
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final imageHeight = _calculateImageHeight(
            imageUrl,
            constraints.maxWidth,
          );

          return GestureDetector(
            onTap: () {
              Get.to(
                () => DetailPage(imgUrl: imageUrl, desc: description),
                transition: Transition.cupertinoDialog,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: imageHeight,
                  placeholder:
                      (context, url) =>
                          buildShimmerCard(context, height: imageHeight),
                  errorWidget:
                      (context, url, error) => Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                          color: Get.theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 40,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                  imageBuilder: (context, imageProvider) {
                    // Get image dimensions when loaded
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _getImageSize(imageProvider, imageUrl);
                    });

                    return Container(
                      height: imageHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                  memCacheWidth: 400,
                  memCacheHeight: 600,
                  maxWidthDiskCache: 800,
                  maxHeightDiskCache: 1200,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _getImageSize(
    ImageProvider imageProvider,
    String imageUrl,
  ) async {
    if (imageSizes.containsKey(imageUrl)) return;

    try {
      final ImageStream stream = imageProvider.resolve(
        ImageConfiguration.empty,
      );
      final Completer<Size> completer = Completer<Size>();

      late ImageStreamListener listener;
      listener = ImageStreamListener((ImageInfo info, bool _) {
        if (!completer.isCompleted) {
          final size = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
          completer.complete(size);
          stream.removeListener(listener);

          if (mounted) {
            setState(() {
              imageSizes[imageUrl] = size;
            });
          }
        }
      });

      stream.addListener(listener);
      await completer.future;
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 180).floor().clamp(2, 4);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          "Swan",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'Quicksand',
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: GestureDetector(
          onTap: () => Get.to(() => const StoryScreen()),
          child: const Icon(CupertinoIcons.add_circled, size: 28),
        ),
        trailing: GestureDetector(
          onTap:
              () => Get.to(
                () => const SettingsScreen(),
                transition: Transition.cupertino,
              ),
          child: const Icon(CupertinoIcons.settings, size: 28),
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
                final imageUrl = item['image_url'] as String?;
                final description = item['description'] as String? ?? "";

                if (imageUrl == null || imageUrl.isEmpty) {
                  return const SizedBox.shrink();
                }

                return _buildLazyImageCard(imageUrl, description, index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
