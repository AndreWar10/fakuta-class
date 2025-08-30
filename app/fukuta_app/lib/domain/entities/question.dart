// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

class Question {
  final int id;
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final String explanation;
  final String difficulty;
  final String category;
  final int points;

  Question({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
    required this.explanation,
    required this.difficulty,
    required this.category,
    required this.points,
  });

  List<String> get allAnswers {
    final answers = [correctAnswer, ...wrongAnswers];
    return answers;
  }

  bool isCorrect(String answer) {
    final result = answer.toLowerCase() == correctAnswer.toLowerCase();
    debugPrint('🔍 Question.isCorrect: "$answer" == "$correctAnswer" = $result');
    return result;
  }

  int calculatePoints(int timeSpent, String answer) {
    debugPrint('🔍 Question.calculatePoints: tempo=$timeSpent, resposta="$answer", pontos base=$points');
    
    if (!isCorrect(answer)) {
      debugPrint('🔍 Resposta incorreta, retornando 0 pontos');
      return 0;
    }
    
    int timeBonus = 0;
    if (timeSpent <= 10) timeBonus = 5;
    else if (timeSpent <= 20) timeBonus = 3;
    else if (timeSpent <= 30) timeBonus = 1;
    
    final totalPoints = points + timeBonus;
    debugPrint('🔍 Pontos calculados: base=$points + bonus=$timeBonus = $totalPoints');
    return totalPoints;
  }
}
