class GlossaryTerm {
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
}
