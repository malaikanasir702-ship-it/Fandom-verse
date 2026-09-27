import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FAQEntry {
  final String question;
  final String answer;

  const FAQEntry({
    required this.question,
    required this.answer,
  });
}

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<FAQEntry> _staticFAQs = [
    FAQEntry(
      question: 'How do I personalize my profile?',
      answer:
          'You can update your avatar, name, and bio by tapping "Edit Profile" on your profile page. You can also pick and like your favorite fandoms to customize your experience.',
    ),
    FAQEntry(
      question: 'How does content filtering work?',
      answer:
          'Content filtering uses your selected fandom preferences to show you relevant posts, news, and lore on your home feed. You can update your preferences anytime from settings or the interest setup page.',
    ),
    FAQEntry(
      question: 'Can I use the app offline?',
      answer:
          'Yes! Fandom Verse uses local SQLite storage. All previously loaded posts, glossary terms, and lore content remain accessible even when you don\'t have an internet connection.',
    ),
    FAQEntry(
      question: 'How do I bookmark content?',
      answer:
          'Tap the bookmark icon on any post or glossary term card to save it. You can access all your saved items anytime from the Bookmarks section.',
    ),
    FAQEntry(
      question: 'How do I report inappropriate content?',
      answer:
          'To report inappropriate content or behavior, contact our moderation team via the Contact Us page or report button on the respective post.',
    ),
    FAQEntry(
      question: 'How do I purchase merchandise?',
      answer:
          'Visit the Merch Store tab from Quick Access or navigation to explore exclusive fan merchandise, collectibles, and apparel.',
    ),
    FAQEntry(
      question: 'How do I RSVP to conventions?',
      answer:
          'Browse the Events section to discover conventions, fan meetups, and exhibitions. Tap on any event to view details and secure your ticket or RSVP.',
    ),
    FAQEntry(
      question: 'I found a bug. Where do I report it?',
      answer:
          'You can submit bug reports and feedback through the "Contact Us" or "About Us" section in your profile settings, or reach out to our support team.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FAQEntry> get _filteredFAQs {
    if (_searchQuery.trim().isEmpty) {
      return _staticFAQs;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _staticFAQs.where((faq) {
      return faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _filteredFAQs;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                hintText: 'Search FAQ questions or answers...',
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // FAQ List
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.search_status,
                            size: 48,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No matching FAQ found',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try searching with different keywords',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final faq = results[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            key: PageStorageKey(faq.question),
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            childrenPadding: const EdgeInsets.fromLTRB(
                                16, 0, 16, 16),
                            title: Text(
                              faq.question,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            iconColor: AppColors.comicRed,
                            collapsedIconColor: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            children: [
                              Text(
                                faq.answer,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  height: 1.5,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.comicBlack,
                                ),
                              ),
                            ],
                          ),
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
