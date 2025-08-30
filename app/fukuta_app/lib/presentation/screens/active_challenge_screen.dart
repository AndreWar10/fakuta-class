import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../../domain/entities/challenge.dart';
import 'widgets/question_card.dart';
import 'widgets/timer_widget.dart';

class ActiveChallengeScreen extends StatefulWidget {
  const ActiveChallengeScreen({super.key});

  @override
  State<ActiveChallengeScreen> createState() => _ActiveChallengeScreenState();
}

class _ActiveChallengeScreenState extends State<ActiveChallengeScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _questionController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _questionAnimation;

  @override
  void initState() {
    super.initState();
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _questionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionController,
      curve: Curves.elasticOut,
    ));

    _backgroundController.repeat(reverse: true);
    _questionController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Consumer<ChallengeProvider>(
        builder: (context, provider, child) {
          if (!provider.hasCurrentChallenge) {
            return _buildNoChallengeView();
          }

          final challenge = provider.currentChallenge!;
          final currentQuestion = challenge.questions[provider.currentQuestionIndex];

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0E21),
                  Color.lerp(
                    const Color(0xFF0A0E21),
                    const Color(0xFF1A237E),
                    _backgroundAnimation.value,
                  )!,
                  const Color(0xFF0A0E21),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(provider, challenge),
                  
                  // Timer
                  TimerWidget(
                    timeSpent: provider.timeSpent,
                    isRunning: provider.isTimerRunning,
                  ),
                  
                  // Question Progress
                  _buildQuestionProgress(provider, challenge),
                  
                  // Question Card
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _questionAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _questionAnimation.value,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: QuestionCard(
                              question: currentQuestion,
                              questionIndex: provider.currentQuestionIndex + 1,
                              totalQuestions: challenge.questions.length,
                              onAnswerSelected: (answer) {
                                provider.submitAnswer(answer);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Navigation
                  _buildNavigation(provider, challenge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoChallengeView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum desafio ativo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Selecione um desafio para começar!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Voltar aos Desafios'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ChallengeProvider provider, Challenge challenge) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.typeName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.quiz,
              color: Colors.blue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionProgress(ChallengeProvider provider, Challenge challenge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Pergunta ${provider.currentQuestionIndex + 1} de ${challenge.questions.length}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const Spacer(),
          Text(
            '${challenge.totalPossiblePoints} pontos possíveis',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(ChallengeProvider provider, Challenge challenge) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (provider.currentQuestionIndex > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: () => provider.previousQuestion(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Anterior'),
              ),
            ),
          
          if (provider.currentQuestionIndex > 0) const SizedBox(width: 16),
          
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Implementar finalização do desafio
                provider.resetChallenge();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Finalizar Desafio'),
            ),
          ),
        ],
      ),
    );
  }
}
