import '../entities/challenge.dart';
import '../entities/question.dart';

abstract class ChallengeRepository {
  Future<Challenge> getDailyChallenge();
  Future<Challenge> getQuickChallenge();
  Future<Challenge> getCategoryChallenge(String category);
  Future<List<Question>> getRandomQuestions(int count);
  Future<void> submitAnswer(int questionId, String answer, int timeSpent);
  Future<void> submitBatchAnswers(List<Map<String, dynamic>> answers);
}
