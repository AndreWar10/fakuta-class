import 'package:flutter/material.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/user_progress_repository.dart';
import '../datasources/local/challenge_local_data_source.dart';
import '../datasources/remote/user_progress_remote_data_source.dart';
import '../models/user_progress_model.dart';

class UserProgressRepositoryImpl implements UserProgressRepository {
  final ChallengeLocalDataSource localDataSource;
  final UserProgressRemoteDataSource remoteDataSource;

  UserProgressRepositoryImpl(this.localDataSource, this.remoteDataSource);

  @override
  Future<UserProgress> getUserProgress() async {
    debugPrint('📱 getUserProgress: INICIANDO...');
    
    try {
      // Primeiro, tentar buscar do cache local
      debugPrint('📱 getUserProgress: Tentando cache local...');
      final cachedProgress = await localDataSource.getUserProgress();
      
      debugPrint('📱 getUserProgress: Cache local retornou: $cachedProgress');
      
      if (cachedProgress != null) {
        debugPrint('📱 getUserProgress: Cache local encontrado - Pontos: ${cachedProgress.totalPoints}, Acertos: ${cachedProgress.correctAnswers}, Respondidas: ${cachedProgress.questionsAnswered}');
        
        if (cachedProgress.totalPoints > 0 || cachedProgress.correctAnswers > 0 || cachedProgress.questionsAnswered > 0) {
          debugPrint('📱 getUserProgress: Usando cache local (dados válidos)');
          return cachedProgress;
        } else {
          debugPrint('📱 getUserProgress: Cache local tem dados zerados, tentando backend...');
        }
      } else {
        debugPrint('📱 getUserProgress: Cache local vazio, tentando backend...');
      }
      
      // Se cache local estiver vazio ou zerado, tentar backend
      debugPrint('📱 getUserProgress: Chamando backend...');
      final remoteProgress = await remoteDataSource.getUserProgress();
      
      debugPrint('📱 getUserProgress: Backend retornou: $remoteProgress');
      
      // Converter para UserProgress
      final progress = UserProgressModel(
        totalPoints: remoteProgress['totalPoints'] as int? ?? 0,
        questionsAnswered: remoteProgress['questionsAnswered'] as int? ?? 0,
        correctAnswers: remoteProgress['correctAnswers'] as int? ?? 0,
        unlockedAchievements: [], // Será carregado separadamente
        categoryPoints: Map<String, int>.from(remoteProgress['categoryPoints'] ?? {}),
        difficultyPoints: Map<String, int>.from(remoteProgress['difficultyPoints'] ?? {}),
        lastPlayed: DateTime.parse(remoteProgress['lastPlayed'] ?? DateTime.now().toIso8601String()),
      );
      
      debugPrint('📱 getUserProgress: Progresso convertido - Pontos: ${progress.totalPoints}, Acertos: ${progress.correctAnswers}, Respondidas: ${progress.questionsAnswered}');
      
      // Salvar no cache local
      await localDataSource.saveUserProgress(progress);
      debugPrint('📱 getUserProgress: Dados do backend salvos no cache - ${progress.totalPoints} pontos');
      
      return progress;
    } catch (e) {
      debugPrint('⚠️ getUserProgress: Erro ao buscar progresso: $e');
      debugPrint('⚠️ getUserProgress: Stack trace: ${StackTrace.current}');
      
      // Fallback para cache local
      debugPrint('📱 getUserProgress: Fallback para cache local...');
      final cachedProgress = await localDataSource.getUserProgress();
      debugPrint('📱 getUserProgress: Fallback retornou: $cachedProgress');
      
      return cachedProgress ?? UserProgressModel.initial();
    }
  }

  @override
  Future<void> updateUserProgress(UserProgress progress) async {
    debugPrint('💾 updateUserProgress: Salvando no cache local - ${progress.totalPoints} pontos');
    final progressModel = UserProgressModel.fromEntity(progress);
    await localDataSource.saveUserProgress(progressModel);
    debugPrint('💾 updateUserProgress: Progresso salvo no cache local com sucesso');
  }

