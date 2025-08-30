// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/usecases/get_daily_challenge.dart';
import '../../domain/usecases/get_quick_challenge.dart';
import '../../domain/usecases/get_category_challenge.dart';
import '../../domain/usecases/submit_challenge_answer.dart';
import '../../domain/usecases/get_user_achievements.dart';
import '../../domain/repositories/user_progress_repository.dart';
import '../screens/active_challenge_screen.dart';

class ChallengeProvider extends ChangeNotifier {
  final GetDailyChallenge getDailyChallenge;
  final GetQuickChallenge getQuickChallenge;
  final GetCategoryChallenge getCategoryChallenge;
  final SubmitChallengeAnswer submitChallengeAnswer;
  final GetUserAchievements getUserAchievements;
  final UserProgressRepository userProgressRepository;

  ChallengeProvider({
    required this.getDailyChallenge,
    required this.getQuickChallenge,
    required this.getCategoryChallenge,
    required this.submitChallengeAnswer,
    required this.getUserAchievements,
    required this.userProgressRepository,
  });

  // Estado
  Challenge? _currentChallenge;
  UserProgress? _userProgress;
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;
  int _currentQuestionIndex = 0;
  int _timeSpent = 0;
  bool _isTimerRunning = false;
  Timer? _timer;
  bool _isSubmitting = false;

  // Getters
  Challenge? get currentChallenge => _currentChallenge;
  UserProgress? get userProgress {
    debugPrint('🎯 ChallengeProvider: userProgress getter chamado - _userProgress: ${_userProgress?.totalPoints} pontos, ${_userProgress?.correctAnswers} acertos');
    return _userProgress;
  }
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get timeSpent => _timeSpent;
  bool get isTimerRunning => _isTimerRunning;
  bool get hasCurrentChallenge => _currentChallenge != null;
  bool get isLastQuestion => _currentChallenge != null && 
      _currentQuestionIndex >= _currentChallenge!.questions.length - 1;

  // Métodos
  Future<void> loadDailyChallenge(BuildContext context) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentChallenge = await getDailyChallenge();
      
      _currentQuestionIndex = 0;
      _startTimer();
      notifyListeners();
      
