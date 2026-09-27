import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fandom_verse/features/fandom_hub/domain/entities/interview_entity.dart';

void main() {
  group('InterviewEntity', () {
    test('should create InterviewEntity with all fields', () {
      final questions = [
        const QuestionAnswer(
          question: 'What inspired you?',
          answer: 'My childhood experiences.',
        ),
        const QuestionAnswer(
          question: 'What is your favorite character?',
          answer: 'The protagonist.',
        ),
      ];

      final interview = InterviewEntity(
        id: 'int_1',
        intervieweeName: 'John Doe',
        roleTitle: 'Voice Actor',
        fandomCategory: 'Anime',
        interviewDate: 1234567890,
        questions: questions,
        imageUrl: 'https://example.com/image.jpg',
        createdAt: 1234567890,
      );

      expect(interview.id, 'int_1');
      expect(interview.intervieweeName, 'John Doe');
      expect(interview.roleTitle, 'Voice Actor');
      expect(interview.fandomCategory, 'Anime');
      expect(interview.interviewDate, 1234567890);
      expect(interview.questions.length, 2);
      expect(interview.questions[0].question, 'What inspired you?');
      expect(interview.questions[0].answer, 'My childhood experiences.');
      expect(interview.imageUrl, 'https://example.com/image.jpg');
      expect(interview.createdAt, 1234567890);
    });

    test('should serialize to database map correctly', () {
      final questions = [
        const QuestionAnswer(
          question: 'What inspired you?',
          answer: 'My childhood experiences.',
        ),
        const QuestionAnswer(
          question: 'What is your favorite character?',
          answer: 'The protagonist.',
        ),
      ];

      final interview = InterviewEntity(
        id: 'int_1',
        intervieweeName: 'John Doe',
        roleTitle: 'Voice Actor',
        fandomCategory: 'Anime',
        interviewDate: 1234567890,
        questions: questions,
        imageUrl: 'https://example.com/image.jpg',
        createdAt: 1234567890,
      );

      final map = interview.toDbMap();

      expect(map['interview_id'], 'int_1');
      expect(map['interviewee_name'], 'John Doe');
      expect(map['role_title'], 'Voice Actor');
      expect(map['fandom_category'], 'Anime');
      expect(map['interview_date'], 1234567890);
      expect(map['image_url'], 'https://example.com/image.jpg');
      expect(map['created_at'], 1234567890);

      // Verify questions_json is properly encoded
      final questionsJson = map['questions_json'] as String;
      final decodedQuestions = jsonDecode(questionsJson) as List<dynamic>;
      expect(decodedQuestions.length, 2);
      expect(decodedQuestions[0]['question'], 'What inspired you?');
      expect(decodedQuestions[0]['answer'], 'My childhood experiences.');
      expect(decodedQuestions[1]['question'], 'What is your favorite character?');
      expect(decodedQuestions[1]['answer'], 'The protagonist.');
    });

    test('should deserialize from database map correctly', () {
      final questionsJson = jsonEncode([
        {'question': 'What inspired you?', 'answer': 'My childhood experiences.'},
        {'question': 'What is your favorite character?', 'answer': 'The protagonist.'},
      ]);

      final map = {
        'interview_id': 'int_1',
        'interviewee_name': 'John Doe',
        'role_title': 'Voice Actor',
        'fandom_category': 'Anime',
        'interview_date': 1234567890,
        'questions_json': questionsJson,
        'image_url': 'https://example.com/image.jpg',
        'created_at': 1234567890,
      };

      final interview = InterviewEntity.fromDbMap(map);

      expect(interview.id, 'int_1');
      expect(interview.intervieweeName, 'John Doe');
      expect(interview.roleTitle, 'Voice Actor');
      expect(interview.fandomCategory, 'Anime');
      expect(interview.interviewDate, 1234567890);
      expect(interview.questions.length, 2);
      expect(interview.questions[0].question, 'What inspired you?');
      expect(interview.questions[0].answer, 'My childhood experiences.');
      expect(interview.questions[1].question, 'What is your favorite character?');
      expect(interview.questions[1].answer, 'The protagonist.');
      expect(interview.imageUrl, 'https://example.com/image.jpg');
      expect(interview.createdAt, 1234567890);
    });

    test('should handle null imageUrl', () {
      final questionsJson = jsonEncode([
        {'question': 'Test question?', 'answer': 'Test answer.'},
      ]);

      final map = {
        'interview_id': 'int_2',
        'interviewee_name': 'Jane Smith',
        'role_title': 'Director',
        'fandom_category': 'Movies',
        'interview_date': 1234567890,
        'questions_json': questionsJson,
        'image_url': null,
        'created_at': 1234567890,
      };

      final interview = InterviewEntity.fromDbMap(map);

      expect(interview.imageUrl, isNull);
    });

    test('should handle empty questions_json', () {
      final map = {
        'interview_id': 'int_3',
        'interviewee_name': 'Test Person',
        'role_title': 'Creator',
        'fandom_category': 'Comics',
        'interview_date': 1234567890,
        'questions_json': '[]',
        'created_at': 1234567890,
      };

      final interview = InterviewEntity.fromDbMap(map);

      expect(interview.questions.length, 0);
      expect(interview.questions, isEmpty);
    });

    test('should handle malformed questions_json gracefully', () {
      final map = {
        'interview_id': 'int_4',
        'interviewee_name': 'Test Person',
        'role_title': 'Creator',
        'fandom_category': 'Comics',
        'interview_date': 1234567890,
        'questions_json': 'invalid json',
        'created_at': 1234567890,
      };

      final interview = InterviewEntity.fromDbMap(map);

      // Should return empty list when JSON parsing fails
      expect(interview.questions, isEmpty);
    });

    test('should support round-trip serialization', () {
      final original = InterviewEntity(
        id: 'int_5',
        intervieweeName: 'Alice Johnson',
        roleTitle: 'Writer',
        fandomCategory: 'Books',
        interviewDate: 1234567890,
        questions: [
          const QuestionAnswer(
            question: 'How do you approach character development?',
            answer: 'I focus on their motivations and backstory.',
          ),
        ],
        imageUrl: 'https://example.com/alice.jpg',
        createdAt: 1234567890,
      );

      final map = original.toDbMap();
      final deserialized = InterviewEntity.fromDbMap(map);

      expect(deserialized.id, original.id);
      expect(deserialized.intervieweeName, original.intervieweeName);
      expect(deserialized.roleTitle, original.roleTitle);
      expect(deserialized.fandomCategory, original.fandomCategory);
      expect(deserialized.interviewDate, original.interviewDate);
      expect(deserialized.questions.length, original.questions.length);
      expect(deserialized.questions[0].question, original.questions[0].question);
      expect(deserialized.questions[0].answer, original.questions[0].answer);
      expect(deserialized.imageUrl, original.imageUrl);
      expect(deserialized.createdAt, original.createdAt);
    });

    test('should use copyWith correctly', () {
      final original = InterviewEntity(
        id: 'int_6',
        intervieweeName: 'Bob Williams',
        roleTitle: 'Producer',
        fandomCategory: 'TV Shows',
        interviewDate: 1234567890,
        questions: [
          const QuestionAnswer(question: 'Q1', answer: 'A1'),
        ],
        imageUrl: 'https://example.com/bob.jpg',
        createdAt: 1234567890,
      );

      final updated = original.copyWith(
        intervieweeName: 'Robert Williams',
        roleTitle: 'Executive Producer',
      );

      expect(updated.id, original.id);
      expect(updated.intervieweeName, 'Robert Williams');
      expect(updated.roleTitle, 'Executive Producer');
      expect(updated.fandomCategory, original.fandomCategory);
      expect(updated.interviewDate, original.interviewDate);
      expect(updated.questions, original.questions);
    });
  });

  group('QuestionAnswer', () {
    test('should create QuestionAnswer correctly', () {
      const qa = QuestionAnswer(
        question: 'What is your favorite project?',
        answer: 'The latest animated series.',
      );

      expect(qa.question, 'What is your favorite project?');
      expect(qa.answer, 'The latest animated series.');
    });

    test('should support equality comparison', () {
      const qa1 = QuestionAnswer(
        question: 'Question 1',
        answer: 'Answer 1',
      );

      const qa2 = QuestionAnswer(
        question: 'Question 1',
        answer: 'Answer 1',
      );

      const qa3 = QuestionAnswer(
        question: 'Question 2',
        answer: 'Answer 2',
      );

      expect(qa1, equals(qa2));
      expect(qa1, isNot(equals(qa3)));
    });
  });
}
