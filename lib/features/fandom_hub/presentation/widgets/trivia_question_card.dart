import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';

class TriviaQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  const TriviaQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  factory TriviaQuestion.fromMap(Map<String, dynamic> map) {
    return TriviaQuestion(
      question: (map['q'] ?? map['question'] ?? '').toString(),
      options: (map['options'] as List? ?? []).map((e) => e.toString()).toList(),
      correctAnswerIndex: (map['answer'] ?? map['correctAnswerIndex'] ?? 0) as int,
      explanation: (map['explanation'] ?? '').toString(),
    );
  }
}

class TriviaQuestionCard extends StatefulWidget {
  final TriviaQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const TriviaQuestionCard({
    super.key,
    required this.question,
    this.questionNumber = 1,
    this.totalQuestions = 1,
    required this.onAnswerSelected,
  });

  @override
  State<TriviaQuestionCard> createState() => _TriviaQuestionCardState();
}

class _TriviaQuestionCardState extends State<TriviaQuestionCard> {
  int? _selectedIndex;
  bool _showResults = false;

  @override
  void didUpdateWidget(covariant TriviaQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.question != widget.question.question) {
      _selectedIndex = null;
      _showResults = false;
    }
  }

  Color _getOptionColor(int index) {
    if (!_showResults) return Colors.transparent;
    if (index == widget.question.correctAnswerIndex) {
      return AppColors.success.withValues(alpha: 0.15);
    }
    if (index == _selectedIndex && index != widget.question.correctAnswerIndex) {
      return AppColors.error.withValues(alpha: 0.15);
    }
    return Colors.transparent;
  }

  Color _getOptionBorderColor(int index, bool isDark) {
    if (!_showResults) {
      return isDark ? AppColors.darkBorder : AppColors.lightBorder;
    }
    if (index == widget.question.correctAnswerIndex) {
      return AppColors.success;
    }
    if (index == _selectedIndex && index != widget.question.correctAnswerIndex) {
      return AppColors.error;
    }
    return isDark ? AppColors.darkBorder : AppColors.lightBorder;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Card
        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.comicRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Q${widget.questionNumber} of ${widget.totalQuestions}',
                  style: const TextStyle(
                    color: AppColors.comicRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.question.question,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Option tiles
        ...List.generate(widget.question.options.length, (i) {
          final optionText = widget.question.options[i];
          final bgColor = _getOptionColor(i);
          final borderColor = _getOptionBorderColor(i, isDark);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: _showResults
                  ? null
                  : () {
                      setState(() {
                        _selectedIndex = i;
                        _showResults = true;
                      });
                      widget.onAnswerSelected(
                        i,
                        i == widget.question.correctAnswerIndex,
                      );
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _showResults
                      ? bgColor
                      : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: borderColor,
                    width: _showResults &&
                            (i == widget.question.correctAnswerIndex ||
                                i == _selectedIndex)
                        ? 1.5
                        : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _showResults && i == widget.question.correctAnswerIndex
                            ? AppColors.success
                            : _showResults && i == _selectedIndex
                                ? AppColors.error
                                : (isDark
                                    ? AppColors.darkBackground
                                    : AppColors.lightBackground),
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + i), // A, B, C, D
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _showResults &&
                                    (i == widget.question.correctAnswerIndex ||
                                        i == _selectedIndex)
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        optionText,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark ? AppColors.darkText : AppColors.comicBlack,
                        ),
                      ),
                    ),
                    if (_showResults && i == widget.question.correctAnswerIndex)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 20)
                    else if (_showResults && i == _selectedIndex)
                      const Icon(Icons.cancel_rounded,
                          color: AppColors.error, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),

        // Explanation text after selection
        if (_showResults && widget.question.explanation.isNotEmpty) ...[
          const SizedBox(height: 6),
          GlassContainer(
            padding: const EdgeInsets.all(14),
            borderColor: AppColors.darkAccentGold.withValues(alpha: 0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Iconsax.info_circle,
                  size: 18,
                  color: AppColors.darkAccentGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.question.explanation,
                    style: const TextStyle(height: 1.5, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
