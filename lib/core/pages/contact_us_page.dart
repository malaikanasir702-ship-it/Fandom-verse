import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/glass_container.dart';
import '../widgets/skewed_button.dart';
import '../widgets/custom_text_field.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;
  bool _submitted = false;
  String _selectedType = 'General Enquiry';

  final List<String> _enquiryTypes = [
    'General Enquiry',
    'Bug Report',
    'Feature Request',
    'Partnership',
    'Merchandise Support',
    'Event Listing',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    // Simulate network submission
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isSending = false;
        _submitted = true;
      });
    }
  }

  void _resetForm() {
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
    setState(() {
      _submitted = false;
      _selectedType = 'General Enquiry';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Contact Us',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _submitted ? _buildSuccessView(isDark) : _buildForm(isDark),
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border:
                Border.all(color: AppColors.success, width: 2),
          ),
          child: const Icon(Iconsax.tick_square,
              color: AppColors.success, size: 40),
        ),
        const SizedBox(height: 20),
        Text('Message Sent!',
            style: AppTextStyles.headlineMedium
                .copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        Text(
          'Thank you for reaching out to the Fandom Verse team.\nWe\'ll get back to you within 24–48 hours.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 32),
        SkewedButton(
          text: 'Send Another Message',
          icon: Iconsax.message_edit,
          height: 52,
          fontSize: 14,
          onPressed: _resetForm,
        ),
      ],
    );
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Banner ───────────────────────────────────────────────
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.comicRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.message_question,
                      color: AppColors.comicRed, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Get In Touch',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 3),
                      Text(
                        'We\'d love to hear from you. Submit an enquiry and our team will respond shortly.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Enquiry Type ────────────────────────────────────────────────
          const Text('Enquiry Type',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _enquiryTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final type = _enquiryTypes[i];
                final isSel = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.comicRed.withValues(alpha: 0.12)
                          : (isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel
                            ? AppColors.comicRed
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                      ),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSel
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isSel
                            ? AppColors.comicRed
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // ── Form Fields ─────────────────────────────────────────────────
          CustomTextField(
            controller: _nameController,
            label: 'Your Full Name',
            prefixIcon: const Icon(Iconsax.profile_circle, size: 18),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Iconsax.sms, size: 18),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _subjectController,
            label: 'Subject',
            prefixIcon: const Icon(Iconsax.edit, size: 18),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Subject is required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _messageController,
            maxLines: 5,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Message is required';
              if (v.trim().length < 20) return 'Message too short (min 20 chars)';
              return null;
            },
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Your Message',
              alignLabelWithHint: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Iconsax.message_text, size: 18),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.lightSurfaceElevated,
            ),
          ),
          const SizedBox(height: 28),

          SkewedButton(
            text: _isSending ? 'Sending...' : 'Send Message',
            icon: Iconsax.send_1,
            height: 52,
            fontSize: 14,
            backgroundColor: AppColors.comicRed,
            onPressed: _isSending ? null : _submitForm,
          ),
          const SizedBox(height: 32),

          // ── Contact Details ─────────────────────────────────────────────
          Text('Contact Details',
              style: AppTextStyles.titleMedium
                  .copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _buildContactTile(
            icon: Iconsax.sms,
            title: 'Email',
            value: 'team@fandomverse.app',
            isDark: isDark,
            onTap: () =>
                Clipboard.setData(const ClipboardData(text: 'team@fandomverse.app')),
          ),
          _buildContactTile(
            icon: Iconsax.location,
            title: 'Studio',
            value: 'Aptech Learning, Pakistan',
            isDark: isDark,
          ),
          _buildContactTile(
            icon: Iconsax.global,
            title: 'Competition',
            value: 'TechWiz 7 — World Tech Championship',
            isDark: isDark,
          ),
          _buildContactTile(
            icon: Iconsax.building_3,
            title: 'Organization',
            value: 'Aptech Limited',
            isDark: isDark,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.comicRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.comicRed, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (onTap != null)
              Icon(Iconsax.copy,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}
