import '../../domain/entities/challenge.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/challenge_repository.dart';
import '../datasources/remote/challenge_remote_data_source.dart';
import '../datasources/local/challenge_local_data_source.dart';
import '../models/question_model.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  final ChallengeRemoteDataSource remoteDataSource;
  final ChallengeLocalDataSource localDataSource;

  ChallengeRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Challenge> getDailyChallenge() async {
    try {
      // Tentar buscar da API
      final data = await remoteDataSource.getDailyChallenge();
      final question = QuestionModel.fromJson(data);
      
      return Challenge(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}',
        type: ChallengeType.daily,
        questions: [question],
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
        totalPossiblePoints: question.points,
      );
    } catch (e) {
      // Fallback para cache local
      final cachedQuestions = await localDataSource.getCachedQuestions();
      if (cachedQuestions.isNotEmpty) {
        final randomQuestion = cachedQuestions[DateTime.now().day % cachedQuestions.length];
        
        return Challenge(
          id: 'daily_${DateTime.now().millisecondsSinceEpoch}',
          type: ChallengeType.daily,
          questions: [randomQuestion],
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 1)),
          totalPossiblePoints: randomQuestion.points,
        );
      }
      
      throw Exception('Nenhuma pergunta disponível');
    }
  }

  @override
  Future<Challenge> getQuickChallenge() async {
    try {
      // Tentar buscar da API
      final data = await remoteDataSource.getQuickChallenge();
      final questions = (data['questions'] as List)
          .map((q) => QuestionModel.fromJson(q))
          .toList();
      
      return Challenge(
        id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
        type: ChallengeType.quick,
        questions: questions,
        createdAt: DateTime.now(),
        totalPossiblePoints: data['totalPossiblePoints'] as int,
      );
    } catch (e) {
      // Fallback para cache local
      final cachedQuestions = await localDataSource.getCachedQuestions();
      if (cachedQuestions.length >= 3) {
        final selectedQuestions = cachedQuestions.take(3).toList();
        final totalPoints = selectedQuestions.fold<int>(0, (sum, q) => sum + q.points);
        
        return Challenge(
          id: 'quick_${DateTime.now().millisecondsSinceEpoch}',
          type: ChallengeType.quick,
          questions: selectedQuestions,
          createdAt: DateTime.now(),
          totalPossiblePoints: totalPoints,
        );
      }
      
      throw Exception('Perguntas insuficientes para desafio rápido');
    }
  }

  @override
  Future<Challenge> getCategoryChallenge(String category) async {
    try {
      // Tentar buscar da API
      final data = await remoteDataSource.getCategoryChallenge(category);
      final questions = (data['questions'] as List)
          .map((q) => QuestionModel.fromJson(q))
          .toList();
      
      return Challenge(
        id: 'category_${category}_${DateTime.now().millisecondsSinceEpoch}',
        type: ChallengeType.category,
        questions: questions,
        createdAt: DateTime.now(),
        totalPossiblePoints: data['totalPossiblePoints'] as int,
        category: category,
      );
    } catch (e) {
      // Fallback para cache local
      final cachedQuestions = await localDataSource.getCachedQuestions();
      final categoryQuestions = cachedQuestions
          .where((q) => q.category.toLowerCase() == category.toLowerCase())
          .take(5)
          .toList();
      
      if (categoryQuestions.isNotEmpty) {
        final totalPoints = categoryQuestions.fold<int>(0, (sum, q) => sum + q.points);
        
        return Challenge(
          id: 'category_${category}_${DateTime.now().millisecondsSinceEpoch}',
          type: ChallengeType.category,
          questions: categoryQuestions,
          createdAt: DateTime.now(),
          totalPossiblePoints: totalPoints,
          category: category,
        );
      }
      
      throw Exception('Nenhuma pergunta encontrada para a categoria $category');
    }
  }

  @override
  Future<List<Question>> getRandomQuestions(int count) async {
    try {
      final cachedQuestions = await localDataSource.getCachedQuestions();
      if (cachedQuestions.length >= count) {
        final randomQuestions = <Question>[];
        final usedIndices = <int>{};
        
        while (randomQuestions.length < count) {
          final randomIndex = DateTime.now().millisecondsSinceEpoch % cachedQuestions.length;
          if (!usedIndices.contains(randomIndex)) {
            usedIndices.add(randomIndex);
            randomQuestions.add(cachedQuestions[randomIndex]);
          }
        }
        
        return randomQuestions;
      }
      
      throw Exception('Perguntas insuficientes');
    } catch (e) {
      throw Exception('Erro ao obter perguntas aleatórias: $e');
    }
  }

  @override
  Future<void> submitAnswer(int questionId, String answer, int timeSpent) async {
    try {
      await remoteDataSource.submitAnswer(questionId, answer, timeSpent);
    } catch (e) {
      // Se falhar na API, apenas logar o erro
      print('Erro ao submeter resposta: $e');
    }
  }

  @override
  Future<void> submitBatchAnswers(List<Map<String, dynamic>> answers) async {
    try {
      // Implementar submissão em lote se necessário
      for (final answer in answers) {
        await submitAnswer(
          answer['questionId'] as int,
          answer['answer'] as String,
          answer['timeSpent'] as int,
        );
      }
    } catch (e) {
      print('Erro ao submeter respostas em lote: $e');
    }
  }
}
