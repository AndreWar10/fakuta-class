class Question {
  final int id;
  final String question;
  final String correctAnswer;
  final List<String> wrongAnswers;
  final String explanation;
  final String difficulty;
  final String category;
  final int points;

  Question({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.wrongAnswers,
    required this.explanation,
    required this.difficulty,
    required this.category,
    required this.points,
  });

  List<String> get allAnswers {
    final answers = [correctAnswer, ...wrongAnswers];
    answers.shuffle();
    return answers;
  }

  bool isCorrect(String answer) {
    return answer.toLowerCase() == correctAnswer.toLowerCase();
  }

  int calculatePoints(int timeSpent, String answer) {
    if (!isCorrect(answer)) return 0;
    
    int timeBonus = 0;
    if (timeSpent <= 10) timeBonus = 5;
    else if (timeSpent <= 20) timeBonus = 3;
    else if (timeSpent <= 30) timeBonus = 1;
    
    return points + timeBonus;
  }
}
