import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
// import 'package:shelf_cors_headers/cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
// import 'package:path/path.dart' as path;

import 'database/database_service.dart';
import 'routes/challenge_routes.dart';
import 'routes/question_routes.dart';
import 'routes/achievement_routes.dart';
import 'routes/stats_routes.dart';

void main() async {
  // Inicializar banco de dados
  final dbService = DatabaseService();
  await dbService.initialize();
  
  // Criar rotas
  final router = Router();
  
  // Adicionar rotas
  challengeRoutes(router, dbService);
  questionRoutes(router, dbService);
  achievementRoutes(router, dbService);
  statsRoutes(router, dbService);
  
  // Rota de health check
  router.get('/health', (Request request) {
    return Response.ok('Fukuta Backend - Sistema Solar Online! 🚀', 
      headers: {'content-type': 'text/plain; charset=utf-8'});
  });
  
  // Rota raiz
  router.get('/', (Request request) {
    return Response.ok('''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Fukuta Backend - Sistema Solar</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background: linear-gradient(135deg, #0A0E21, #1A237E); color: white; }
            .container { max-width: 800px; margin: 0 auto; }
            h1 { color: #64B5F6; text-align: center; }
            .endpoint { background: rgba(255,255,255,0.1); padding: 15px; margin: 10px 0; border-radius: 8px; }
            .method { display: inline-block; padding: 5px 10px; border-radius: 4px; font-weight: bold; margin-right: 10px; }
            .get { background: #4CAF50; }
            .post { background: #2196F3; }
            .put { background: #FF9800; }
            .delete { background: #F44336; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Fukuta Backend - Sistema Solar</h1>
            <p>Backend para o app Sistema Solar com sistema de desafios espaciais!</p>
            
            <h2>📚 Endpoints Disponíveis:</h2>
            
            <div class="endpoint">
                <span class="method get">GET</span>
                <strong>/health</strong> - Status do servidor
            </div>
            
            <div class="endpoint">
                <span class="method get">GET</span>
                <strong>/questions</strong> - Listar todas as perguntas
            </div>
            
            <div class="endpoint">
                <span class="method get">GET</span>
                <strong>/questions/random</strong> - Pergunta aleatória
            </div>
            
            <div class="endpoint">
                <span class="method post">POST</span>
                <strong>/challenges/submit</strong> - Submeter resposta de desafio
            </div>
            
            <div class="endpoint">
                <span class="method get">GET</span>
                <strong>/achievements</strong> - Listar conquistas disponíveis
            </div>
            
            <div class="endpoint">
                <span class="method get">GET</span>
                <strong>/stats</strong> - Estatísticas globais
            </div>
            
            <p style="text-align: center; margin-top: 40px; color: #BDBDBD;">
                🌟 Sistema de Desafios Espaciais - Explore o universo! 🌟
            </p>
        </div>
    </body>
    </html>
    ''', headers: {'content-type': 'text/html; charset=utf-8'});
  });
  
  // Configurar handler
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router);
  
  // Iniciar servidor
  final server = await io.serve(handler, 'localhost', 8080);
  
  print('🚀 Fukuta Backend rodando em http://localhost:${server.port}');
  print('📚 Sistema de Desafios Espaciais Online!');
  print('🌍 Acesse: http://localhost:${server.port}');
}
