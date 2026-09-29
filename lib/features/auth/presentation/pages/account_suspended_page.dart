import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/services/suspension_appeal_service.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class AccountSuspendedPage extends StatefulWidget {
  final UserEntity? user;

  const AccountSuspendedPage({
    super.key,
    this.user,
  });

  @override
  State<AccountSuspendedPage> createState() => _AccountSuspendedPageState();
}

class _AccountSuspendedPageState extends State<AccountSuspendedPage> {
  final TextEditingController _appealController = TextEditingController();
  final SuspensionAppealService _appealService = SuspensionAppealService.instance;

  bool _isSubmitting = false;
  bool _isCheckingStatus = false;
  Map<String, dynamic>? _existingAppeal;
  bool _isLoadingAppeal = true;
  Timer? _autoCheckTimer;

  UserEntity? get _targetUser => widget.user ?? context.read<AuthBloc>().currentUser;

  @override
  void initState() {
    super.initState();
    _fetchExistingAppeal();
    // Periodically check every 5 seconds if admin has unbanned the user
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkIfUnbanned(silent: true);
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    _appealController.dispose();
    super.dispose();
  }

  Future<void> _fetchExistingAppeal() async {
    final user = _targetUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingAppeal = false);
      return;
    }

    try {
      final appeal = await _appealService.getAppealForUser(user.id);
      if (mounted) {
        setState(() {
          _existingAppeal = appeal;
          _isLoadingAppeal = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingAppeal = false);
    }
  }

  Future<void> _checkIfUnbanned({bool silent = false}) async {
    final user = _targetUser;
    if (user == null || !mounted) return;

    if (!silent) {
      setState(() => _isCheckingStatus = true);
    }

    try {
      final isStillBanned = await _appealService.isUserBanned(user.id, email: user.email);
      if (!isStillBanned) {
        if (!mounted) return;
        // User is unbanned!
        _autoCheckTimer?.cancel();
        _showReinstatedDialog();
        return;
      }

      // Check if appeal record updated
      final updatedAppeal = await _appealService.getAppealForUser(user.id);
      if (mounted) {
        setState(() {
          _existingAppeal = updatedAppeal;
          _isCheckingStatus = false;
        });
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account is still under suspension review.'),
              backgroundColor: AppColors.comicRed,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        setState(() => _isCheckingStatus = false);
      }
    }
  }

  void _showReinstatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Iconsax.tick_circle, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text(
              'Account Reinstated!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Great news! The administrator has reviewed your appeal and reinstated your account. You can now log in and enjoy Fandom-verse.',
          style: TextStyle(fontSize: 14, color: AppColors.adminLightTextSecondary),
        ),
        actions: [
          SkewedButton(
            text: 'Go to Login',
            height: 42,
            backgroundColor: AppColors.success,
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitAppeal() async {
    final reason = _appealController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe why your account should be reinstated.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = _targetUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session not found. Please log in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await _appealService.submitAppeal(
        userId: user.id,
        email: user.email,
        name: user.name,
        reason: reason,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appeal submitted successfully! An admin will review it.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 3),
          ),
        );
        _appealController.clear();
        await _fetchExistingAppeal();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit appeal. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _targetUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appealStatus = _existingAppeal?['status'] as String?;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.comicRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.comicRed.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Iconsax.danger, color: AppColors.comicRed, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'SECURITY NOTICE',
                    style: TextStyle(
                      color: AppColors.comicRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Iconsax.logout, color: AppColors.comicRed),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutEvent());
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoadingAppeal
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.comicRed),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // ── Warning Shield Banner ──
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.comicRed.withValues(alpha: 0.12),
                        border: Border.all(color: AppColors.comicRed.withValues(alpha: 0.35), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.comicRed.withValues(alpha: 0.2),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Iconsax.user_minus,
                          size: 44,
                          color: AppColors.comicRed,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Title & Message ──
                    const Text(
                      'Your Account Has Been Suspended',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'An administrator has temporarily or permanently suspended this account. Access to feed, messaging, ticketing, and store features has been blocked.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── User Identifier Card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF181B24) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.comicRed.withValues(alpha: 0.15),
                            child: Text(
                              (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.comicRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name ?? 'Fan Member',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.comicRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SUSPENDED',
                              style: TextStyle(
                                color: AppColors.comicRed,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Appeal Section / Dynamic Status ──
                    _buildAppealSection(isDark, appealStatus),

                    const SizedBox(height: 24),

                    // ── Check Status & Return Buttons ──
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white : Colors.black87,
                              side: BorderSide(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: _isCheckingStatus
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Iconsax.refresh, size: 16),
                            label: const Text('Refresh Status', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                            onPressed: _isCheckingStatus ? null : () => _checkIfUnbanned(silent: false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SkewedButton(
                            text: 'Back to Login',
                            icon: Iconsax.logout,
                            height: 46,
                            fontSize: 12.5,
                            backgroundColor: const Color(0xFF374151),
                            textColor: Colors.white,
                            onPressed: () {
                              context.read<AuthBloc>().add(const LogoutEvent());
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAppealSection(bool isDark, String? appealStatus) {
    if (appealStatus == 'pending') {
      final reason = _existingAppeal?['reason'] ?? '';
      final createdAt = _existingAppeal?['created_at'];
      String timeStr = 'Recently';
      if (createdAt is int) {
        final dt = DateTime.fromMillisecondsSinceEpoch(createdAt);
        timeStr = '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Iconsax.timer_1, color: Color(0xFFD97706), size: 20),
                SizedBox(width: 8),
                Text(
                  'Appeal Review Underway',
                  style: TextStyle(
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your appeal request was submitted ($timeStr) and is waiting for administrator approval.',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E212D) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Statement:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFD97706),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Listening for live admin decision...',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (appealStatus == 'rejected') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Iconsax.close_circle, color: AppColors.error, size: 20),
                SizedBox(width: 8),
                Text(
                  'Appeal Declined',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your previous appeal was reviewed and declined by the administration. You may submit a new revised statement if you have additional information.',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            _buildAppealInputForm(isDark, isResubmission: true),
          ],
        ),
      );
    }

    // Default: No appeal submitted yet
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.message_edit, color: AppColors.comicRed, size: 20),
              SizedBox(width: 8),
              Text(
                'Submit Appeal Review',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'If you think this suspension was placed by mistake, send an appeal statement directly to the admin moderation team.',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _buildAppealInputForm(isDark),
        ],
      ),
    );
  }

  Widget _buildAppealInputForm(bool isDark, {bool isResubmission = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _appealController,
          maxLines: 4,
          maxLength: 500,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: isResubmission
                ? 'Provide updated details or clarifications for the admin...'
                : 'Explain why your account should be unbanned (e.g. account compromised, misunderstanding)...',
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF12141C) : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.comicRed,
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SkewedButton(
          text: _isSubmitting ? 'Sending Request...' : 'Send Appeal to Admin',
          icon: Iconsax.send_1,
          height: 44,
          fontSize: 13,
          backgroundColor: AppColors.comicRed,
          textColor: Colors.white,
          onPressed: _isSubmitting ? null : _submitAppeal,
        ),
      ],
    );
  }
}