  @override
  Future<void> addPoints(int points, String category, String difficulty) async {
    debugPrint('💰 addPoints: INICIANDO - Pontos: $points, Categoria: $category, Dificuldade: $difficulty');
    debugPrint('💰 addPoints: Stack trace: ${StackTrace.current}');
    
    final currentProgress = await getUserProgress();
    debugPrint('💰 addPoints: Progresso atual - Total: ${currentProgress.totalPoints}, Categoria: ${currentProgress.categoryPoints[category] ?? 0}, Dificuldade: ${currentProgress.difficultyPoints[difficulty] ?? 0}');
    
    final newCategoryPoints = Map<String, int>.from(currentProgress.categoryPoints);
    final newDifficultyPoints = Map<String, int>.from(currentProgress.difficultyPoints);
    
    newCategoryPoints[category] = (newCategoryPoints[category] ?? 0) + points;
    newDifficultyPoints[difficulty] = (newDifficultyPoints[difficulty] ?? 0) + points;
    
    final updatedProgress = currentProgress.copyWith(
      totalPoints: currentProgress.totalPoints + points,
      categoryPoints: newCategoryPoints,
      difficultyPoints: newDifficultyPoints,
      lastPlayed: DateTime.now(),
    );
    
    debugPrint('💰 addPoints: Progresso atualizado - Total: ${updatedProgress.totalPoints}, Categoria: ${updatedProgress.categoryPoints[category]}, Dificuldade: ${updatedProgress.difficultyPoints[difficulty]}');
    
    // Salvar no backend e cache local
    try {
      debugPrint('💰 addPoints: Sincronizando com backend...');
      await remoteDataSource.updateUserProgress({
        'totalPoints': updatedProgress.totalPoints,
        'questionsAnswered': updatedProgress.questionsAnswered,
        'correctAnswers': updatedProgress.correctAnswers,
        'categoryPoints': updatedProgress.categoryPoints,
        'difficultyPoints': updatedProgress.difficultyPoints,
      });
      debugPrint('💰 addPoints: Backend sincronizado com sucesso');
    } catch (e) {
      // Se falhar, continuar apenas com cache local
      debugPrint('⚠️ addPoints: Falha ao sincronizar com backend: $e');
    }
    
    debugPrint('💰 addPoints: Salvando no cache local...');
    await updateUserProgress(updatedProgress);
    debugPrint('💰 addPoints: Cache local atualizado com sucesso');
    debugPrint('💰 addPoints: FINALIZADO');
  }

  @override
  Future<void> recordAnswer(bool isCorrect, String category, String difficulty) async {
    debugPrint('📝 recordAnswer: INICIANDO - Correto: $isCorrect, Categoria: $category, Dificuldade: $difficulty');
    debugPrint('📝 recordAnswer: Stack trace: ${StackTrace.current}');
    
    final currentProgress = await getUserProgress();
    debugPrint('📝 recordAnswer: Progresso atual - Respondidas: ${currentProgress.questionsAnswered}, Acertos: ${currentProgress.correctAnswers}');
    
    final updatedProgress = currentProgress.copyWith(
      questionsAnswered: currentProgress.questionsAnswered + 1,
      correctAnswers: currentProgress.correctAnswers + (isCorrect ? 1 : 0),
      lastPlayed: DateTime.now(),
    );
    
    debugPrint('📝 recordAnswer: Progresso atualizado - Respondidas: ${updatedProgress.questionsAnswered}, Acertos: ${updatedProgress.correctAnswers}');
    
    // Salvar no backend e cache local
    try {
      debugPrint('📝 recordAnswer: Sincronizando com backend...');
      await remoteDataSource.updateUserProgress({
        'totalPoints': updatedProgress.totalPoints,
        'questionsAnswered': updatedProgress.questionsAnswered,
        'correctAnswers': updatedProgress.correctAnswers,
        'categoryPoints': updatedProgress.categoryPoints,
        'difficultyPoints': updatedProgress.difficultyPoints,
      });
      debugPrint('📝 recordAnswer: Backend sincronizado com sucesso');
    } catch (e) {
      // Se falhar, continuar apenas com cache local
      debugPrint('⚠️ recordAnswer: Falha ao sincronizar com backend: $e');
    }
    
    debugPrint('📝 recordAnswer: Salvando no cache local...');
    await updateUserProgress(updatedProgress);
    debugPrint('📝 recordAnswer: Cache local atualizado com sucesso');
    debugPrint('📝 recordAnswer: FINALIZADO');
  }

  @override
  Future<void> unlockAchievement(int achievementId) async {
    // Esta funcionalidade pode ser implementada se necessário
    // Por enquanto, as conquistas são desbloqueadas automaticamente baseadas nos pontos
  }

  @override
  Future<void> resetProgress() async {
    final initialProgress = UserProgressModel.initial();
    await localDataSource.saveUserProgress(initialProgress);
  }
}
