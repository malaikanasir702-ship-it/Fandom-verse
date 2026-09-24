import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../../domain/entities/discussion_thread.dart';

class ThreadDetailPage extends StatefulWidget {
  final DiscussionThread thread;
  const ThreadDetailPage({super.key, required this.thread});

  @override
  State<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> {
  final _replyController = TextEditingController();
  late DiscussionThread _thread;

  @override
  void initState() {
    super.initState();
    _thread = widget.thread;
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    if (_replyController.text.trim().isEmpty) return;
    context.read<CommunityBloc>().add(AddReplyToThreadEvent(
      threadId: _thread.id,
      replyText: _replyController.text.trim(),
      userName: 'FanUser123',
    ));
    _replyController.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💬 Reply posted!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _thread.category,
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.darkSecondary, fontSize: 15),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Share feature coming soon!')),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // OP (Original Post)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.darkPrimary, AppColors.darkSecondary],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _thread.userName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_thread.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.darkAccentGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _thread.userBadge,
                                  style: const TextStyle(color: AppColors.darkAccentGold, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _timeAgo(_thread.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                Text(_thread.title, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800, height: 1.3)),
                const SizedBox(height: 10),

                // Body
                Text(_thread.body, style: AppTextStyles.bodyMedium.copyWith(height: 1.65)),
                const SizedBox(height: 14),

                // Vote row
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.read<CommunityBloc>().add(UpvoteThreadEvent(_thread.id)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _thread.isUpvoted
                              ? AppColors.darkPrimary.withValues(alpha: 0.15)
                              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _thread.isUpvoted ? AppColors.darkPrimary : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 16,
                              color: _thread.isUpvoted ? AppColors.darkPrimary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_thread.upvotes} Upvotes',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: _thread.isUpvoted ? AppColors.darkPrimary : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.comment_rounded, size: 16),
                          const SizedBox(width: 6),
                          Text('${_thread.replies.length} Replies', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                const SizedBox(height: 12),

                if (_thread.replies.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text('No replies yet. Be the first to reply! 💬',
                          style: TextStyle(color: AppColors.darkTextSecondary)),
                    ),
                  )
                else
                  ..._thread.replies.map((reply) => _ReplyCard(reply: reply)),
              ],
            ),
          ),

          // Reply Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    maxLines: null,
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
                      gradient: LinearGradient(colors: [AppColors.darkPrimary, AppColors.darkSecondary]),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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

class _ReplyCard extends StatelessWidget {
  final DiscussionReply reply;
  const _ReplyCard({required this.reply});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkSecondary.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                reply.userName.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: AppColors.darkSecondary, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(reply.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text(
                      _timeAgo(reply.createdAt),
                      style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(reply.body, style: AppTextStyles.bodySmall.copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
