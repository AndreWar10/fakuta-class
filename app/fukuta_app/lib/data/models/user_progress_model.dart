import '../../domain/entities/user_progress.dart';
import '../../domain/entities/achievement.dart';
import 'achievement_model.dart';

class UserProgressModel extends UserProgress {
  UserProgressModel({
    required super.totalPoints,
    required super.questionsAnswered,
    required super.correctAnswers,
    required super.unlockedAchievements,
    required super.categoryPoints,
    required super.difficultyPoints,
    required super.lastPlayed,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      totalPoints: json['totalPoints'] as int? ?? 0,
      questionsAnswered: json['questionsAnswered'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      unlockedAchievements: (json['unlockedAchievements'] as List<dynamic>?)
          ?.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      categoryPoints: Map<String, int>.from(json['categoryPoints'] ?? {}),
      difficultyPoints: Map<String, int>.from(json['difficultyPoints'] ?? {}),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'questionsAnswered': questionsAnswered,
      'correctAnswers': correctAnswers,
      'unlockedAchievements': unlockedAchievements.map((a) => (a as AchievementModel).toJson()).toList(),
      'categoryPoints': categoryPoints,
      'difficultyPoints': difficultyPoints,
      'lastPlayed': lastPlayed.toIso8601String(),
    };
  }

  factory UserProgressModel.fromEntity(UserProgress progress) {
    return UserProgressModel(
      totalPoints: progress.totalPoints,
      questionsAnswered: progress.questionsAnswered,
      correctAnswers: progress.correctAnswers,
      unlockedAchievements: progress.unlockedAchievements.map((a) => AchievementModel.fromEntity(a)).toList(),
      categoryPoints: progress.categoryPoints,
      difficultyPoints: progress.difficultyPoints,
      lastPlayed: progress.lastPlayed,
    );
  }

  factory UserProgressModel.initial() {
    return UserProgressModel(
      totalPoints: 0,
      questionsAnswered: 0,
      correctAnswers: 0,
      unlockedAchievements: [],
      categoryPoints: {},
      difficultyPoints: {},
      lastPlayed: DateTime.now(),
    );
  }
}
