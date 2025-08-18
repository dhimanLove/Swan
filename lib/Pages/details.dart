import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinterest/components/pptheme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


class DetailPage extends StatefulWidget {
  final String imgUrl;
  final String desc;

  const DetailPage({super.key, required this.imgUrl, required this.desc});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  bool isLiked = false;
  bool isExpanded = false;
  static const int maxWords = 20;

  late AnimationController _likeController;
  late Animation<double> _likeScale;

  // Comments
  final List<Comment> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
    _loadComments();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadLikeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isLiked = prefs.getBool('liked_${widget.imgUrl}') ?? false;
    setState(() {});
  }

  Future<void> _saveLikeStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('liked_${widget.imgUrl}', value);
  }

  // Comments functionality
  Future<void> _loadComments() async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = prefs.getString('comments_${widget.imgUrl}') ?? '[]';
    final List<dynamic> commentsList = json.decode(commentsJson);
    _comments.clear();
    _comments.addAll(commentsList.map((e) => Comment.fromJson(e)).toList());
    setState(() {});
  }

  Future<void> _saveComments() async {
    final prefs = await SharedPreferences.getInstance();
    final commentsJson = json.encode(_comments.map((e) => e.toJson()).toList());
    await prefs.setString('comments_${widget.imgUrl}', commentsJson);
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      author: 'You', // In real app, get from user session
      createdAt: DateTime.now(),
    );

    setState(() {
      _comments.insert(0, newComment);
    });

    await _saveComments();
    _commentController.clear();
    _commentFocusNode.unfocus();
  }

  void _deleteComment(String commentId) async {
    setState(() {
      _comments.removeWhere((comment) => comment.id == commentId);
    });
    await _saveComments();
  }

  void _showCommentsSheet() {
    final theme = Theme.of(context);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Comments (${_comments.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(
                      CupertinoIcons.xmark,
                      color: theme.iconTheme.color,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Comments list
            Expanded(
              child: _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.chat_bubble,
                            size: 50,
                            color: CupertinoColors.systemGrey3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No comments yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to comment',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return _CommentTile(
                          comment: comment,
                          theme: theme,
                          onDelete: () => _deleteComment(comment.id),
                        );
                      },
                    ),
            ),

            // Comment input
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 8,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey5,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      autocorrect: true,
                      controller: _commentController,
                      focusNode: _commentFocusNode,
                      placeholder: 'Add a comment...',
                      maxLines: null,
                      style: theme.textTheme.bodyMedium,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                          width: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.paperplane_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Permission?> _getGalleryPermission() async {
    if (Platform.isAndroid) {
      return Permission.storage;
    }
    return null;
  }

  Future<void> saveImgToGallery(String url) async {
    try {
      Permission? permission = await _getGalleryPermission();
      PermissionStatus? status;
      if (permission != null) {
        status = await permission.status;
        if (status.isDenied || status.isRestricted) status = await permission.request();
        if (status.isPermanentlyDenied) {
          _showPermissionSettingsDialog();
          return;
        }
        if (!status.isGranted) {
          _showAlert("Permission Denied", "Storage permission is required to save images.");
          return;
        }
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = Directory('/storage/emulated/0/Pictures/Pinterest');
        if (!await dir.exists()) await dir.create(recursive: true);
        final fileName = "pinterest_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final file = File("${dir.path}/$fileName");
        await file.writeAsBytes(response.bodyBytes);
        _showAlert("Success", "Image saved to gallery");
      } else {
        _showAlert("Error", "Download failed.");
      }
    } catch (e) {
      _showAlert("Error", e.toString());
    }
  }

  void _showPermissionSettingsDialog() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Permission Required"),
        content: const Text("Storage permission is permanently denied. Grant permission in settings."),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text("Open Settings"),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _showAlert(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _getTruncatedText(String text) {
    final words = text.split(' ');
    if (words.length <= maxWords) return text;
    return '${words.take(maxWords).join(' ')}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final maxImgWidth = mq.size.width - 32;

    return Theme(
      data: mq.platformBrightness == Brightness.dark ? PpTheme.darkTheme : PpTheme.lightTheme,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Preview'),
          backgroundColor: theme.appBarTheme.backgroundColor,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.back,
              color: theme.iconTheme.color,
              size: 28,
            ),
            onPressed: () => Get.back(),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.share,
              color: theme.iconTheme.color,
              size: 28,
            ),
            onPressed: () => Share.share('${widget.desc}\n${widget.imgUrl}'),
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return FutureBuilder(
                        future: _getImageOriginalSize(widget.imgUrl),
                        builder: (context, AsyncSnapshot<Size?> snap) {
                          double displayWidth = maxImgWidth;
                          double displayHeight = 300;

                          if (snap.hasData && snap.data != null) {
                            final Size sz = snap.data!;
                            if (sz.width > maxImgWidth) {
                              displayWidth = maxImgWidth;
                              displayHeight = displayWidth * (sz.height / sz.width);
                            } else {
                              displayWidth = sz.width;
                              displayHeight = sz.height;
                            }
                          }

                          return GestureDetector(
                            onDoubleTap: () async {
                              setState(() => isLiked = !isLiked);
                              await _saveLikeStatus(isLiked);
                              _likeController.forward(from: 0);
                            },
                            child: Hero(
                              tag: widget.imgUrl,
                              child: SizedBox(
                                width: displayWidth,
                                height: displayHeight,
                                child: CachedNetworkImage(
                                  imageUrl: widget.imgUrl,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  placeholder: (context, url) => Container(
                                    color: theme.cardColor,
                                    child: const Center(child: CupertinoActivityIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: theme.cardColor,
                                    child: const Center(
                                      child: Icon(
                                        CupertinoIcons.exclamationmark_triangle,
                                        size: 40,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Row with description first line + Like & Comment buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Expanded description column with See more/less
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: Text(
                                  isExpanded ? widget.desc : _getTruncatedText(widget.desc),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              if (widget.desc.split(' ').length > maxWords)
                                GestureDetector(
                                  onTap: () => setState(() => isExpanded = !isExpanded),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      isExpanded ? 'See less' : 'See more',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Like button - only shows status, no tap action (double tap on image only)
                        Column(
                          children: [
                            AnimatedBuilder(
                              animation: _likeController,
                              builder: (context, child) => Transform.scale(
                                scale: _likeScale.value,
                                child: Icon(
                                  isLiked ? CupertinoIcons.heart_solid : CupertinoIcons.heart,
                                  color: isLiked ? CupertinoColors.systemRed : theme.iconTheme.color,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 8),

                        // Comment button
                        Column(
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Stack(
                                children: [
                                  Icon(
                                    CupertinoIcons.chat_bubble,
                                    color: theme.iconTheme.color,
                                    size: 28,
                                  ),
                                  if (_comments.isNotEmpty)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '${_comments.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onPressed: _showCommentsSheet,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Size?> _getImageOriginalSize(String url) async {
    try {
      final image = Image.network(url);
      final imageCompleter = Completer<Size>();
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((info, _) {
          imageCompleter.complete(Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          ));
        }),
      );
      return await imageCompleter.future;
    } catch (e) {
      return null;
    }
  }
}

// Comment model
class Comment {
  final String id;
  final String text;
  final String author;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      text: json['text'],
      author: json['author'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  String get authorInitials {
    final parts = author.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

// Comment tile widget
class _CommentTile extends StatelessWidget {
  final Comment comment;
  final ThemeData theme;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.theme,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              comment.authorInitials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          // Delete button
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.delete,
              color: CupertinoColors.systemGrey,
              size: 18,
            ),
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (_) => CupertinoAlertDialog(
                  title: const Text('Delete Comment'),
                  content: const Text('Are you sure you want to delete this comment?'),
                  actions: [
                    CupertinoDialogAction(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: const Text('Delete'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDelete();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
