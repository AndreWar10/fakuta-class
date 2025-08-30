import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/question_model.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/user_progress_model.dart';

class HiveConfig {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Registrar adaptadores
    Hive.registerAdapter(QuestionModelAdapter());
    Hive.registerAdapter(AchievementModelAdapter());
    Hive.registerAdapter(UserProgressModelAdapter());
    
    debugPrint('🗄️ Hive inicializado com sucesso!');
  }
}

// Adapters para Hive
class QuestionModelAdapter extends TypeAdapter<QuestionModel> {
  @override
  final int typeId = 0;

  @override
  QuestionModel read(BinaryReader reader) {
    return QuestionModel(
      id: reader.readInt(),
      question: reader.readString(),
      correctAnswer: reader.readString(),
      wrongAnswers: List<String>.from(reader.readList()),
      explanation: reader.readString(),
      difficulty: reader.readString(),
      category: reader.readString(),
      points: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.question);
    writer.writeString(obj.correctAnswer);
    writer.writeList(obj.wrongAnswers);
    writer.writeString(obj.explanation);
    writer.writeString(obj.difficulty);
    writer.writeString(obj.category);
    writer.writeInt(obj.points);
  }
}

class AchievementModelAdapter extends TypeAdapter<AchievementModel> {
  @override
  final int typeId = 1;

  @override
  AchievementModel read(BinaryReader reader) {
    return AchievementModel(
      id: reader.readInt(),
      name: reader.readString(),
      description: reader.readString(),
      icon: reader.readString(),
      pointsRequired: reader.readInt(),
      category: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, AchievementModel obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.description);
    writer.writeString(obj.icon);
    writer.writeInt(obj.pointsRequired);
    writer.writeString(obj.category);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}

class UserProgressModelAdapter extends TypeAdapter<UserProgressModel> {
  @override
  final int typeId = 2;

  @override
  UserProgressModel read(BinaryReader reader) {
    return UserProgressModel(
      totalPoints: reader.readInt(),
      questionsAnswered: reader.readInt(),
      correctAnswers: reader.readInt(),
      unlockedAchievements: List<AchievementModel>.from(reader.readList()),
      categoryPoints: Map<String, int>.from(reader.readMap()),
      difficultyPoints: Map<String, int>.from(reader.readMap()),
      lastPlayed: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, UserProgressModel obj) {
    writer.writeInt(obj.totalPoints);
    writer.writeInt(obj.questionsAnswered);
    writer.writeInt(obj.correctAnswers);
    writer.writeList(obj.unlockedAchievements);
    writer.writeMap(obj.categoryPoints);
    writer.writeMap(obj.difficultyPoints);
    writer.writeString(obj.lastPlayed.toIso8601String());
  }
}
