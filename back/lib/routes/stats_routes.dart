import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

import '../database/database_service.dart';

void statsRoutes(Router router, DatabaseService dbService) {
  
  // GET /stats - Estatísticas globais
  router.get('/stats', (Request request) {
    try {
      final globalStats = dbService.getGlobalStats();
      final questions = dbService.getAllQuestions();
      final achievements = dbService.getAllAchievements();
      
      // Calcular estatísticas adicionais
      final categories = questions.map((q) => q['category']).toSet().toList();
      final difficulties = questions.map((q) => q['difficulty']).toSet().toList();
      
      // Estatísticas por categoria
      final categoryStats = <Map<String, dynamic>>[];
      for (final category in categories) {
        final categoryQuestions = questions.where((q) => q['category'] == category).toList();
        final totalPoints = categoryQuestions.fold(0, (sum, q) => sum + (q['points'] as int));
        
        categoryStats.add({
          'category': category,
          'questionCount': categoryQuestions.length,
          'totalPoints': totalPoints,
          'averageDifficulty': _calculateAverageDifficulty(categoryQuestions),
          'mostCommonDifficulty': _getMostCommonDifficulty(categoryQuestions)
        });
      }
      
      // Estatísticas por dificuldade
      final difficultyStats = <Map<String, dynamic>>[];
      for (final difficulty in difficulties) {
        final difficultyQuestions = questions.where((q) => q['difficulty'] == difficulty).toList();
        final totalPoints = difficultyQuestions.fold(0, (sum, q) => sum + (q['points'] as int));
        
        difficultyStats.add({
          'difficulty': difficulty,
          'questionCount': difficultyQuestions.length,
          'totalPoints': totalPoints,
          'categories': difficultyQuestions.map((q) => q['category']).toSet().toList()
        });
      }
      
      // Estatísticas de conquistas
      final achievementStats = {
        'totalAchievements': achievements.length,
        'categories': achievements.map((a) => a['category']).toSet().toList(),
        'pointsRange': {
          'min': achievements.isNotEmpty ? achievements.map((a) => a['points_required'] as int).reduce((a, b) => a < b ? a : b) : 0,
          'max': achievements.isNotEmpty ? achievements.map((a) => a['points_required'] as int).reduce((a, b) => a > b ? a : b) : 0
        }
      };
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'global': globalStats,
            'questions': {
              'total': questions.length,
              'categories': categories,
              'difficulties': difficulties,
              'totalPossiblePoints': questions.fold(0, (sum, q) => sum + (q['points'] as int)),
              'categoryStats': categoryStats,
              'difficultyStats': difficultyStats
            },
            'achievements': achievementStats,
            'system': {
              'lastUpdated': DateTime.now().toIso8601String(),
              'version': '1.0.0',
              'status': 'online'
            }
          },
          'message': 'Estatísticas carregadas com sucesso!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar estatísticas: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /stats/category/{category} - Estatísticas por categoria
  router.get('/stats/category/<category>', (Request request, String category) {
    try {
      final questions = dbService.getAllQuestions()
          .where((q) => q['category'].toLowerCase() == category.toLowerCase())
          .toList();
      
      if (questions.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Categoria não encontrada'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      // Estatísticas detalhadas da categoria
      final difficulties = questions.map((q) => q['difficulty']).toSet().toList();
      final totalPoints = questions.fold(0, (sum, q) => sum + (q['points'] as int));
      
      final difficultyBreakdown = <Map<String, dynamic>>[];
      for (final difficulty in difficulties) {
        final difficultyQuestions = questions.where((q) => q['difficulty'] == difficulty).toList();
        final difficultyPoints = difficultyQuestions.fold(0, (sum, q) => sum + (q['points'] as int));
        
        difficultyBreakdown.add({
          'difficulty': difficulty,
          'count': difficultyQuestions.length,
          'points': difficultyPoints,
          'percentage': (difficultyQuestions.length / questions.length * 100).toStringAsFixed(1)
        });
      }
      
      // Perguntas mais difíceis (mais pontos)
      final topQuestions = questions
          .sorted((a, b) => (b['points'] as int).compareTo(a['points'] as int))
          .take(5)
          .toList();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'category': category,
            'summary': {
              'totalQuestions': questions.length,
              'totalPoints': totalPoints,
              'averagePoints': (totalPoints / questions.length).toStringAsFixed(1),
              'difficulties': difficulties
            },
            'difficultyBreakdown': difficultyBreakdown,
            'topQuestions': topQuestions,
            'distribution': {
              'byDifficulty': difficultyBreakdown,
              'byPoints': _groupByPoints(questions)
            }
          },
          'message': 'Estatísticas da categoria $category carregadas!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar estatísticas da categoria: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /stats/difficulty/{difficulty} - Estatísticas por dificuldade
  router.get('/stats/difficulty/<difficulty>', (Request request, String difficulty) {
    try {
      final questions = dbService.getAllQuestions()
          .where((q) => q['difficulty'].toLowerCase() == difficulty.toLowerCase())
          .toList();
      
      if (questions.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Dificuldade não encontrada'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      // Estatísticas detalhadas da dificuldade
      final categories = questions.map((q) => q['category']).toSet().toList();
      final totalPoints = questions.fold(0, (sum, q) => sum + (q['points'] as int));
      
      final categoryBreakdown = <Map<String, dynamic>>[];
      for (final category in categories) {
        final categoryQuestions = questions.where((q) => q['category'] == category).toList();
        final categoryPoints = categoryQuestions.fold(0, (sum, q) => sum + (q['points'] as int));
        
        categoryBreakdown.add({
          'category': category,
          'count': categoryQuestions.length,
          'points': categoryPoints,
          'percentage': (categoryQuestions.length / questions.length * 100).toStringAsFixed(1)
        });
      }
      
      // Perguntas da categoria
      final topQuestions = questions
          .sorted((a, b) => (b['points'] as int).compareTo(a['points'] as int))
          .take(10)
          .toList();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'difficulty': difficulty,
            'summary': {
              'totalQuestions': questions.length,
              'totalPoints': totalPoints,
              'averagePoints': (totalPoints / questions.length).toStringAsFixed(1),
              'categories': categories
            },
            'categoryBreakdown': categoryBreakdown,
            'topQuestions': topQuestions,
            'distribution': {
              'byCategory': categoryBreakdown,
              'byPoints': _groupByPoints(questions)
            }
          },
          'message': 'Estatísticas da dificuldade $difficulty carregadas!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar estatísticas da dificuldade: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /stats/performance - Estatísticas de performance
  router.get('/stats/performance', (Request request) {
    try {
      final globalStats = dbService.getGlobalStats();
      final questions = dbService.getAllQuestions();
      
      // Calcular métricas de performance
      final totalPossiblePoints = questions.fold(0, (sum, q) => sum + (q['points'] as int));
      final accuracy = globalStats['total_questions_answered'] > 0 
          ? (globalStats['total_correct_answers'] / globalStats['total_questions_answered'] * 100).toStringAsFixed(1)
          : '0.0';
      
      // Performance por categoria
      final categoryPerformance = <Map<String, dynamic>>[];
      final categories = questions.map((q) => q['category']).toSet().toList();
      
      for (final category in categories) {
        final categoryQuestions = questions.where((q) => q['category'] == category).toList();
        final categoryPoints = categoryQuestions.fold(0, (sum, q) => sum + (q['points'] as int));
        
        categoryPerformance.add({
          'category': category,
          'totalQuestions': categoryQuestions.length,
          'totalPoints': categoryPoints,
          'difficulty': _calculateAverageDifficulty(categoryQuestions),
          'estimatedAccuracy': _estimateCategoryAccuracy(categoryQuestions)
        });
      }
      
      // Performance por dificuldade
      final difficultyPerformance = <Map<String, dynamic>>[];
      final difficulties = questions.map((q) => q['difficulty']).toSet().toList();
      
      for (final difficulty in difficulties) {
        final difficultyQuestions = questions.where((q) => q['difficulty'] == difficulty).toList();
        final difficultyPoints = difficultyQuestions.fold(0, (sum, q) => sum + (q['points'] as int));
        
        difficultyPerformance.add({
          'difficulty': difficulty,
          'totalQuestions': difficultyQuestions.length,
          'totalPoints': difficultyPoints,
          'estimatedAccuracy': _estimateDifficultyAccuracy(difficultyQuestions)
        });
      }
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'overall': {
              'totalQuestionsAnswered': globalStats['total_questions_answered'] ?? 0,
              'totalCorrectAnswers': globalStats['total_correct_answers'] ?? 0,
              'totalPointsEarned': globalStats['total_points_earned'] ?? 0,
              'totalPossiblePoints': totalPossiblePoints,
              'accuracy': accuracy,
              'efficiency': totalPossiblePoints > 0 
                  ? ((globalStats['total_points_earned'] ?? 0) / totalPossiblePoints * 100).toStringAsFixed(1)
                  : '0.0'
            },
            'byCategory': categoryPerformance,
            'byDifficulty': difficultyPerformance,
            'trends': {
              'mostPopularCategory': globalStats['most_popular_category'] ?? 'N/A',
              'lastUpdated': globalStats['last_updated'] ?? 'N/A'
            }
          },
          'message': 'Estatísticas de performance carregadas!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar estatísticas de performance: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /stats/summary - Resumo das estatísticas
  router.get('/stats/summary', (Request request) {
    try {
      final globalStats = dbService.getGlobalStats();
      final questions = dbService.getAllQuestions();
      final achievements = dbService.getAllAchievements();
      
      // Resumo compacto
      final summary = {
        'questions': {
          'total': questions.length,
          'categories': questions.map((q) => q['category']).toSet().length,
          'difficulties': questions.map((q) => q['difficulty']).toSet().length,
          'totalPoints': questions.fold(0, (sum, q) => sum + (q['points'] as int))
        },
        'achievements': {
          'total': achievements.length,
          'categories': achievements.map((a) => a['category']).toSet().length,
          'pointsRange': {
            'min': achievements.isNotEmpty ? achievements.map((a) => a['points_required'] as int).reduce((a, b) => a < b ? a : b) : 0,
            'max': achievements.isNotEmpty ? achievements.map((a) => a['points_required'] as int).reduce((a, b) => a > b ? a : b) : 0
          }
        },
        'performance': {
          'questionsAnswered': globalStats['total_questions_answered'] ?? 0,
          'correctAnswers': globalStats['total_correct_answers'] ?? 0,
          'pointsEarned': globalStats['total_points_earned'] ?? 0,
          'accuracy': globalStats['total_questions_answered'] > 0 
              ? (globalStats['total_correct_answers'] / globalStats['total_questions_answered'] * 100).toStringAsFixed(1)
              : '0.0'
        },
        'lastUpdated': DateTime.now().toIso8601String()
      };
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': summary,
          'message': 'Resumo das estatísticas carregado!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar resumo: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
}

// Funções auxiliares
double _calculateAverageDifficulty(List<Map<String, dynamic>> questions) {
  if (questions.isEmpty) return 0.0;
  
  final difficultyValues = {
    'Fácil': 1.0,
    'Médio': 2.0,
    'Difícil': 3.0
  };
  
  final totalDifficulty = questions.fold(0.0, (sum, q) {
    return sum + (difficultyValues[q['difficulty']] ?? 1.0);
  });
  
  return (totalDifficulty / questions.length);
}

String _getMostCommonDifficulty(List<Map<String, dynamic>> questions) {
  if (questions.isEmpty) return 'N/A';
  
  final difficultyCounts = <String, int>{};
  for (final question in questions) {
    final difficulty = question['difficulty'] as String;
    difficultyCounts[difficulty] = (difficultyCounts[difficulty] ?? 0) + 1;
  }
  
  return difficultyCounts.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
}

List<Map<String, dynamic>> _groupByPoints(List<Map<String, dynamic>> questions) {
  final pointGroups = <Map<String, dynamic>>[];
  final pointRanges = [10, 15, 20];
  
  for (final point in pointRanges) {
    final count = questions.where((q) => q['points'] == point).length;
    if (count > 0) {
      pointGroups.add({
        'points': point,
        'count': count,
        'percentage': (count / questions.length * 100).toStringAsFixed(1)
      });
    }
  }
  
  return pointGroups;
}

String _estimateCategoryAccuracy(List<Map<String, dynamic>> questions) {
  // Estimativa baseada na dificuldade das perguntas
  final avgDifficulty = _calculateAverageDifficulty(questions);
  
  if (avgDifficulty <= 1.5) return '85-95%';
  if (avgDifficulty <= 2.5) return '70-85%';
  return '55-70%';
}

String _estimateDifficultyAccuracy(List<Map<String, dynamic>> questions) {
  final difficulty = questions.isNotEmpty ? questions.first['difficulty'] : 'Fácil';
  
  switch (difficulty) {
    case 'Fácil':
      return '85-95%';
    case 'Médio':
      return '70-85%';
    case 'Difícil':
      return '55-70%';
    default:
      return '70-80%';
  }
}
