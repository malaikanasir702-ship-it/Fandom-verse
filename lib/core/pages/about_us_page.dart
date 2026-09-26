import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/glass_container.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const _mentor = _TeamMember(
    name: 'Syed Ashir Ali',
    role: 'Mentor',
    bio: 'Our guiding force — providing technical direction, architectural guidance, and ensuring the project meets enterprise-grade standards.',
    icon: Iconsax.teacher,
    color: Color(0xFF6C63FF),
  );

  static const _teamLeader = _TeamMember(
    name: 'Rana Waleed',
    role: 'Team Leader',
    bio: 'Led the full development lifecycle — coordinating tasks, making architectural decisions, and driving the project from concept to completion.',
    icon: Iconsax.crown_1,
    color: AppColors.comicRed,
  );

  static const _members = [
    _TeamMember(
      name: 'Muhammad Zohair',
      role: 'Developer',
      bio: 'Contributed to UI design, feature implementation, and database integration across the fan-facing modules.',
      icon: Iconsax.code,
      color: AppColors.heroBlue,
    ),
    _TeamMember(
      name: 'Muhammad Subhan',
      role: 'Developer',
      bio: 'Worked on the admin panel, store module, and backend logic including SQLite schema design.',
      icon: Iconsax.setting_2,
      color: AppColors.heroGreen,
    ),
    _TeamMember(
      name: 'Hamna Shabbir',
      role: 'Developer',
      bio: 'Focused on UI/UX design, theming, onboarding flow, and community features.',
      icon: Iconsax.brush_1,
      color: AppColors.heroPurple,
    ),
  ];

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
        title: const Text('About Us',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── App Banner ─────────────────────────────────────────────────
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.comicRed, AppColors.heroPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('FV',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontStyle: FontStyle.italic)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fandom Verse Pocket Edition',
                    style: AppTextStyles.headlineMedium
                        .copyWith(fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fandom Trivia on the Go',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.comicRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              AppColors.comicRed.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Version 1.0.0  •  TechWiz 7 — Aptech Limited',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.comicRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Mission ────────────────────────────────────────────────────
            GlassContainer(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.flash_1,
                          color: AppColors.comicYellow, size: 20),
                      const SizedBox(width: 8),
                      Text('Our Mission',
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fandom Verse Pocket Edition is a unified cross-platform mobile app that brings together the global fandom community. '
                    'From anime and manga to gaming, K-Pop, Marvel, and beyond — we connect passionate fans with the content, events, merchandise, and community they love, all in one place.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Tech Stack ─────────────────────────────────────────────────
            GlassContainer(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.code,
                          color: AppColors.heroBlue, size: 20),
                      const SizedBox(width: 8),
                      Text('Technology Stack',
                          style: AppTextStyles.titleMedium
                              .copyWith(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Flutter 3.x',
                      'Dart 3.x',
                      'Firebase Auth',
                      'Cloud Firestore',
                      'SQLite (sqflite)',
                      'BLoC Pattern',
                      'GetIt DI',
                      'Groq AI (Llama 3)',
                      'MapLibre GL',
                      'Story View',
                    ]
                        .map((tech) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.heroBlue
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.heroBlue
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Text(tech,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.heroBlue)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Mentor ─────────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Mentor',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            _buildMemberCard(_mentor, isDark, isMentor: true),
            const SizedBox(height: 20),

            // ── Team Leader ────────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Team Leader',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            _buildMemberCard(_teamLeader, isDark, isLeader: true),
            const SizedBox(height: 20),

            // ── Team Members ───────────────────────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Team Members',
                  style: AppTextStyles.titleMedium
                      .copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 10),
            ..._members
                .map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMemberCard(m, isDark),
                    )),
            const SizedBox(height: 24),

            // ── Competition ────────────────────────────────────────────────
            GlassContainer(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.comicYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Iconsax.cup,
                          color: AppColors.comicYellow, size: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TechWiz 7 — World Tech Championship',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Multi-Platform App Computing Category\nAptech Limited',
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(
    _TeamMember member,
    bool isDark, {
    bool isMentor = false,
    bool isLeader = false,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: (isMentor || isLeader)
          ? member.color.withValues(alpha: 0.4)
          : null,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: member.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: member.color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(member.icon,
                  size: 26, color: member.color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: member.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        member.role,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: member.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  member.bio,
                  style: TextStyle(
                    fontSize: 12,
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
    );
  }
}

class _TeamMember {
  final String name;
  final String role;
  final String bio;
  final IconData icon;
  final Color color;

  const _TeamMember({
    required this.name,
    required this.role,
    required this.bio,
    required this.icon,
    required this.color,
  });
}
