import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

import '../database/database_service.dart';

void achievementRoutes(Router router, DatabaseService dbService) {
  
  // GET /achievements - Listar todas as conquistas
  router.get('/achievements', (Request request) {
    try {
      final achievements = dbService.getAllAchievements();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': achievements,
          'count': achievements.length,
          'message': 'Conquistas carregadas com sucesso!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar conquistas: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /achievements/available/{points} - Conquistas disponíveis para X pontos
  router.get('/achievements/available/<points>', (Request request, String points) {
    try {
      final pointsRequired = int.tryParse(points);
      
      if (pointsRequired == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Pontos inválidos'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      final achievements = dbService.getAchievementsByPoints(pointsRequired);
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'currentPoints': pointsRequired,
            'achievements': achievements,
            'unlockedCount': achievements.length,
            'nextAchievement': _getNextAchievement(pointsRequired, dbService),
            'progress': _calculateProgress(pointsRequired, dbService)
          },
          'message': 'Conquistas disponíveis carregadas!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar conquistas disponíveis: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /achievements/category/{category} - Conquistas por categoria
  router.get('/achievements/category/<category>', (Request request, String category) {
    try {
      final achievements = dbService.getAllAchievements()
          .where((a) => a['category'].toLowerCase() == category.toLowerCase())
          .toList();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'category': category,
            'achievements': achievements,
            'count': achievements.length
          },
          'message': 'Conquistas da categoria $category carregadas!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar conquistas da categoria: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /achievements/recent - Conquistas mais recentes
  router.get('/achievements/recent', (Request request) {
    try {
      final achievements = dbService.getAllAchievements();
      
      // Ordenar por pontos requeridos (mais fáceis primeiro)
      achievements.sort((a, b) => (a['points_required'] as int).compareTo(b['points_required'] as int));
      
      // Pegar as 5 primeiras
      final recentAchievements = achievements.take(5).toList();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'achievements': recentAchievements,
            'count': recentAchievements.length,
            'message': 'Conquistas mais recentes carregadas!'
          }
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar conquistas recentes: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /achievements/check/{points} - Verificar conquistas desbloqueadas
  router.get('/achievements/check/<points>', (Request request, String points) {
    try {
      final currentPoints = int.tryParse(points);
      
      if (currentPoints == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Pontos inválidos'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      final allAchievements = dbService.getAllAchievements();
      final unlockedAchievements = allAchievements
          .where((a) => (a['points_required'] as int) <= currentPoints)
          .toList();
      
      final lockedAchievements = allAchievements
          .where((a) => (a['points_required'] as int) > currentPoints)
          .toList();
      
      // Encontrar próxima conquista
      final nextAchievement = lockedAchievements.isNotEmpty 
          ? lockedAchievements.reduce((a, b) => 
              (a['points_required'] as int) < (b['points_required'] as int) ? a : b)
          : null;
      
      // Calcular progresso para próxima conquista
      double progressToNext = 0.0;
      if (nextAchievement != null) {
        final pointsForNext = nextAchievement['points_required'] as int;
        final previousAchievement = unlockedAchievements
            .where((a) => (a['points_required'] as int) < pointsForNext)
            .fold<Map<String, dynamic>?>(null, (a, b) => 
                a == null || (b['points_required'] as int) > (a['points_required'] as int) ? b : a);
        
        if (previousAchievement != null) {
          final previousPoints = previousAchievement['points_required'] as int;
          final range = pointsForNext - previousPoints;
          final progress = currentPoints - previousPoints;
          progressToNext = (progress / range * 100).clamp(0.0, 100.0);
        } else {
          progressToNext = (currentPoints / pointsForNext * 100).clamp(0.0, 100.0);
        }
      }
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'currentPoints': currentPoints,
            'unlockedAchievements': unlockedAchievements,
            'lockedAchievements': lockedAchievements,
            'totalUnlocked': unlockedAchievements.length,
            'totalLocked': lockedAchievements.length,
            'nextAchievement': nextAchievement,
            'progressToNext': progressToNext,
            'summary': {
              'totalAchievements': allAchievements.length,
              'completionPercentage': (unlockedAchievements.length / allAchievements.length * 100).toStringAsFixed(1),
              'highestUnlocked': unlockedAchievements.isNotEmpty 
                  ? unlockedAchievements.reduce((a, b) => 
                      (a['points_required'] as int) > (b['points_required'] as int) ? a : b)
                  : null
            }
          },
          'message': 'Verificação de conquistas realizada!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao verificar conquistas: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /achievements/leaderboard - Ranking de conquistas
  router.get('/achievements/leaderboard', (Request request) {
    try {
      final achievements = dbService.getAllAchievements();
      
      // Simular ranking (em um sistema real, isso viria de uma tabela de usuários)
      final leaderboard = [
        {
          'rank': 1,
          'username': 'Astronauta_Mestre',
          'points': 1250,
          'achievements': achievements.length,
          'icon': '👑'
        },
        {
          'rank': 2,
          'username': 'Explorador_Espacial',
          'points': 890,
          'achievements': achievements.length - 1,
          'icon': '🥈'
        },
        {
          'rank': 3,
          'username': 'Viajante_Estelar',
          'points': 650,
          'achievements': achievements.length - 2,
          'icon': '🥉'
        },
        {
          'rank': 4,
          'username': 'Curioso_Cósmico',
          'points': 420,
          'achievements': achievements.length - 3,
          'icon': '⭐'
        },
        {
          'rank': 5,
          'username': 'Iniciante_Estelar',
          'points': 180,
          'achievements': achievements.length - 4,
          'icon': '🌟'
        }
      ];
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'leaderboard': leaderboard,
            'totalParticipants': leaderboard.length,
            'lastUpdated': DateTime.now().toIso8601String()
          },
          'message': 'Ranking de conquistas carregado!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar ranking: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
}

// Funções auxiliares
Map<String, dynamic>? _getNextAchievement(int currentPoints, DatabaseService dbService) {
  final allAchievements = dbService.getAllAchievements();
  final lockedAchievements = allAchievements
      .where((a) => (a['points_required'] as int) > currentPoints)
      .toList();
  
  if (lockedAchievements.isEmpty) return null;
  
  return lockedAchievements.reduce((a, b) => 
      (a['points_required'] as int) < (b['points_required'] as int) ? a : b);
}

Map<String, dynamic> _calculateProgress(int currentPoints, DatabaseService dbService) {
  final allAchievements = dbService.getAllAchievements();
  final unlockedAchievements = allAchievements
      .where((a) => (a['points_required'] as int) <= currentPoints)
      .toList();
  
  final nextAchievement = _getNextAchievement(currentPoints, dbService);
  
  double progressToNext = 0.0;
  if (nextAchievement != null) {
    final pointsForNext = nextAchievement['points_required'] as int;
    final previousAchievement = unlockedAchievements
        .where((a) => (a['points_required'] as int) < pointsForNext)
        .fold<Map<String, dynamic>?>(null, (a, b) => 
            a == null || (b['points_required'] as int) > (a['points_required'] as int) ? b : a);
    
    if (previousAchievement != null) {
      final previousPoints = previousAchievement['points_required'] as int;
      final range = pointsForNext - previousPoints;
      final progress = currentPoints - previousPoints;
      progressToNext = (progress / range * 100).clamp(0.0, 100.0);
    } else {
      progressToNext = (currentPoints / pointsForNext * 100).clamp(0.0, 100.0);
    }
  }
  
  return {
    'currentPoints': currentPoints,
    'totalAchievements': allAchievements.length,
    'unlockedAchievements': unlockedAchievements.length,
    'completionPercentage': (unlockedAchievements.length / allAchievements.length * 100).toStringAsFixed(1),
    'progressToNext': progressToNext,
    'nextAchievement': nextAchievement
  };
}
