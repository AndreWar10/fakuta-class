import 'package:flutter/foundation.dart';
import '../../domain/entities/challenge.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/usecases/get_daily_challenge.dart';
import '../../domain/usecases/get_quick_challenge.dart';
import '../../domain/usecases/submit_challenge_answer.dart';
import '../../domain/usecases/get_user_achievements.dart';

class ChallengeProvider extends ChangeNotifier {
  final GetDailyChallenge getDailyChallenge;
  final GetQuickChallenge getQuickChallenge;
  final SubmitChallengeAnswer submitChallengeAnswer;
  final GetUserAchievements getUserAchievements;

  ChallengeProvider({
    required this.getDailyChallenge,
    required this.getQuickChallenge,
    required this.submitChallengeAnswer,
    required this.getUserAchievements,
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

  // Getters
  Challenge? get currentChallenge => _currentChallenge;
  UserProgress? get userProgress => _userProgress;
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
  Future<void> loadDailyChallenge() async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentChallenge = await getDailyChallenge();
      _currentQuestionIndex = 0;
      _startTimer();
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar desafio diário: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadQuickChallenge() async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentChallenge = await getQuickChallenge();
      _currentQuestionIndex = 0;
      _startTimer();
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar desafio rápido: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCategoryChallenge(String category) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Implementar quando necessário
      notifyListeners();
    } catch (e) {
      _setError('Erro ao carregar desafio da categoria: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> submitAnswer(String answer) async {
    if (_currentChallenge == null) return;
    
    _stopTimer();
    final question = _currentChallenge!.questions[_currentQuestionIndex];
    
    try {
      final result = await submitChallengeAnswer(
        questionId: question.id,
        answer: answer,
        timeSpent: _timeSpent,
        question: question,
      );
      
      // Atualizar progresso
      await _loadUserProgress();
      
      // Mover para próxima pergunta ou finalizar
      if (isLastQuestion) {
        _finishChallenge();
      } else {
        _nextQuestion();
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erro ao submeter resposta: $e');
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
    await _loadUserProgress();
  }

  Future<void> loadAchievements() async {
    try {
      final result = await getUserAchievements();
      _userProgress = UserProgress(
        totalPoints: result['currentPoints'] as int,
        questionsAnswered: 0, // Será carregado separadamente
        correctAnswers: 0, // Será carregado separadamente
        unlockedAchievements: result['unlockedAchievements'] as List<Achievement>,
        categoryPoints: {},
        difficultyPoints: {},
        lastPlayed: DateTime.now(),
      );
      _achievements = result['unlockedAchievements'] as List<Achievement>;
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
  }

  void _resetTimer() {
    _timeSpent = 0;
  }

  void _startTimerTicker() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isTimerRunning) {
        _timeSpent++;
        notifyListeners();
        _startTimerTicker();
      }
    });
  }

  Future<void> _loadUserProgress() async {
    // Implementar carregamento do progresso do usuário
  }
}
