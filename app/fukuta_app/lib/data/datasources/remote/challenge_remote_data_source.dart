import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/question_model.dart';
import '../../models/achievement_model.dart';

abstract class ChallengeRemoteDataSource {
  Future<List<QuestionModel>> getQuestions();
  Future<QuestionModel> getRandomQuestion();
  Future<Map<String, dynamic>> submitAnswer(int questionId, String answer, int timeSpent);
  Future<Map<String, dynamic>> getDailyChallenge();
  Future<Map<String, dynamic>> getQuickChallenge();
  Future<Map<String, dynamic>> getCategoryChallenge(String category);
  Future<List<AchievementModel>> getAchievements();
}

class ChallengeRemoteDataSourceImpl implements ChallengeRemoteDataSource {
  static const String baseUrl = 'http://localhost:8080';
  
  @override
  Future<List<QuestionModel>> getQuestions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/questions'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final questions = data['data'] as List;
          return questions.map((q) => QuestionModel.fromJson(q)).toList();
        }
      }
      
      throw Exception('Falha ao carregar perguntas');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<QuestionModel> getRandomQuestion() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/questions/random'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return QuestionModel.fromJson(data['data']);
        }
      }
      
      throw Exception('Falha ao carregar pergunta aleatória');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> submitAnswer(int questionId, String answer, int timeSpent) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/challenges/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'questionId': questionId,
          'answer': answer,
          'timeSpent': timeSpent,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      
      throw Exception('Falha ao submeter resposta');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDailyChallenge() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/challenges/daily'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      
      throw Exception('Falha ao carregar desafio diário');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getQuickChallenge() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/challenges/quick'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      
      throw Exception('Falha ao carregar desafio rápido');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCategoryChallenge(String category) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/challenges/category/$category'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      
      throw Exception('Falha ao carregar desafio da categoria');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/achievements'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final achievements = data['data'] as List;
          return achievements.map((a) => AchievementModel.fromJson(a)).toList();
        }
      }
      
      throw Exception('Falha ao carregar conquistas');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
