import 'package:equatable/equatable.dart';

class GlossaryTerm extends Equatable {
  final String id;
  final String term;
  final String definition;
  final String fandomCategory;
  final String exampleUsage;
  final String phonetic;
  final bool isBookmarked;

  const GlossaryTerm({
    required this.id,
    required this.term,
    required this.definition,
    required this.fandomCategory,
    required this.exampleUsage,
    required this.phonetic,
    this.isBookmarked = false,
  });

  GlossaryTerm copyWith({
    String? id,
    String? term,
    String? definition,
    String? fandomCategory,
    String? exampleUsage,
    String? phonetic,
    bool? isBookmarked,
  }) {
    return GlossaryTerm(
      id: id ?? this.id,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      fandomCategory: fandomCategory ?? this.fandomCategory,
      exampleUsage: exampleUsage ?? this.exampleUsage,
      phonetic: phonetic ?? this.phonetic,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  factory GlossaryTerm.fromDbMap(Map<String, dynamic> map) {
    return GlossaryTerm(
      id: (map['term_id'] ?? '').toString(),
      term: (map['term'] ?? '').toString(),
      definition: (map['definition'] ?? '').toString(),
      fandomCategory: (map['fandom_category'] ?? '').toString(),
      exampleUsage: (map['example_usage'] ?? '').toString(),
      phonetic: (map['phonetic'] ?? '').toString(),
      isBookmarked: (map['is_bookmarked'] as num?)?.toInt() == 1,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'term_id': id,
      'term': term,
      'definition': definition,
      'fandom_category': fandomCategory,
      'example_usage': exampleUsage,
      'phonetic': phonetic,
      'is_bookmarked': isBookmarked ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [
        id,
        term,
        definition,
        fandomCategory,
        exampleUsage,
        phonetic,
        isBookmarked,
      ];
}
