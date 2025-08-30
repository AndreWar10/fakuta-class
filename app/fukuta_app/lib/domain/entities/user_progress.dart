import 'achievement.dart';

class UserProgress {
  final int totalPoints;
  final int questionsAnswered;
  final int correctAnswers;
  final List<Achievement> unlockedAchievements;
  final Map<String, int> categoryPoints;
  final Map<String, int> difficultyPoints;
  final DateTime lastPlayed;

  UserProgress({
    required this.totalPoints,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.unlockedAchievements,
    required this.categoryPoints,
    required this.difficultyPoints,
    required this.lastPlayed,
  });

  double get accuracy {
    if (questionsAnswered == 0) return 0.0;
    return correctAnswers / questionsAnswered;
  }

  String get accuracyText {
    return '${(accuracy * 100).toStringAsFixed(1)}%';
  }

  String get level {
    if (totalPoints >= 1000) return 'Lenda do Cosmos 🌟';
    if (totalPoints >= 500) return 'Sábio Espacial ⭐';
    if (totalPoints >= 200) return 'Mestre do Sistema Solar 🚀';
    if (totalPoints >= 50) return 'Astrônomo Amador 🔭';
    if (totalPoints >= 10) return 'Explorador Iniciante 🌍';
    return 'Novato Espacial 🚀';
  }

  int get levelNumber {
    if (totalPoints >= 1000) return 5;
    if (totalPoints >= 500) return 4;
    if (totalPoints >= 200) return 3;
    if (totalPoints >= 50) return 2;
    if (totalPoints >= 10) return 1;
    return 0;
  }

  double get levelProgress {
    final levels = [0, 10, 50, 200, 500, 1000];
    final currentLevel = levelNumber;
    final currentLevelPoints = levels[currentLevel];
    final nextLevelPoints = levels[currentLevel + 1];
    
    if (nextLevelPoints == null) return 1.0;
    
    final progress = totalPoints - currentLevelPoints;
    final range = nextLevelPoints - currentLevelPoints;
    
    return progress / range;
  }

  String get favoriteCategory {
    if (categoryPoints.isEmpty) return 'Nenhuma';
    
    final sorted = categoryPoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }

  String get favoriteDifficulty {
    if (difficultyPoints.isEmpty) return 'Nenhuma';
    
    final sorted = difficultyPoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.first.key;
  }

  UserProgress copyWith({
    int? totalPoints,
    int? questionsAnswered,
    int? correctAnswers,
    List<Achievement>? unlockedAchievements,
    Map<String, int>? categoryPoints,
    Map<String, int>? difficultyPoints,
    DateTime? lastPlayed,
  }) {
    return UserProgress(
      totalPoints: totalPoints ?? this.totalPoints,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      categoryPoints: categoryPoints ?? this.categoryPoints,
      difficultyPoints: difficultyPoints ?? this.difficultyPoints,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }
}
