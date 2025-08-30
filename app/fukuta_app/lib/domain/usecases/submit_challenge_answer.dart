import 'package:flutter/material.dart';

import '../entities/question.dart';
import '../repositories/challenge_repository.dart';
import '../repositories/user_progress_repository.dart';

class SubmitChallengeAnswer {
  final ChallengeRepository challengeRepository;
  final UserProgressRepository progressRepository;

  SubmitChallengeAnswer(this.challengeRepository, this.progressRepository);

  Future<Map<String, dynamic>> call({
    required int questionId,
    required String answer,
    required int timeSpent,
    required Question question,
  }) async {
    debugPrint('🔍 SubmitChallengeAnswer: ID=$questionId, resposta="$answer", tempo=$timeSpent');
    debugPrint('🔍 Pergunta: "${question.question}"');
    debugPrint('🔍 Resposta correta: "${question.correctAnswer}"');
    
    // Submeter resposta
    await challengeRepository.submitAnswer(questionId, answer, timeSpent);
    
    // Verificar se está correto
    final isCorrect = question.isCorrect(answer);
    debugPrint('🔍 Resposta está correta: $isCorrect');
    
    // Calcular pontos
    final points = question.calculatePoints(timeSpent, answer);
    debugPrint('🔍 Pontos calculados: $points');
    
    // Atualizar progresso
    if (isCorrect) {
      debugPrint('🔍 Adicionando $points pontos para categoria ${question.category} e dificuldade ${question.difficulty}');
      await progressRepository.addPoints(points, question.category, question.difficulty);
    }
    
    debugPrint('🔍 Registrando resposta: correta=$isCorrect, categoria=${question.category}, dificuldade=${question.difficulty}');
    await progressRepository.recordAnswer(isCorrect, question.category, question.difficulty);
    
    final result = {
      'isCorrect': isCorrect,
      'points': points,
      'explanation': question.explanation,
      'correctAnswer': question.correctAnswer,
    };
    
    debugPrint('🔍 Resultado final: $result');
    return result;
  }
}
