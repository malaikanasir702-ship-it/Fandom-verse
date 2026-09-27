import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse/features/fandom_hub/domain/entities/glossary_term.dart';

void main() {
  group('GlossaryTerm Serialization', () {
    test('round-trip serialization preserves all fields', () {
      const term = GlossaryTerm(
        id: 'term_1',
        term: 'Muggle',
        definition: 'A person without magical powers',
        fandomCategory: 'harry_potter',
        exampleUsage: 'He was raised by Muggles.',
        phonetic: '/ˈmʌɡ.əl/',
        isBookmarked: true,
      );

      final map = term.toMap();
      final restored = GlossaryTerm.fromMap(map);

      expect(restored, equals(term));
      expect(restored.id, 'term_1');
      expect(restored.term, 'Muggle');
      expect(restored.definition, 'A person without magical powers');
      expect(restored.fandomCategory, 'harry_potter');
      expect(restored.exampleUsage, 'He was raised by Muggles.');
      expect(restored.phonetic, '/ˈmʌɡ.əl/');
      expect(restored.isBookmarked, isTrue);
    });

    test('fromMap handles null phonetic with default empty string', () {
      final map = {
        'term_id': 'term_2',
        'term': 'Jedi',
        'definition': 'Guardians of peace',
        'phonetic': null,
      };

      final term = GlossaryTerm.fromMap(map);
      expect(term.phonetic, '');
    });

    test('fromMap converts INTEGER is_bookmarked (1 and 0) to boolean', () {
      final mapBookmarked = {
        'term_id': 'term_3',
        'term': 'Quirk',
        'is_bookmarked': 1,
      };
      final term1 = GlossaryTerm.fromMap(mapBookmarked);
      expect(term1.isBookmarked, isTrue);

      final mapNotBookmarked = {
        'term_id': 'term_4',
        'term': 'Bankai',
        'is_bookmarked': 0,
      };
      final term2 = GlossaryTerm.fromMap(mapNotBookmarked);
      expect(term2.isBookmarked, isFalse);
    });

    test('fromMap throws FormatException when term_id is missing', () {
      final map = {
        'term': 'Titan',
        'definition': 'Giant humanoid',
      };

      expect(() => GlossaryTerm.fromMap(map), throwsFormatException);
    });

    test('fromMap throws FormatException when term is missing', () {
      final map = {
        'term_id': 'term_5',
        'definition': 'Giant humanoid',
      };

      expect(() => GlossaryTerm.fromMap(map), throwsFormatException);
    });

    test('fromMap throws FormatException for invalid field type', () {
      final map = {
        'term_id': 'term_6',
        'term': 12345, // invalid type for term
      };

      expect(() => GlossaryTerm.fromMap(map as dynamic), throwsFormatException);
    });

    test('toMap converts boolean is_bookmarked to INTEGER (0/1)', () {
      const termBookmarked = GlossaryTerm(
        id: 't1',
        term: 'Chakra',
        definition: 'Energy',
        fandomCategory: 'naruto',
        exampleUsage: 'Mold chakra',
        phonetic: 'cha-kra',
        isBookmarked: true,
      );
      expect(termBookmarked.toMap()['is_bookmarked'], 1);

      const termUnbookmarked = GlossaryTerm(
        id: 't2',
        term: 'Ki',
        definition: 'Life force',
        fandomCategory: 'dragon_ball',
        exampleUsage: 'Raise ki',
        phonetic: 'kee',
        isBookmarked: false,
      );
      expect(termUnbookmarked.toMap()['is_bookmarked'], 0);
    });
  });
}
