import 'question.dart';

enum ChallengeType {
  daily,
  quick,
  category,
  custom,
}

class Challenge {
  final String id;
  final ChallengeType type;
  final List<Question> questions;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int totalPossiblePoints;
  final String? category;

  Challenge({
    required this.id,
    required this.type,
    required this.questions,
    required this.createdAt,
    this.expiresAt,
    required this.totalPossiblePoints,
    this.category,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isDaily => type == ChallengeType.daily;
  bool get isQuick => type == ChallengeType.quick;
  bool get isCategory => type == ChallengeType.category;

  String get typeName {
    switch (type) {
      case ChallengeType.daily:
        return 'Desafio Diário';
      case ChallengeType.quick:
        return 'Desafio Rápido';
      case ChallengeType.category:
        return 'Desafio ${category ?? ''}';
      case ChallengeType.custom:
        return 'Desafio Personalizado';
    }
  }

  String get description {
    switch (type) {
      case ChallengeType.daily:
        return 'Uma pergunta especial para hoje!';
      case ChallengeType.quick:
        return '3 perguntas para testar seu conhecimento!';
      case ChallengeType.category:
        return 'Perguntas sobre $category!';
      case ChallengeType.custom:
        return 'Desafio personalizado para você!';
    }
  }
}
