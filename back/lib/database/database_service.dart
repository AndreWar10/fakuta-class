import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:convert';

class DatabaseService {
  late Database _database;
  late String _dbPath;
  
  Future<void> initialize() async {
    // Criar diretório de dados se não existir
    final dataDir = Directory('data');
    if (!await dataDir.exists()) {
      await dataDir.create();
    }
    
    _dbPath = path.join('data', 'fukuta_challenges.db');
    _database = sqlite3.open(_dbPath);
    
    // Criar tabelas
    await _createTables();
    
    // Inserir dados iniciais
    await _insertInitialData();
    
    print('🗄️ Banco de dados inicializado: $_dbPath');
  }
  
  Future<void> _createTables() async {
    // Tabela de perguntas
    _database.execute('''
      CREATE TABLE IF NOT EXISTS questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        wrong_answers TEXT NOT NULL,
        explanation TEXT,
        difficulty TEXT NOT NULL,
        category TEXT NOT NULL,
        points INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Tabela de conquistas
    _database.execute('''
      CREATE TABLE IF NOT EXISTS achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        points_required INTEGER NOT NULL,
        category TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Tabela de estatísticas globais
    _database.execute('''
      CREATE TABLE IF NOT EXISTS global_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_questions_answered INTEGER DEFAULT 0,
        total_correct_answers INTEGER DEFAULT 0,
        total_points_earned INTEGER DEFAULT 0,
        most_popular_category TEXT,
        last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Tabela de progresso do usuário
    _database.execute('''
      CREATE TABLE IF NOT EXISTS user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT UNIQUE NOT NULL,
        total_points INTEGER DEFAULT 0,
        questions_answered INTEGER DEFAULT 0,
        correct_answers INTEGER DEFAULT 0,
        category_points TEXT DEFAULT '{}',
        difficulty_points TEXT DEFAULT '{}',
        last_played DATETIME DEFAULT CURRENT_TIMESTAMP,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    print('📋 Tabelas criadas com sucesso!');
  }
  
  Future<void> _insertInitialData() async {
    // Inserir perguntas iniciais sobre o sistema solar
    final questions = [
      {
        'question': 'Qual é o planeta mais próximo do Sol?',
        'correct_answer': 'Mercúrio',
        'wrong_answers': 'Vênus,Terra,Marte',
        'explanation': 'Mercúrio é o primeiro planeta do sistema solar, orbitando mais próximo do Sol.',
        'difficulty': 'Fácil',
        'category': 'Planetas',
        'points': 10
      },
      {
        'question': 'Qual planeta é conhecido como o "Planeta Vermelho"?',
        'correct_answer': 'Marte',
        'wrong_answers': 'Vênus,Júpiter,Saturno',
        'explanation': 'Marte é chamado de Planeta Vermelho devido à cor de sua superfície rica em óxido de ferro.',
        'difficulty': 'Fácil',
        'category': 'Planetas',
        'points': 10
      },
      {
        'question': 'Qual é o maior planeta do sistema solar?',
        'correct_answer': 'Júpiter',
        'wrong_answers': 'Saturno,Urano,Netuno',
        'explanation': 'Júpiter é o maior planeta do sistema solar, com massa 2.5 vezes maior que todos os outros planetas juntos.',
        'difficulty': 'Fácil',
        'category': 'Planetas',
        'points': 10
      },
      {
        'question': 'Quantos planetas existem no sistema solar?',
        'correct_answer': '8',
        'wrong_answers': '7,9,10',
        'explanation': 'Existem 8 planetas no sistema solar: Mercúrio, Vênus, Terra, Marte, Júpiter, Saturno, Urano e Netuno.',
        'difficulty': 'Fácil',
        'category': 'Sistema Solar',
        'points': 10
      },
      {
        'question': 'Qual planeta tem o maior número de luas?',
        'correct_answer': 'Saturno',
        'wrong_answers': 'Júpiter,Urano,Netuno',
        'explanation': 'Saturno possui 82 luas confirmadas, mais que qualquer outro planeta do sistema solar.',
        'difficulty': 'Médio',
        'category': 'Planetas',
        'points': 15
      },
      {
        'question': 'Qual é a temperatura média da superfície de Vênus?',
        'correct_answer': '462°C',
        'wrong_answers': '15°C,100°C,200°C',
        'explanation': 'Vênus tem a temperatura mais alta do sistema solar, com média de 462°C devido ao efeito estufa intenso.',
        'difficulty': 'Médio',
        'category': 'Temperatura',
        'points': 15
      },
      {
        'question': 'Quanto tempo a luz do Sol leva para chegar à Terra?',
        'correct_answer': '8 minutos',
        'wrong_answers': '1 minuto,30 minutos,1 hora',
        'explanation': 'A luz do Sol leva aproximadamente 8 minutos para percorrer os 150 milhões de km até a Terra.',
        'difficulty': 'Médio',
        'category': 'Astronomia',
        'points': 15
      },
      {
        'question': 'Qual é a composição principal da atmosfera de Marte?',
        'correct_answer': 'Dióxido de Carbono',
        'wrong_answers': 'Oxigênio,Nitrogênio,Hidrogênio',
        'explanation': 'A atmosfera de Marte é composta principalmente por dióxido de carbono (95%).',
        'difficulty': 'Difícil',
        'category': 'Atmosfera',
        'points': 20
      },
      {
        'question': 'Qual é o período de rotação de Júpiter?',
        'correct_answer': '9 horas e 56 minutos',
        'wrong_answers': '24 horas,12 horas,48 horas',
        'explanation': 'Júpiter é o planeta que gira mais rápido, completando uma rotação em apenas 9 horas e 56 minutos.',
        'difficulty': 'Difícil',
        'category': 'Rotação',
        'points': 20
      },
      {
        'question': 'Qual é a distância média entre a Terra e o Sol?',
        'correct_answer': '150 milhões de km',
        'wrong_answers': '100 milhões de km,200 milhões de km,300 milhões de km',
        'explanation': 'A distância média entre a Terra e o Sol é de aproximadamente 150 milhões de quilômetros.',
        'difficulty': 'Médio',
        'category': 'Distâncias',
        'points': 15
      }
    ];
    
    for (final question in questions) {
      _database.execute('''
        INSERT OR IGNORE INTO questions (question, correct_answer, wrong_answers, explanation, difficulty, category, points)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [
        question['question'],
        question['correct_answer'],
        question['wrong_answers'],
        question['explanation'],
        question['difficulty'],
        question['category'],
        question['points']
      ]);
    }
    
    // Inserir conquistas iniciais
    final achievements = [
      {
        'name': 'Explorador Iniciante',
        'description': 'Respondeu sua primeira pergunta sobre o sistema solar',
        'icon': '🌍',
        'points_required': 10,
        'category': 'Iniciante'
      },
      {
        'name': 'Astrônomo Amador',
        'description': 'Acumulou 50 pontos em desafios espaciais',
        'icon': '🔭',
        'points_required': 50,
        'category': 'Intermediário'
      },
      {
        'name': 'Mestre do Sistema Solar',
        'description': 'Acumulou 200 pontos e conhece todos os planetas',
        'icon': '🚀',
        'points_required': 200,
        'category': 'Avançado'
      },
      {
        'name': 'Sábio Espacial',
        'description': 'Acumulou 500 pontos e é um expert em astronomia',
        'icon': '⭐',
        'points_required': 500,
        'category': 'Expert'
      },
      {
        'name': 'Lenda do Cosmos',
        'description': 'Acumulou 1000 pontos e domina o conhecimento espacial',
        'icon': '🌟',
        'points_required': 1000,
        'category': 'Lenda'
      }
    ];
    
    for (final achievement in achievements) {
      _database.execute('''
        INSERT OR IGNORE INTO achievements (name, description, icon, points_required, category)
        VALUES (?, ?, ?, ?, ?)
      ''', [
        achievement['name'],
        achievement['description'],
        achievement['icon'],
        achievement['points_required'],
        achievement['category']
      ]);
    }
    
    // Inserir estatísticas iniciais
    _database.execute('''
      INSERT OR IGNORE INTO global_stats (id, total_questions_answered, total_correct_answers, total_points_earned, most_popular_category)
      VALUES (1, 0, 0, 0, 'Planetas')
    ''');
    
    print('📚 Dados iniciais inseridos: ${questions.length} perguntas e ${achievements.length} conquistas!');
  }
  
  // Métodos para perguntas
  List<Map<String, dynamic>> getAllQuestions() {
    final result = _database.select('SELECT * FROM questions ORDER BY difficulty, category');
    return result.map((row) => {
      'id': row[0],
      'question': row[1],
      'correct_answer': row[2],
      'wrong_answers': row[3].split(','),
      'explanation': row[4],
      'difficulty': row[5],
      'category': row[6],
      'points': row[7],
      'created_at': row[8]
    }).toList();
  }
  
  Map<String, dynamic>? getRandomQuestion() {
    final result = _database.select('SELECT * FROM questions ORDER BY RANDOM() LIMIT 1');
    if (result.isEmpty) return null;
    
    final row = result.first;
    return {
      'id': row[0],
      'question': row[1],
      'correct_answer': row[2],
      'wrong_answers': row[3].split(','),
      'explanation': row[4],
      'difficulty': row[5],
      'category': row[6],
      'points': row[7],
      'created_at': row[8]
    };
  }
  
  Map<String, dynamic>? getQuestionById(int id) {
    final result = _database.select('SELECT * FROM questions WHERE id = ?', [id]);
    if (result.isEmpty) return null;
    
    final row = result.first;
    return {
      'id': row[0],
      'question': row[1],
      'correct_answer': row[2],
      'wrong_answers': row[3].split(','),
      'explanation': row[4],
      'difficulty': row[5],
      'category': row[6],
      'points': row[7],
      'created_at': row[8]
    };
  }
  
  // Métodos para conquistas
  List<Map<String, dynamic>> getAllAchievements() {
    final result = _database.select('SELECT * FROM achievements ORDER BY points_required');
    return result.map((row) => {
      'id': row[0],
      'name': row[1],
      'description': row[2],
      'icon': row[3],
      'points_required': row[4],
      'category': row[5],
      'created_at': row[6]
    }).toList();
  }
  
  List<Map<String, dynamic>> getAchievementsByPoints(int points) {
    final result = _database.select('SELECT * FROM achievements WHERE points_required <= ? ORDER BY points_required', [points]);
    return result.map((row) => {
      'id': row[0],
      'name': row[1],
      'description': row[2],
      'icon': row[3],
      'points_required': row[4],
      'category': row[5],
      'created_at': row[6]
    }).toList();
  }
  
  // Métodos para estatísticas
  Map<String, dynamic> getGlobalStats() {
    final result = _database.select('SELECT * FROM global_stats LIMIT 1');
    if (result.isEmpty) return {};
    
    final row = result.first;
    return {
      'total_questions_answered': row[1],
      'total_correct_answers': row[2],
      'total_points_earned': row[3],
      'most_popular_category': row[4],
      'last_updated': row[5]
    };
  }
  
  Future<void> updateGlobalStats({
    int? questionsAnswered,
    int? correctAnswers,
    int? pointsEarned,
    String? popularCategory
  }) async {
    final currentStats = getGlobalStats();
    
    final newQuestionsAnswered = (currentStats['total_questions_answered'] ?? 0) + (questionsAnswered ?? 0);
    final newCorrectAnswers = (currentStats['total_correct_answers'] ?? 0) + (correctAnswers ?? 0);
    final newPointsEarned = (currentStats['total_points_earned'] ?? 0) + (pointsEarned ?? 0);
    
    _database.execute('''
      UPDATE global_stats 
      SET total_questions_answered = ?, total_correct_answers = ?, total_points_earned = ?, 
          most_popular_category = ?, last_updated = CURRENT_TIMESTAMP
      WHERE id = 1
    ''', [
      newQuestionsAnswered,
      newCorrectAnswers,
      newPointsEarned,
      popularCategory ?? currentStats['most_popular_category']
    ]);
  }
  
  // Métodos para progresso do usuário
  Future<void> saveUserProgress({
    required String deviceId,
    required int totalPoints,
    required int questionsAnswered,
    required int correctAnswers,
    required Map<String, dynamic> categoryPoints,
    required Map<String, dynamic> difficultyPoints,
  }) async {
    final categoryPointsJson = json.encode(categoryPoints);
    final difficultyPointsJson = json.encode(difficultyPoints);
    
    // Tentar inserir, se falhar (device_id já existe), atualizar
    try {
      _database.execute('''
        INSERT INTO user_progress (
          device_id, total_points, questions_answered, correct_answers,
          category_points, difficulty_points, last_played, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
      ''', [
        deviceId, totalPoints, questionsAnswered, correctAnswers,
        categoryPointsJson, difficultyPointsJson
      ]);
    } catch (e) {
      // Se falhar, atualizar registro existente
      _database.execute('''
        UPDATE user_progress 
        SET total_points = ?, questions_answered = ?, correct_answers = ?,
            category_points = ?, difficulty_points = ?, last_played = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE device_id = ?
      ''', [
        totalPoints, questionsAnswered, correctAnswers,
        categoryPointsJson, difficultyPointsJson, deviceId
      ]);
    }
  }
  
  Map<String, dynamic>? getUserProgress(String deviceId) {
    final result = _database.select('SELECT * FROM user_progress WHERE device_id = ?', [deviceId]);
    if (result.isEmpty) return null;
    
    final row = result.first;
    return {
      'deviceId': row[1],
      'totalPoints': row[2],
      'questionsAnswered': row[3],
      'correctAnswers': row[4],
      'categoryPoints': json.decode(row[5] ?? '{}'),
      'difficultyPoints': json.decode(row[6] ?? '{}'),
      'lastPlayed': row[7],
      'createdAt': row[8],
      'updatedAt': row[9]
    };
  }
  
  Future<void> updateUserProgress({
    required String deviceId,
    required int totalPoints,
    required int questionsAnswered,
    required int correctAnswers,
    required Map<String, dynamic> categoryPoints,
    required Map<String, dynamic> difficultyPoints,
  }) async {
    final categoryPointsJson = json.encode(categoryPoints);
    final difficultyPointsJson = json.encode(difficultyPoints);
    
    _database.execute('''
      UPDATE user_progress 
      SET total_points = ?, questions_answered = ?, correct_answers = ?,
          category_points = ?, difficulty_points = ?, last_played = CURRENT_TIMESTAMP,
          updated_at = CURRENT_TIMESTAMP
      WHERE device_id = ?
    ''', [
      totalPoints, questionsAnswered, correctAnswers,
      categoryPointsJson, difficultyPointsJson, deviceId
    ]);
  }
  
  Future<void> resetUserProgress(String deviceId) async {
    _database.execute('''
      UPDATE user_progress 
      SET total_points = 0, questions_answered = 0, correct_answers = 0,
          category_points = '{}', difficulty_points = '{}',
          last_played = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
      WHERE device_id = ?
    ''', [deviceId]);
  }
  
  void close() {
    _database.dispose();
  }
}
