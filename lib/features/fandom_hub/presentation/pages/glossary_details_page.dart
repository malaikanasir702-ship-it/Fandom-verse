import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/glossary_term.dart';
import '../bloc/fandom_hub_bloc.dart';
import '../bloc/fandom_hub_event.dart';
import '../bloc/fandom_hub_state.dart';

class Share {
  static void share(String text) {
    // Shared text representation
  }
}

class GlossaryDetailsPage extends StatefulWidget {
  final GlossaryTerm term;

  const GlossaryDetailsPage({
    super.key,
    required this.term,
  });

  @override
  State<GlossaryDetailsPage> createState() => _GlossaryDetailsPageState();
}

class _GlossaryDetailsPageState extends State<GlossaryDetailsPage> {
  late GlossaryTerm _currentTerm;
  List<GlossaryTerm> _relatedTerms = [];
  bool _isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    _currentTerm = widget.term;
    _loadRelatedTerms();
  }

  @override
  void didUpdateWidget(covariant GlossaryDetailsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.term.id != widget.term.id) {
      _currentTerm = widget.term;
      _loadRelatedTerms();
    }
  }

  Future<void> _loadRelatedTerms() async {
    setState(() => _isLoadingRelated = true);
    try {
      final rows = await SqliteHelper.instance.query(
        DbConstants.tableGlossary,
        where: 'fandom_category = ? AND term_id != ?',
        whereArgs: [_currentTerm.fandomCategory, _currentTerm.id],
        limit: 5,
      );
      if (mounted) {
        setState(() {
          _relatedTerms = rows.map((m) => GlossaryTerm.fromDbMap(m)).toList();
          _isLoadingRelated = false;
        });
      }
    } catch (_) {
      // Fallback from BLoC state if available
      if (mounted) {
        final hubState = context.read<FandomHubBloc>().state;
        if (hubState is FandomHubLoaded) {
          _relatedTerms = hubState.glossary
              .where((t) =>
                  t.fandomCategory == _currentTerm.fandomCategory &&
                  t.id != _currentTerm.id)
              .take(5)
              .toList();
        }
        setState(() => _isLoadingRelated = false);
      }
    }
  }

  void _shareTerm() {
    final text = '${_currentTerm.term}: ${_currentTerm.definition}';
    Share.share(text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${_currentTerm.term}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleBookmark() {
    final newStatus = !_currentTerm.isBookmarked;
    setState(() {
      _currentTerm = _currentTerm.copyWith(isBookmarked: newStatus);
    });
    context.read<FandomHubBloc>().add(
          ToggleBookmarkGlossaryEvent(_currentTerm.id),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus ? 'Added to bookmarks' : 'Removed from bookmarks',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildExampleUsage(String example, String term, bool isDark) {
    if (example.isEmpty) {
      return const SizedBox.shrink();
    }

    final lowerExample = example.toLowerCase();
    final lowerTerm = term.toLowerCase();
    final startIndex = lowerExample.indexOf(lowerTerm);

    if (startIndex == -1) {
      return Text(
        example,
        style: AppTextStyles.bodyMedium.copyWith(
          fontStyle: FontStyle.italic,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      );
    }

    final before = example.substring(0, startIndex);
    final match = example.substring(startIndex, startIndex + term.length);
    final after = example.substring(startIndex + term.length);

    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyMedium.copyWith(
          fontStyle: FontStyle.italic,
          color: isDark ? AppColors.darkText : AppColors.comicBlack,
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: const TextStyle(
              color: AppColors.comicRed,
              fontWeight: FontWeight.w800,
              backgroundColor: Color(0x22E53935),
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<FandomHubBloc, FandomHubState>(
      listener: (context, state) {
        if (state is FandomHubLoaded) {
          final updated = state.glossary.firstWhere(
            (t) => t.id == _currentTerm.id,
            orElse: () => _currentTerm,
          );
          if (updated.isBookmarked != _currentTerm.isBookmarked) {
            setState(() {
              _currentTerm = updated;
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _currentTerm.term,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.share),
              tooltip: 'Share Term',
              onPressed: _shareTerm,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleBookmark,
          backgroundColor: AppColors.comicRed,
          tooltip: _currentTerm.isBookmarked ? 'Remove Bookmark' : 'Bookmark Term',
          child: Icon(
            _currentTerm.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: Colors.white,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Hero Section: Term Name & Phonetic
            GlassContainer(
              padding: const EdgeInsets.all(20),
              borderColor: AppColors.comicRed.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _currentTerm.term,
                          style: AppTextStyles.displaySmall.copyWith(
                            color: AppColors.comicRed,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      // Fandom category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.comicRed.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.comicRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          _currentTerm.fandomCategory.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.comicRed,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_currentTerm.phonetic.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _currentTerm.phonetic,
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Definition Section
            Text(
              'DEFINITION',
              style: AppTextStyles.comicSectionHeader.copyWith(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GlassContainer(
              padding: const EdgeInsets.all(18),
              child: Text(
                _currentTerm.definition,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.6,
                  fontSize: 15,
                  color: isDark ? AppColors.darkText : AppColors.comicBlack,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Example Usage Section
            if (_currentTerm.exampleUsage.isNotEmpty) ...[
              Text(
                'EXAMPLE USAGE',
                style: AppTextStyles.comicSectionHeader.copyWith(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              GlassContainer(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.quote_up,
                      size: 20,
                      color: AppColors.comicRed,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildExampleUsage(
                        _currentTerm.exampleUsage,
                        _currentTerm.term,
                        isDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Related Terms Section
            Text(
              'RELATED TERMS',
              style: AppTextStyles.comicSectionHeader.copyWith(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoadingRelated)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_relatedTerms.isEmpty)
              Text(
                'No related terms found in this category.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _relatedTerms.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final rel = _relatedTerms[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GlossaryDetailsPage(term: rel),
                          ),
                        );
                      },
                      child: Container(
                        width: 180,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rel.term,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.comicRed,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            if (rel.phonetic.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                rel.phonetic,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                rel.definition,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
