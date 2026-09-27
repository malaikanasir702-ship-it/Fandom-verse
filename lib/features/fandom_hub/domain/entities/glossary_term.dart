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

  factory GlossaryTerm.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('term_id') || !map.containsKey('term') || map['term_id'] == null || map['term'] == null) {
      throw const FormatException('Missing required fields: term_id or term');
    }

    if (map['term_id'] is! String && map['term_id'] is! num) {
      throw const FormatException('Invalid field type: term_id must be String or num');
    }
    if (map['term'] is! String) {
      throw const FormatException('Invalid field type: term must be String');
    }
    if (map['definition'] != null && map['definition'] is! String) {
      throw const FormatException('Invalid field type: definition must be String');
    }
    if (map['fandom_category'] != null && map['fandom_category'] is! String) {
      throw const FormatException('Invalid field type: fandom_category must be String');
    }
    if (map['example_usage'] != null && map['example_usage'] is! String) {
      throw const FormatException('Invalid field type: example_usage must be String');
    }
    if (map['phonetic'] != null && map['phonetic'] is! String) {
      throw const FormatException('Invalid field type: phonetic must be String');
    }
    if (map['is_bookmarked'] != null &&
        map['is_bookmarked'] is! num &&
        map['is_bookmarked'] is! bool) {
      throw const FormatException('Invalid field type: is_bookmarked must be num or bool');
    }

    bool isBookmarked = false;
    if (map['is_bookmarked'] is num) {
      isBookmarked = (map['is_bookmarked'] as num).toInt() == 1;
    } else if (map['is_bookmarked'] is bool) {
      isBookmarked = map['is_bookmarked'] as bool;
    }

    return GlossaryTerm(
      id: map['term_id'].toString(),
      term: map['term'].toString(),
      definition: (map['definition'] ?? '').toString(),
      fandomCategory: (map['fandom_category'] ?? '').toString(),
      exampleUsage: (map['example_usage'] ?? '').toString(),
      phonetic: (map['phonetic'] ?? '').toString(),
      isBookmarked: isBookmarked,
    );
  }

  factory GlossaryTerm.fromDbMap(Map<String, dynamic> map) => GlossaryTerm.fromMap(map);

  Map<String, dynamic> toMap() {
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

  Map<String, dynamic> toDbMap() => toMap();

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
