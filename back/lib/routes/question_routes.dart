import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
// import 'package:http/http.dart' as http;
import 'dart:convert';

import '../database/database_service.dart';

void questionRoutes(Router router, DatabaseService dbService) {
  
  // GET /questions - Listar todas as perguntas
  router.get('/questions', (Request request) {
    try {
      final questions = dbService.getAllQuestions();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': questions,
          'count': questions.length,
          'message': 'Perguntas carregadas com sucesso!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar perguntas: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /questions/random - Obter pergunta aleatória
  router.get('/questions/random', (Request request) {
    try {
      final question = dbService.getRandomQuestion();
      
      if (question == null) {
        return Response.notFound(
          jsonEncode({
            'success': false,
            'error': 'Nenhuma pergunta encontrada'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': question,
          'message': 'Pergunta aleatória carregada!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar pergunta aleatória: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /questions/{id} - Obter pergunta por ID
  router.get('/questions/<id>', (Request request, String id) {
    try {
      final questionId = int.tryParse(id);
      
      if (questionId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'ID inválido'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
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
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': question,
          'message': 'Pergunta encontrada!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao buscar pergunta: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /questions/category/{category} - Obter perguntas por categoria
  router.get('/questions/category/<category>', (Request request, String category) {
    try {
      final questions = dbService.getAllQuestions()
          .where((q) => q['category'].toLowerCase() == category.toLowerCase())
          .toList();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': questions,
          'count': questions.length,
          'category': category,
          'message': 'Perguntas da categoria $category carregadas!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar perguntas da categoria: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /questions/difficulty/{difficulty} - Obter perguntas por dificuldade
  router.get('/questions/difficulty/<difficulty>', (Request request, String difficulty) {
    try {
      final questions = dbService.getAllQuestions()
          .where((q) => q['difficulty'].toLowerCase() == difficulty.toLowerCase())
          .toList();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': questions,
          'count': questions.length,
          'difficulty': difficulty,
          'message': 'Perguntas de dificuldade $difficulty carregadas!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar perguntas por dificuldade: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /questions/search - Buscar perguntas por texto
  router.get('/questions/search', (Request request) {
    try {
      final query = request.url.queryParameters['q'];
      
      if (query == null || query.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({
            'success': false,
            'error': 'Parâmetro de busca "q" é obrigatório'
          }),
          headers: {'content-type': 'application/json; charset=utf-8'}
        );
      }
      
      final questions = dbService.getAllQuestions()
          .where((q) => 
              q['question'].toLowerCase().contains(query.toLowerCase()) ||
              q['category'].toLowerCase().contains(query.toLowerCase()) ||
              q['difficulty'].toLowerCase().contains(query.toLowerCase())
          )
          .toList();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': questions,
          'count': questions.length,
          'query': query,
          'message': 'Busca realizada com sucesso!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro na busca: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /questions/categories - Listar todas as categorias
  router.get('/questions/categories', (Request request) {
    try {
      final questions = dbService.getAllQuestions();
      final categories = questions
          .map((q) => q['category'])
          .toSet()
          .toList()
        ..sort();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': categories,
          'count': categories.length,
          'message': 'Categorias carregadas!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar categorias: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
  
  // GET /questions/difficulties - Listar todas as dificuldades
  router.get('/questions/difficulties', (Request request) {
    try {
      final questions = dbService.getAllQuestions();
      final difficulties = questions
          .map((q) => q['difficulty'])
          .toSet()
          .toList()
        ..sort();
      
      return Response.ok(
        jsonEncode({
          'success': true,
          'data': difficulties,
          'count': difficulties.length,
          'message': 'Dificuldades carregadas!'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'success': false,
          'error': 'Erro ao carregar dificuldades: $e'
        }),
        headers: {'content-type': 'application/json; charset=utf-8'}
      );
    }
  });
}
