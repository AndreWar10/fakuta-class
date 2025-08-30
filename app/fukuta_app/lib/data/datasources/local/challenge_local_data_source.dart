import 'package:hive/hive.dart';
import '../../models/question_model.dart';
import '../../models/achievement_model.dart';
import '../../models/user_progress_model.dart';

abstract class ChallengeLocalDataSource {
  Future<void> cacheQuestions(List<QuestionModel> questions);
  Future<List<QuestionModel>> getCachedQuestions();
  Future<void> cacheAchievements(List<AchievementModel> achievements);
  Future<List<AchievementModel>> getCachedAchievements();
  Future<void> saveUserProgress(UserProgressModel progress);
  Future<UserProgressModel?> getUserProgress();
  Future<void> clearCache();
}

class ChallengeLocalDataSourceImpl implements ChallengeLocalDataSource {
  static const String questionsBox = 'questions_box';
  static const String achievementsBox = 'achievements_box';
  static const String progressBox = 'progress_box';
  
  @override
  Future<void> cacheQuestions(List<QuestionModel> questions) async {
    final box = await Hive.openBox(questionsBox);
    await box.clear();
    
    for (int i = 0; i < questions.length; i++) {
      await box.put(i, questions[i].toJson());
    }
  }

  @override
  Future<List<QuestionModel>> getCachedQuestions() async {
    try {
      final box = await Hive.openBox(questionsBox);
      final questions = <QuestionModel>[];
      
      for (int i = 0; i < box.length; i++) {
        final data = box.get(i) as Map<String, dynamic>;
        questions.add(QuestionModel.fromJson(data));
      }
      
      return questions;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> cacheAchievements(List<AchievementModel> achievements) async {
    final box = await Hive.openBox(achievementsBox);
    await box.clear();
    
    for (int i = 0; i < achievements.length; i++) {
      await box.put(i, achievements[i].toJson());
    }
  }

  @override
  Future<List<AchievementModel>> getCachedAchievements() async {
    try {
      final box = await Hive.openBox(achievementsBox);
      final achievements = <AchievementModel>[];
      
      for (int i = 0; i < box.length; i++) {
        final data = box.get(i) as Map<String, dynamic>;
        achievements.add(AchievementModel.fromJson(data));
      }
      
      return achievements;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveUserProgress(UserProgressModel progress) async {
    final box = await Hive.openBox(progressBox);
    await box.put('progress', progress.toJson());
  }

  @override
  Future<UserProgressModel?> getUserProgress() async {
    try {
      final box = await Hive.openBox(progressBox);
      final data = box.get('progress') as Map<String, dynamic>?;
      
      if (data != null) {
        return UserProgressModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    final questionsBox = await Hive.openBox(ChallengeLocalDataSourceImpl.questionsBox);
    final achievementsBox = await Hive.openBox(ChallengeLocalDataSourceImpl.achievementsBox);
    final progressBox = await Hive.openBox(ChallengeLocalDataSourceImpl.progressBox);
    
    await questionsBox.clear();
    await achievementsBox.clear();
    await progressBox.clear();
  }
}
