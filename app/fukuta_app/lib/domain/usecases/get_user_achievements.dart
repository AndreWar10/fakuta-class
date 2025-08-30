import '../entities/achievement.dart';
import '../repositories/achievement_repository.dart';
import '../repositories/user_progress_repository.dart';

class GetUserAchievements {
  final AchievementRepository achievementRepository;
  final UserProgressRepository progressRepository;

  GetUserAchievements(this.achievementRepository, this.progressRepository);

  Future<Map<String, dynamic>> call() async {
    final progress = await progressRepository.getUserProgress();
    final allAchievements = await achievementRepository.getAllAchievements();
    final unlockedAchievements = await achievementRepository.getAchievementsByPoints(progress.totalPoints);
    final nextAchievement = await achievementRepository.getNextAchievement(progress.totalPoints);
    final progressToNext = await achievementRepository.getProgressToNextAchievement(progress.totalPoints);
    
    return {
      'currentPoints': progress.totalPoints,
      'unlockedAchievements': unlockedAchievements,
      'lockedAchievements': allAchievements.where((a) => !unlockedAchievements.contains(a)).toList(),
      'nextAchievement': nextAchievement,
      'progressToNext': progressToNext,
      'totalAchievements': allAchievements.length,
      'unlockedCount': unlockedAchievements.length,
    };
  }
}
