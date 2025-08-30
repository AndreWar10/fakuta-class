import 'package:flutter/material.dart';

import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  QuestionModel({
    required super.id,
    required super.question,
    required super.correctAnswer,
    required super.wrongAnswers,
    required super.explanation,
    required super.difficulty,
    required super.category,
    required super.points,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 QuestionModel.fromJson: $json');
    
    final result = QuestionModel(
      id: json['id'] as int,
      question: json['question'] as String,
      correctAnswer: json['correct_answer'] as String,
      wrongAnswers: List<String>.from(json['wrong_answers']),
      explanation: json['explanation'] as String? ?? '',
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
      points: json['points'] as int,
    );
    
    debugPrint('🔍 QuestionModel criado: ID=${result.id}, Pergunta="${result.question}", Resposta correta="${result.correctAnswer}", Pontos=${result.points}');
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'correct_answer': correctAnswer,
      'wrong_answers': wrongAnswers,
      'explanation': explanation,
      'difficulty': difficulty,
      'category': category,
      'points': points,
    };
  }

  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      question: question.question,
      correctAnswer: question.correctAnswer,
      wrongAnswers: question.wrongAnswers,
      explanation: question.explanation,
      difficulty: question.difficulty,
      category: question.category,
      points: question.points,
    );
  }
}
