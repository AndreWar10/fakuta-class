class Achievement {
  final int id;
  final String name;
  final String description;
  final String icon;
  final int pointsRequired;
  final String category;
  final DateTime createdAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.pointsRequired,
    required this.category,
    required this.createdAt,
  });

  bool isUnlocked(int currentPoints) {
    return currentPoints >= pointsRequired;
  }

  double getProgress(int currentPoints) {
    if (currentPoints >= pointsRequired) return 1.0;
    return currentPoints / pointsRequired;
  }

  String getProgressText(int currentPoints) {
    if (isUnlocked(currentPoints)) return 'Desbloqueado!';
    final remaining = pointsRequired - currentPoints;
    return 'Faltam $remaining pontos';
  }
}
