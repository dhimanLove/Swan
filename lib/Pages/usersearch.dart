import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _hasMore = false;
  int _limit = 30;
  int _offset = 0;
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 100 &&
        !_loading &&
        _hasMore) {
      _searchUsers(_query);
    }
  }

  void _onQueryChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = text.trim();
      _searchUsers(_query, reset: true);
    });
  }

  Future<void> _searchUsers(String query, {bool reset = false}) async {
    if (query.isEmpty) {
      setState(() {
        _results.clear();
        _hasMore = false;
      });
      return;
    }

    if (_loading) return;

    if (reset) {
      setState(() {
        _results.clear();
        _offset = 0;
        _hasMore = true;
      });
    }

    setState(() => _loading = true);

    try {
      final String? myId = supabase.auth.currentUser?.id;

      final List<dynamic> response = await supabase.rpc(
        'search_users_by_email',
        params: {'search_text': query},
      );

      final rows = response
          .whereType<Map<String, dynamic>>()
          .where((user) => user['id'] != myId)
          .toList();

      setState(() {
        _results.addAll(rows);
        _offset += rows.length;
        _hasMore = rows.length >= _limit;
      });
    } catch (e) {
      _showErrorDialog('Failed to search users.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Search Users',
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(CupertinoIcons.back, color: theme.iconTheme.color),
        ),
      ),
      child: CustomScrollView(
        controller: _scroll,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoSearchTextField(
                controller: _controller,
                placeholder: 'Search by email...',
                onChanged: _onQueryChanged,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                suffixIcon: _controller.text.isNotEmpty
                    ? const Icon(CupertinoIcons.clear_circled_solid)
                    : const Icon(CupertinoIcons.search),
                onSuffixTap: () {
                  _controller.clear();
                  _onQueryChanged('');
                },
              ),
            ),
          ),
          if (_loading && _results.isEmpty)
            const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            ),
          if (!_loading && _results.isEmpty && _query.isNotEmpty)
            SliverFillRemaining(child: _EmptyState(query: _query)),
          if (_results.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == _results.length) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CupertinoActivityIndicator()),
                    );
                  }
                  final user = _results[index];
                  final email = user['email'] ?? 'Unknown';
                  final avatar =
                      user['raw_user_meta_data']?['avatar_url'] as String?;

                  return _UserTile(
                    name: email,
                    email: email,
                    avatarUrl: avatar,
                    onTap: () {},
                  );
                },
                childCount: _results.length + (_loading && _hasMore ? 1 : 0),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.onTap,
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Get.theme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(14),
        onPressed: onTap,
        child: Row(
          children: [
            ClipOval(
              child: avatarUrl == null
                  ? Container(
                      width: 50,
                      height: 50,
                      color: theme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        CupertinoIcons.person,
                        color: theme.iconTheme.color,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const CupertinoActivityIndicator(),
                      errorWidget: (_, __, ___) => Icon(
                        CupertinoIcons.person,
                        color: theme.iconTheme.color,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.forward,
              color: theme.iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No results found for "$query"',
        style: TextStyle(color: Get.theme.textTheme.bodyLarge?.color),
      ),
    );
  }
}
