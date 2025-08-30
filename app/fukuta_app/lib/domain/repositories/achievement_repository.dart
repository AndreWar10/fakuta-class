import '../entities/achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAllAchievements();
  Future<List<Achievement>> getAchievementsByPoints(int points);
  Future<List<Achievement>> getAchievementsByCategory(String category);
  Future<Achievement?> getNextAchievement(int currentPoints);
  Future<double> getProgressToNextAchievement(int currentPoints);
}
