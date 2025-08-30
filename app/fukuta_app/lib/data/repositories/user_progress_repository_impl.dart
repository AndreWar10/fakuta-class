import '../../domain/entities/user_progress.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/repositories/user_progress_repository.dart';
import '../datasources/local/challenge_local_data_source.dart';
import '../models/user_progress_model.dart';

class UserProgressRepositoryImpl implements UserProgressRepository {
  final ChallengeLocalDataSource localDataSource;

  UserProgressRepositoryImpl(this.localDataSource);

  @override
  Future<UserProgress> getUserProgress() async {
    final cachedProgress = await localDataSource.getUserProgress();
    return cachedProgress ?? UserProgressModel.initial();
  }

  @override
  Future<void> updateUserProgress(UserProgress progress) async {
    final progressModel = UserProgressModel.fromEntity(progress);
    await localDataSource.saveUserProgress(progressModel);
  }

  @override
  Future<void> addPoints(int points, String category, String difficulty) async {
    final currentProgress = await getUserProgress();
    
    final newCategoryPoints = Map<String, int>.from(currentProgress.categoryPoints);
    final newDifficultyPoints = Map<String, int>.from(currentProgress.difficultyPoints);
    
    newCategoryPoints[category] = (newCategoryPoints[category] ?? 0) + points;
    newDifficultyPoints[difficulty] = (newDifficultyPoints[difficulty] ?? 0) + points;
    
    final updatedProgress = currentProgress.copyWith(
      totalPoints: currentProgress.totalPoints + points,
      categoryPoints: newCategoryPoints,
      difficultyPoints: newDifficultyPoints,
      lastPlayed: DateTime.now(),
    );
    
    await updateUserProgress(updatedProgress);
  }

  @override
  Future<void> recordAnswer(bool isCorrect, String category, String difficulty) async {
    final currentProgress = await getUserProgress();
    
    final updatedProgress = currentProgress.copyWith(
      questionsAnswered: currentProgress.questionsAnswered + 1,
      correctAnswers: currentProgress.correctAnswers + (isCorrect ? 1 : 0),
      lastPlayed: DateTime.now(),
    );
    
    await updateUserProgress(updatedProgress);
  }

  @override
  Future<void> unlockAchievement(int achievementId) async {
    // Esta funcionalidade pode ser implementada se necessário
    // Por enquanto, as conquistas são desbloqueadas automaticamente baseadas nos pontos
  }

  @override
  Future<void> resetProgress() async {
    final initialProgress = UserProgressModel.initial();
    await localDataSource.saveUserProgress(initialProgress);
  }
}
