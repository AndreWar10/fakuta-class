import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'dart:convert';

import '../database/database_service.dart';

void challengeRoutes(Router router, DatabaseService dbService) {
  
  // POST /challenges/submit - Submeter resposta de desafio
  router.post('/challenges/submit', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      // Validar dados obrigatórios
      if (!data.containsKey('questionId') || 
          !data.containsKey('answer') || 
          !data.containsKey('timeSpent')) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Dados obrigatórios: questionId, answer, timeSpent'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      final questionId = data['questionId'] as int;
      final answer = data['answer'] as String;
      final timeSpent = data['timeSpent'] as int; // em segundos
      
      // Buscar pergunta
      final question = dbService.getQuestionById(questionId);
      if (question == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Pergunta não encontrada'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      // Verificar resposta
      final isCorrect = answer.toLowerCase() == question['correct_answer'].toLowerCase();
      final basePoints = question['points'] as int;
      
      // Calcular pontos baseado no tempo
      int timeBonus = 0;
      if (isCorrect) {
        if (timeSpent <= 10) {
          timeBonus = 5; // Bônus por resposta rápida
        } else if (timeSpent <= 20) {
          timeBonus = 3;
        } else if (timeSpent <= 30) {
          timeBonus = 1;
        }
      }
      
      final totalPoints = isCorrect ? basePoints + timeBonus : 0;
      
      // Atualizar estatísticas globais
      await dbService.updateGlobalStats(
        questionsAnswered: 1,
        correctAnswers: isCorrect ? 1 : 0,
        pointsEarned: totalPoints,
        popularCategory: question['category']
      );
      
      // Preparar resposta
      final response = {
        'success': true,
        'data': {
          'isCorrect': isCorrect,
          'correctAnswer': question['correct_answer'],
          'explanation': question['explanation'],
          'pointsEarned': totalPoints,
          'basePoints': basePoints,
          'timeBonus': timeBonus,
          'timeSpent': timeSpent,
          'question': {
            'id': question['id'],
            'question': question['question'],
            'difficulty': question['difficulty'],
            'category': question['category']
          }
        },
        'message': isCorrect 
            ? 'Parabéns! Resposta correta!' 
            : 'Ops! Resposta incorreta. Tente novamente!'
      };
      
      return Response.ok(
        jsonEncode(response),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao processar desafio: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /challenges/daily - Obter desafio diário
  router.get('/challenges/daily', (Request request) {
    try {
      // Usar data atual para gerar pergunta "aleatória" mas consistente por dia
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      
      final questions = dbService.getAllQuestions();
      if (questions.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Nenhuma pergunta disponível'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      // Selecionar pergunta baseada no dia do ano
      final questionIndex = dayOfYear % questions.length;
      final question = questions[questionIndex];
      
      // Embaralhar respostas
      final allAnswers = [
        question['correct_answer'],
        ...question['wrong_answers']
      ]..shuffle();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'id': question['id'],
            'question': question['question'],
            'answers': allAnswers,
            'difficulty': question['difficulty'],
            'category': question['category'],
            'points': question['points'],
            'date': now.toIso8601String(),
            'dayOfYear': dayOfYear
          },
          'message': 'Desafio diário carregado!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar desafio diário: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /challenges/quick - Desafio rápido (3 perguntas)
  router.get('/challenges/quick', (Request request) {
    try {
      final questions = dbService.getAllQuestions();
      if (questions.length < 3) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Perguntas insuficientes para desafio rápido'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      // Selecionar 3 perguntas aleatórias
      final randomQuestions = <Map<String, dynamic>>[];
      final usedIndices = <int>{};
      
      while (randomQuestions.length < 3) {
        final randomIndex = (DateTime.now().millisecondsSinceEpoch % questions.length).toInt();
        if (!usedIndices.contains(randomIndex)) {
          usedIndices.add(randomIndex);
          final question = questions[randomIndex];
          
          // Embaralhar respostas
          final allAnswers = [
            question['correct_answer'],
            ...question['wrong_answers']
          ]..shuffle();
          
          randomQuestions.add({
            'id': question['id'],
            'question': question['question'],
            'answers': allAnswers,
            'difficulty': question['difficulty'],
            'category': question['category'],
            'points': question['points']
          });
        }
      }
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'questions': randomQuestions,
            'totalQuestions': randomQuestions.length,
            'totalPossiblePoints': randomQuestions.fold<int>(0, (sum, q) => sum + (q['points'] as int))
          },
          'message': 'Desafio rápido carregado!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar desafio rápido: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /challenges/category/{category} - Desafio por categoria
  router.get('/challenges/category/<category>', (Request request, String category) {
    try {
      final questions = dbService.getAllQuestions()
          .where((q) => q['category'].toLowerCase() == category.toLowerCase())
          .toList();
      
      if (questions.isEmpty) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Nenhuma pergunta encontrada para a categoria $category'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      // Selecionar até 5 perguntas da categoria
      final selectedQuestions = questions.take(5).map((question) {
        final allAnswers = [
          question['correct_answer'],
          ...question['wrong_answers']
        ]..shuffle();
        
        return {
          'id': question['id'],
          'question': question['question'],
          'answers': allAnswers,
          'difficulty': question['difficulty'],
          'category': question['category'],
          'points': question['points']
        };
      }).toList();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'category': category,
            'questions': selectedQuestions,
            'totalQuestions': selectedQuestions.length,
            'totalPossiblePoints': selectedQuestions.fold<int>(0, (sum, q) => sum + (q['points'] as int))
          },
          'message': 'Desafio da categoria $category carregado!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar desafio da categoria: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // POST /challenges/batch-submit - Submeter múltiplas respostas
  router.post('/challenges/batch-submit', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      
      if (!data.containsKey('answers') || data['answers'] is! List) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Campo "answers" deve ser uma lista'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      final answers = data['answers'] as List;
      int totalPoints = 0;
      int correctAnswers = 0;
      int totalQuestions = answers.length;
      
      final results = <Map<String, dynamic>>[];
      
      for (final answerData in answers) {
        if (answerData is! Map<String, dynamic>) continue;
        
        final questionId = answerData['questionId'] as int?;
        final answer = answerData['answer'] as String?;
        final timeSpent = answerData['timeSpent'] as int? ?? 0;
        
        if (questionId == null || answer == null) continue;
        
        final question = dbService.getQuestionById(questionId);
        if (question == null) continue;
        
        final isCorrect = answer.toLowerCase() == question['correct_answer'].toLowerCase();
        final basePoints = question['points'] as int;
        
        // Calcular bônus de tempo
        int timeBonus = 0;
        if (isCorrect) {
          if (timeSpent <= 10) timeBonus = 5;
          else if (timeSpent <= 20) timeBonus = 3;
          else if (timeSpent <= 30) timeBonus = 1;
        }
        
        final pointsEarned = isCorrect ? basePoints + timeBonus : 0;
        totalPoints += pointsEarned;
        if (isCorrect) correctAnswers++;
        
        results.add({
          'questionId': questionId,
          'isCorrect': isCorrect,
          'correctAnswer': question['correct_answer'],
          'pointsEarned': pointsEarned,
          'timeBonus': timeBonus
        });
      }
      
      // Atualizar estatísticas globais
      await dbService.updateGlobalStats(
        questionsAnswered: totalQuestions,
        correctAnswers: correctAnswers,
        pointsEarned: totalPoints
      );
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': {
            'results': results,
            'summary': {
              'totalQuestions': totalQuestions,
              'correctAnswers': correctAnswers,
              'totalPoints': totalPoints,
              'accuracy': totalQuestions > 0 ? (correctAnswers / totalQuestions * 100).toStringAsFixed(1) : '0.0'
            }
          },
          'message': 'Desafio em lote processado com sucesso!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
      
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao processar desafio em lote: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
}
