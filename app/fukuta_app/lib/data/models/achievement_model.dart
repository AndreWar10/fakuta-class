import '../../domain/entities/achievement.dart';

class AchievementModel extends Achievement {
  AchievementModel({
    required super.id,
    required super.name,
    required super.description,
    required super.icon,
    required super.pointsRequired,
    required super.category,
    required super.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      pointsRequired: json['points_required'] as int,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'points_required': pointsRequired,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AchievementModel.fromEntity(Achievement achievement) {
    return AchievementModel(
      id: achievement.id,
      name: achievement.name,
      description: achievement.description,
      icon: achievement.icon,
      pointsRequired: achievement.pointsRequired,
      category: achievement.category,
      createdAt: achievement.createdAt,
    );
  }
}
