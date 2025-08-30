import '../../domain/entities/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../datasources/remote/challenge_remote_data_source.dart';
import '../datasources/local/challenge_local_data_source.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final ChallengeRemoteDataSource remoteDataSource;
  final ChallengeLocalDataSource localDataSource;

  AchievementRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<Achievement>> getAllAchievements() async {
    try {
      // Tentar buscar da API
      final achievements = await remoteDataSource.getAchievements();
      // Cache local
      await localDataSource.cacheAchievements(achievements);
      // AchievementModel herda de Achievement, então pode retornar diretamente
      return achievements;
    } catch (e) {
      // Fallback para cache local
      final cachedAchievements = await localDataSource.getCachedAchievements();
      // AchievementModel herda de Achievement, então pode retornar diretamente
      return cachedAchievements;
    }
  }

  @override
  Future<List<Achievement>> getAchievementsByPoints(int points) async {
    final allAchievements = await getAllAchievements();
    return allAchievements
        .where((a) => a.pointsRequired <= points)
        .toList()
      ..sort((a, b) => a.pointsRequired.compareTo(b.pointsRequired));
  }

  @override
  Future<List<Achievement>> getAchievementsByCategory(String category) async {
    final allAchievements = await getAllAchievements();
    return allAchievements
        .where((a) => a.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<Achievement?> getNextAchievement(int currentPoints) async {
    final allAchievements = await getAllAchievements();
    final lockedAchievements = allAchievements
        .where((a) => a.pointsRequired > currentPoints)
        .toList();
    
    if (lockedAchievements.isEmpty) return null;
    
    if (lockedAchievements.length == 1) {
      return lockedAchievements.first;
    }
    
    // Garantir que todos os elementos são do tipo Achievement
    final typedAchievements = lockedAchievements.cast<Achievement>();
    return typedAchievements
        .reduce((a, b) => a.pointsRequired < b.pointsRequired ? a : b);
  }

  @override
  Future<double> getProgressToNextAchievement(int currentPoints) async {
    final nextAchievement = await getNextAchievement(currentPoints);
    if (nextAchievement == null) return 1.0;
    
    final allAchievements = await getAllAchievements();
    final unlockedAchievements = allAchievements
        .where((a) => a.pointsRequired <= currentPoints)
        .toList();
    
    Achievement? previousAchievement;
    if (unlockedAchievements.isNotEmpty) {
      final filteredAchievements = unlockedAchievements
          .where((a) => a.pointsRequired < nextAchievement.pointsRequired)
          .toList();
      
      if (filteredAchievements.isNotEmpty) {
        // Garantir que todos os elementos são do tipo Achievement
        final typedFilteredAchievements = filteredAchievements.cast<Achievement>();
        previousAchievement = typedFilteredAchievements
            .reduce((a, b) => a.pointsRequired > b.pointsRequired ? a : b);
      }
    }
    
    if (previousAchievement != null) {
      final range = nextAchievement.pointsRequired - previousAchievement.pointsRequired;
      final progress = currentPoints - previousAchievement.pointsRequired;
      return (progress / range).clamp(0.0, 1.0);
    } else {
      return (currentPoints / nextAchievement.pointsRequired).clamp(0.0, 1.0);
    }
  }
}
