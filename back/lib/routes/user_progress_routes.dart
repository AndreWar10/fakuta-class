import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/database_service.dart';

void userProgressRoutes(Router router, DatabaseService dbService) {
  // POST /user-progress - Salvar/atualizar progresso do usuário
  router.post('/user-progress', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);
      
      final deviceId = data['deviceId'] as String;
      final totalPoints = data['totalPoints'] as int? ?? 0;
      final questionsAnswered = data['questionsAnswered'] as int? ?? 0;
      final correctAnswers = data['correctAnswers'] as int? ?? 0;
      final categoryPoints = data['categoryPoints'] as Map<String, dynamic>? ?? {};
      final difficultyPoints = data['difficultyPoints'] as Map<String, dynamic>? ?? {};
      
      // Salvar ou atualizar progresso
      await dbService.saveUserProgress(
        deviceId: deviceId,
        totalPoints: totalPoints,
        questionsAnswered: questionsAnswered,
        correctAnswers: correctAnswers,
        categoryPoints: categoryPoints,
        difficultyPoints: difficultyPoints,
      );
      
      return Response.ok(
        json.encode({
          'success': true,
          'message': 'Progresso salvo com sucesso!',
          'data': {
            'deviceId': deviceId,
            'totalPoints': totalPoints,
            'questionsAnswered': questionsAnswered,
            'correctAnswers': correctAnswers,
          }
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({
          'success': false,
          'error': 'Erro ao salvar progresso: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });
  
  // GET /user-progress/{deviceId} - Obter progresso do usuário
  router.get('/user-progress/<deviceId>', (Request request, String deviceId) async {
    try {
      final progress = await dbService.getUserProgress(deviceId);
      
      if (progress == null) {
        return Response.ok(
          json.encode({
            'success': true,
            'message': 'Usuário não encontrado, criando progresso inicial',
            'data': {
              'deviceId': deviceId,
              'totalPoints': 0,
              'questionsAnswered': 0,
              'correctAnswers': 0,
              'categoryPoints': {},
              'difficultyPoints': {},
              'lastPlayed': DateTime.now().toIso8601String(),
            }
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }
      
      return Response.ok(
        json.encode({
          'success': true,
          'message': 'Progresso carregado com sucesso!',
          'data': progress,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({
          'success': false,
          'error': 'Erro ao carregar progresso: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });
  
  // PUT /user-progress/{deviceId} - Atualizar progresso do usuário
  router.put('/user-progress/<deviceId>', (Request request, String deviceId) async {
    try {
      final body = await request.readAsString();
      final data = json.decode(body);
      
      final totalPoints = data['totalPoints'] as int? ?? 0;
      final questionsAnswered = data['questionsAnswered'] as int? ?? 0;
      final correctAnswers = data['correctAnswers'] as int? ?? 0;
      final categoryPoints = data['categoryPoints'] as Map<String, dynamic>? ?? {};
      final difficultyPoints = data['difficultyPoints'] as Map<String, dynamic>? ?? {};
      
      // Atualizar progresso
      await dbService.updateUserProgress(
        deviceId: deviceId,
        totalPoints: totalPoints,
        questionsAnswered: questionsAnswered,
        correctAnswers: correctAnswers,
        categoryPoints: categoryPoints,
        difficultyPoints: difficultyPoints,
      );
      
      return Response.ok(
        json.encode({
          'success': true,
          'message': 'Progresso atualizado com sucesso!',
          'data': {
            'deviceId': deviceId,
            'totalPoints': totalPoints,
            'questionsAnswered': questionsAnswered,
            'correctAnswers': correctAnswers,
          }
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({
          'success': false,
          'error': 'Erro ao atualizar progresso: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });
  
  // DELETE /user-progress/{deviceId} - Resetar progresso do usuário
  router.delete('/user-progress/<deviceId>', (Request request, String deviceId) async {
    try {
      await dbService.resetUserProgress(deviceId);
      
      return Response.ok(
        json.encode({
          'success': true,
          'message': 'Progresso resetado com sucesso!',
          'data': {
            'deviceId': deviceId,
            'totalPoints': 0,
            'questionsAnswered': 0,
            'correctAnswers': 0,
          }
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({
          'success': false,
          'error': 'Erro ao resetar progresso: $e',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });
}