      // Navegar para a tela de desafio ativo
      if (_currentChallenge != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ActiveChallengeScreen(),
          ),
        );
      }
    } catch (e) {
      _setError('Erro ao carregar desafio diário: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadQuickChallenge(BuildContext context) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentChallenge = await getQuickChallenge();
      
      _currentQuestionIndex = 0;
      _startTimer();
      notifyListeners();
      
      // Navegar para a tela de desafio ativo
      if (_currentChallenge != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ActiveChallengeScreen(),
          ),
        );
      }
    } catch (e) {
      _setError('Erro ao carregar desafio rápido: $e');
    } finally {
      _setLoading(false);
    }
  }



  Future<void> loadCategoryChallenge(String category, BuildContext context) async {
    _setLoading(true);
    _clearError();
    
    try {
      debugPrint('🎯 Carregando desafio da categoria: $category');
      
      final challenge = await getCategoryChallenge(category);
      _currentChallenge = challenge;
      _currentQuestionIndex = 0;
      _resetTimer();
      _startTimer();
      
      debugPrint('✅ Desafio da categoria $category carregado com sucesso!');
      
      // Navegar para a tela de desafio ativo
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ActiveChallengeScreen(),
          ),
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('💥 Erro ao carregar desafio da categoria $category: $e');
      _setError('Erro ao carregar desafio da categoria: $e');
    } finally {
      _setLoading(false);
    }
  }

    Future<void> submitAnswer(String answer) async {
    if (_currentChallenge == null) return;
    
    // Prevenir múltiplas chamadas
    if (_isSubmitting) {
      debugPrint('⚠️ submitAnswer: Já está processando uma resposta, ignorando...');
      return;
    }
    
    _isSubmitting = true;
    debugPrint('🎯 submitAnswer: INICIANDO - Resposta: $answer para pergunta ${_currentChallenge!.questions[_currentQuestionIndex].id}');
    debugPrint('⏱️ Tempo gasto: $_timeSpent segundos');
    
    _stopTimer();
    final question = _currentChallenge!.questions[_currentQuestionIndex];
    
    try {
      final result = await submitChallengeAnswer(
        questionId: question.id,
        answer: answer,
        timeSpent: _timeSpent,
        question: question,
      );
      
      debugPrint('✅ Resposta processada: ${result['isCorrect']} - ${result['points']} pontos');
      
      // O SubmitChallengeAnswer.call() já atualiza o progresso automaticamente
      debugPrint('📊 Progresso atualizado automaticamente pelo SubmitChallengeAnswer');
      
      // Recarregar progresso atualizado
      debugPrint('🔄 Recarregando progresso do usuário...');
      await loadUserProgress();
      debugPrint('📊 Progresso recarregado: ${_userProgress?.totalPoints} pontos, ${_userProgress?.correctAnswers} acertos');
      
      // Mover para próxima pergunta ou finalizar
      if (isLastQuestion) {
        _finishChallenge();
      } else {
        _nextQuestion();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('💥 Erro ao submeter resposta: $e');
      _setError('Erro ao submeter resposta: $e');
    } finally {
      _isSubmitting = false;
      debugPrint('🎯 submitAnswer: FINALIZADO');
    }
  }

  void nextQuestion() {
    if (_currentChallenge != null && _currentQuestionIndex < _currentChallenge!.questions.length - 1) {
      _currentQuestionIndex++;
      _resetTimer();
      _startTimer();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _resetTimer();
      _startTimer();
      notifyListeners();
    }
  }

  Future<void> loadUserProgress() async {
    debugPrint('🔄 loadUserProgress: Iniciando...');
    
    try {
      // Carregar progresso diretamente do cache local (mais confiável)
      debugPrint('🔄 loadUserProgress: Carregando do cache local...');
      
      final localProgress = await userProgressRepository.getUserProgress();
      
      debugPrint('🔄 loadUserProgress: Progresso local: ${localProgress.totalPoints} pontos, ${localProgress.correctAnswers} acertos, ${localProgress.questionsAnswered} respondidas');
      
      // Buscar conquistas separadamente
      debugPrint('🔄 loadUserProgress: Carregando conquistas...');
      final achievementsResult = await getUserAchievements();
      final unlockedAchievements = achievementsResult['unlockedAchievements'] as List<Achievement>? ?? [];
      
      // Criar UserProgress com dados locais + conquistas
      _userProgress = UserProgress(
        totalPoints: localProgress.totalPoints,
        questionsAnswered: localProgress.questionsAnswered,
        correctAnswers: localProgress.correctAnswers,
        unlockedAchievements: unlockedAchievements,
        categoryPoints: localProgress.categoryPoints,
        difficultyPoints: localProgress.difficultyPoints,
        lastPlayed: localProgress.lastPlayed,
      );
      
      debugPrint('🔄 loadUserProgress: UserProgress criado: ${_userProgress?.totalPoints} pontos, ${_userProgress?.correctAnswers} acertos, ${_userProgress?.questionsAnswered} respondidas');
      debugPrint('🔄 loadUserProgress: _userProgress hash: ${_userProgress.hashCode}');
      debugPrint('🔄 loadUserProgress: _userProgress == localProgress: ${_userProgress == localProgress}');
      debugPrint('🔄 loadUserProgress: VALORES FINAIS - Pontos: ${_userProgress?.totalPoints}, Acertos: ${_userProgress?.correctAnswers}, Respondidas: ${_userProgress?.questionsAnswered}');
      
      notifyListeners();
      debugPrint('🔄 loadUserProgress: notifyListeners() chamado');
      debugPrint('🔄 loadUserProgress: Estado atual - Pontos: ${_userProgress?.totalPoints}, Acertos: ${_userProgress?.correctAnswers}, Respondidas: ${_userProgress?.questionsAnswered}');
      
    } catch (e) {
      debugPrint('💥 loadUserProgress: Erro ao carregar progresso: $e');
      debugPrint('💥 loadUserProgress: Stack trace: ${StackTrace.current}');
      
      // Se falhar, criar progresso inicial
      _userProgress = UserProgress(
        totalPoints: 0,
        questionsAnswered: 0,
        correctAnswers: 0,
        unlockedAchievements: [],
        categoryPoints: {},
        difficultyPoints: {},
        lastPlayed: DateTime.now(),
      );
      
      debugPrint('🔄 loadUserProgress: Progresso inicial criado devido ao erro');
      notifyListeners();
    }
  }

  Future<void> loadAchievements() async {
    try {
      final result = await getUserAchievements();
      // NÃO sobrescrever _userProgress aqui, apenas carregar conquistas
      _achievements = result['unlockedAchievements'] as List<Achievement>;
      debugPrint('🏆 loadAchievements: ${_achievements.length} conquistas carregadas');
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar conquistas: $e');
    }
  }

  void resetChallenge() {
    _currentChallenge = null;
    _currentQuestionIndex = 0;
    _resetTimer();
    _clearError();
    notifyListeners();
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _nextQuestion() {
    if (_currentChallenge != null && _currentQuestionIndex < _currentChallenge!.questions.length - 1) {
      _currentQuestionIndex++;
      _resetTimer();
      _startTimer();
    }
  }

  void _finishChallenge() {
    _currentChallenge = null;
    _currentQuestionIndex = 0;
    _stopTimer();
    _resetTimer();
  }

  void _startTimer() {
    _isTimerRunning = true;
    _timeSpent = 0;
    _startTimerTicker();
  }

  void _stopTimer() {
    _isTimerRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  void _resetTimer() {
    _timeSpent = 0;
    _timer?.cancel();
    _timer = null;
  }

  void _startTimerTicker() {
    _timer?.cancel(); // Cancelar timer anterior se existir
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerRunning) {
        _timeSpent++;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
