import 'dart:convert';
import 'package:equatable/equatable.dart';

class InterviewEntity extends Equatable {
  final String id;
  final String intervieweeName;
  final String roleTitle;
  final String fandomCategory;
  final int interviewDate;
  final List<QuestionAnswer> questions;
  final String? imageUrl;
  final int createdAt;

  const InterviewEntity({
    required this.id,
    required this.intervieweeName,
    required this.roleTitle,
    required this.fandomCategory,
    required this.interviewDate,
    required this.questions,
    this.imageUrl,
    required this.createdAt,
  });

  InterviewEntity copyWith({
    String? id,
    String? intervieweeName,
    String? roleTitle,
    String? fandomCategory,
    int? interviewDate,
    List<QuestionAnswer>? questions,
    String? imageUrl,
    int? createdAt,
  }) {
    return InterviewEntity(
      id: id ?? this.id,
      intervieweeName: intervieweeName ?? this.intervieweeName,
      roleTitle: roleTitle ?? this.roleTitle,
      fandomCategory: fandomCategory ?? this.fandomCategory,
      interviewDate: interviewDate ?? this.interviewDate,
      questions: questions ?? this.questions,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory InterviewEntity.fromDbMap(Map<String, dynamic> map) {
    // Parse questions_json field
    final questionsJson = map['questions_json'] as String? ?? '[]';
    List<QuestionAnswer> questions = [];
    
    try {
      final List<dynamic> questionsData = jsonDecode(questionsJson);
      questions = questionsData
          .map((q) => QuestionAnswer(
                question: (q['question'] ?? '').toString(),
                answer: (q['answer'] ?? '').toString(),
              ))
          .toList();
    } catch (e) {
      // If parsing fails, return empty list
      questions = [];
    }

    return InterviewEntity(
      id: (map['interview_id'] ?? '').toString(),
      intervieweeName: (map['interviewee_name'] ?? '').toString(),
      roleTitle: (map['role_title'] ?? '').toString(),
      fandomCategory: (map['fandom_category'] ?? '').toString(),
      interviewDate: (map['interview_date'] as num?)?.toInt() ?? 0,
      questions: questions,
      imageUrl: map['image_url']?.toString(),
      createdAt: (map['created_at'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toDbMap() {
    // Encode questions list to JSON string
    final questionsJson = jsonEncode(
      questions
          .map((q) => {
                'question': q.question,
                'answer': q.answer,
              })
          .toList(),
    );

    return {
      'interview_id': id,
      'interviewee_name': intervieweeName,
      'role_title': roleTitle,
      'fandom_category': fandomCategory,
      'interview_date': interviewDate,
      'questions_json': questionsJson,
      'image_url': imageUrl,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        intervieweeName,
        roleTitle,
        fandomCategory,
        interviewDate,
        questions,
        imageUrl,
        createdAt,
      ];
}

class QuestionAnswer extends Equatable {
  final String question;
  final String answer;

  const QuestionAnswer({
    required this.question,
    required this.answer,
  });

  @override
  List<Object?> get props => [question, answer];
}
