import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import '../../domain/entities/discussion_thread.dart';

class ThreadDetailPage extends StatefulWidget {
  final DiscussionThread thread;
  const ThreadDetailPage({super.key, required this.thread});

  @override
  State<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  late DiscussionThread _thread;

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submitReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<AuthBloc>().currentUser;
    final senderName = (user != null && user.name.isNotEmpty) ? user.name : 'FanExplorer';

    // 1. INSTANT OPTIMISTIC UI UPDATE (Zero ms delay)
    final instantReply = DiscussionReply(
      id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
      userName: senderName,
      userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
      body: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _thread = _thread.copyWith(
        replies: [..._thread.replies, instantReply],
      );
    });

    _replyController.clear();
    FocusScope.of(context).unfocus();

    // Auto-scroll to show the new comment immediately
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // 2. Dispatch to BLoC to persist
    context.read<CommunityBloc>().add(AddReplyToThreadEvent(
      threadId: _thread.id,
      replyText: text,
      userName: senderName,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comment posted instantly!'),
        backgroundColor: AppColors.comicBlack,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is CommunityLoaded) {
          final updated = state.threads.firstWhere(
            (t) => t.id == _thread.id,
            orElse: () => _thread,
          );
          if (updated.replies.length > _thread.replies.length) {
            setState(() => _thread = updated);
          }
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          title: Text(
            _thread.category.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.comicRed, fontSize: 15),
          ),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.share, size: 20),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thread link copied to clipboard!')),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // OP (Original Post)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.comicRed,
                        ),
                        child: Center(
                          child: Text(
                            _thread.userName.isNotEmpty ? _thread.userName.substring(0, 1).toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_thread.userName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.comicYellow,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _thread.category.toUpperCase(),
                                    style: const TextStyle(color: AppColors.comicBlack, fontSize: 9, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _timeAgo(_thread.createdAt),
                                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.comicGray),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title & Body
                  Text(
                    _thread.title,
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _thread.body,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 16),

                  // Upvote / Replies Count Bar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.flash, size: 16, color: AppColors.comicYellow),
                            const SizedBox(width: 4),
                            Text(
                              '${_thread.upvotes} Upvotes',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.messages, size: 16, color: AppColors.comicRed),
                            const SizedBox(width: 4),
                            Text(
                              '${_thread.replies.length} Comments',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 36, thickness: 1),

                  // Comments Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'COMMENTS (${_thread.replies.length})',
                        style: AppTextStyles.comicSectionHeader.copyWith(
                          fontSize: 14,
                          color: isDark ? Colors.white : AppColors.comicBlack,
                        ),
                      ),
                      const Text(
                        'Live Discussion',
                        style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Replies List
                  if (_thread.replies.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      child: const Column(
                        children: [
                          Icon(Iconsax.messages, size: 36, color: AppColors.comicGray),
                          SizedBox(height: 8),
                          Text(
                            'No comments yet. Be the first to share your thoughts!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.comicGray, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._thread.replies.map((reply) => _ReplyCard(reply: reply)),
                ],
              ),
            ),

            // ── Bottom Comment Input Box (Solid Styling) ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.comicGrayLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _submitReply(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _submitReply,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.comicRed,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final DiscussionReply reply;
  const _ReplyCard({required this.reply});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.comicYellow,
            ),
            child: Center(
              child: Text(
                reply.userName.isNotEmpty ? reply.userName.substring(0, 1).toUpperCase() : 'U',
                style: const TextStyle(color: AppColors.comicBlack, fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(reply.userName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(
                      _timeAgo(reply.createdAt),
                      style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.comicGray),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reply.body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.white : AppColors.comicBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
