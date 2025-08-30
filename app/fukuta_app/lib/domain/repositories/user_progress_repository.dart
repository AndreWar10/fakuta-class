import '../entities/user_progress.dart';

abstract class UserProgressRepository {
  Future<UserProgress> getUserProgress();
  Future<void> updateUserProgress(UserProgress progress);
  Future<void> addPoints(int points, String category, String difficulty);
  Future<void> recordAnswer(bool isCorrect, String category, String difficulty);
  Future<void> unlockAchievement(int achievementId);
  Future<void> resetProgress();
}
