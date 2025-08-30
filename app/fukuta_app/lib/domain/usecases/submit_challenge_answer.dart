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
    // Submeter resposta
    await challengeRepository.submitAnswer(questionId, answer, timeSpent);
    
    // Verificar se está correto
    final isCorrect = question.isCorrect(answer);
    
    // Calcular pontos
    final points = question.calculatePoints(timeSpent, answer);
    
    // Atualizar progresso
    if (isCorrect) {
      await progressRepository.addPoints(points, question.category, question.difficulty);
    }
    
    await progressRepository.recordAnswer(isCorrect, question.category, question.difficulty);
    
    return {
      'isCorrect': isCorrect,
      'points': points,
      'explanation': question.explanation,
      'correctAnswer': question.correctAnswer,
    };
  }
}
