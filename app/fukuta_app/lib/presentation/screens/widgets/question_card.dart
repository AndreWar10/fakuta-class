import 'package:flutter/material.dart';
import '../../../domain/entities/question.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final int questionIndex;
  final int totalQuestions;
  final Function(String) onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.totalQuestions,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _answersController;
  late Animation<double> _cardAnimation;
  late Animation<double> _answersAnimation;
  String? _selectedAnswer;
  bool _answerSubmitted = false;

  @override
  void initState() {
    super.initState();
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _answersController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));

    _answersAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _answersController,
      curve: Curves.easeOutBack,
    ));

    _cardController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _answersController.forward();
    });
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Resetar estado quando a pergunta muda
    if (oldWidget.question.id != widget.question.id) {
      _selectedAnswer = null;
      _answerSubmitted = false;
      
      // Reiniciar animações para a nova pergunta
      _cardController.reset();
      _answersController.reset();
      _cardController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _answersController.forward();
      });
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    _answersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E),
                  Color(0xFF3949AB),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Header
                  _buildQuestionHeader(),
                  
                  const SizedBox(height: 24),
                  
                  // Question Text
                  _buildQuestionText(),
                  
                  const SizedBox(height: 32),
                  
                  // Answers
                  Expanded(
                    child: _buildAnswers(),
                  ),
                  
                  // Submit Button
                  if (_selectedAnswer != null && !_answerSubmitted)
                    _buildSubmitButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.quiz,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pergunta ${widget.questionIndex} de ${widget.totalQuestions}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor().withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.question.difficulty,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getDifficultyColor(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.question.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.question.points}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionText() {
    return Text(
      widget.question.question,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 1.4,
      ),
    );
  }

  Widget _buildAnswers() {
    final answers = widget.question.allAnswers;
    
    return AnimatedBuilder(
      animation: _answersAnimation,
      builder: (context, child) {
        return ListView.builder(
          itemCount: answers.length,
          itemBuilder: (context, index) {
            final answer = answers[index];
            final isSelected = _selectedAnswer == answer;
            final isCorrect = _answerSubmitted && answer == widget.question.correctAnswer;
            final isWrong = _answerSubmitted && isSelected && answer != widget.question.correctAnswer;
            
            return Transform.scale(
              scale: _answersAnimation.value,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildAnswerOption(
                  answer: answer,
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  isWrong: isWrong,
                  onTap: () => _selectAnswer(answer),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnswerOption({
    required String answer,
    required bool isSelected,
    required bool isCorrect,
    required bool isWrong,
    required VoidCallback onTap,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    
    if (_answerSubmitted) {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        borderColor = Colors.green;
        textColor = Colors.green;
      } else if (isWrong) {
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        borderColor = Colors.red;
        textColor = Colors.red;
      } else {
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        borderColor = Colors.grey.withValues(alpha: 0.3);
        textColor = Colors.grey[400]!;
      }
    } else {
      backgroundColor = isSelected 
          ? Colors.blue.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.05);
      borderColor = isSelected 
          ? Colors.blue
          : Colors.white.withValues(alpha: 0.2);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: _answerSubmitted ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (_answerSubmitted && isCorrect)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            if (_answerSubmitted && isWrong)
              const Icon(
                Icons.cancel,
                color: Colors.red,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitAnswer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Confirmar Resposta',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer != null) {
      setState(() {
        _answerSubmitted = true;
      });
      
      // Aguardar um pouco para mostrar o resultado
      Future.delayed(const Duration(seconds: 2), () {
        widget.onAnswerSelected(_selectedAnswer!);
      });
    }
  }

  Color _getDifficultyColor() {
    switch (widget.question.difficulty.toLowerCase()) {
      case 'fácil':
        return Colors.green;
      case 'médio':
        return Colors.orange;
      case 'difícil':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
