# 🚀 Fukuta Backend - Sistema de Desafios Espaciais

Backend em Dart para o app Sistema Solar com sistema de desafios de perguntas e respostas sobre astronomia.

## ✨ Funcionalidades

- **Sistema de Perguntas**: Banco de perguntas sobre o sistema solar
- **Desafios**: Múltiplos tipos de desafios (diário, rápido, por categoria)
- **Sistema de Pontuação**: Pontos baseados em acertos e tempo de resposta
- **Conquistas**: Badges e achievements por milestones
- **Estatísticas**: Relatórios detalhados de performance
- **API RESTful**: Endpoints organizados e documentados

## 🛠️ Tecnologias

- **Dart** - Linguagem principal
- **Shelf** - Framework web para Dart
- **SQLite** - Banco de dados local
- **CORS** - Suporte a requisições cross-origin

## 📦 Instalação

1. **Instalar Dart SDK** (versão 3.6.0 ou superior)
2. **Clonar o projeto**:
   ```bash
   cd back
   ```
3. **Instalar dependências**:
   ```bash
   dart pub get
   ```
4. **Executar o servidor**:
   ```bash
   dart run lib/main.dart
   ```

## 🌐 Endpoints da API

### 📚 Perguntas

| Método | Endpoint | Descrição |
|--------|----------|------------|
| `GET` | `/questions` | Listar todas as perguntas |
| `GET` | `/questions/random` | Obter pergunta aleatória |
| `GET` | `/questions/{id}` | Obter pergunta por ID |
| `GET` | `/questions/category/{category}` | Perguntas por categoria |
| `GET` | `/questions/difficulty/{difficulty}` | Perguntas por dificuldade |
| `GET` | `/questions/search?q={query}` | Buscar perguntas |
| `GET` | `/questions/categories` | Listar categorias |
| `GET` | `/questions/difficulties` | Listar dificuldades |

### 🎯 Desafios

| Método | Endpoint | Descrição |
|--------|----------|------------|
| `POST` | `/challenges/submit` | Submeter resposta |
| `GET` | `/challenges/daily` | Desafio diário |
| `GET` | `/challenges/quick` | Desafio rápido (3 perguntas) |
| `GET` | `/challenges/category/{category}` | Desafio por categoria |
| `POST` | `/challenges/batch-submit` | Submeter múltiplas respostas |

### 🏆 Conquistas

| Método | Endpoint | Descrição |
|--------|----------|------------|
| `GET` | `/achievements` | Listar todas as conquistas |
| `GET` | `/achievements/available/{points}` | Conquistas disponíveis |
| `GET` | `/achievements/category/{category}` | Conquistas por categoria |
| `GET` | `/achievements/recent` | Conquistas recentes |
| `GET` | `/achievements/check/{points}` | Verificar conquistas |
| `GET` | `/achievements/leaderboard` | Ranking de conquistas |

### 📊 Estatísticas

| Método | Endpoint | Descrição |
|--------|----------|------------|
| `GET` | `/stats` | Estatísticas globais |
| `GET` | `/stats/category/{category}` | Estatísticas por categoria |
| `GET` | `/stats/difficulty/{difficulty}` | Estatísticas por dificuldade |
| `GET` | `/stats/performance` | Estatísticas de performance |
| `GET` | `/stats/summary` | Resumo das estatísticas |

### 🔧 Sistema

| Método | Endpoint | Descrição |
|--------|----------|------------|
| `GET` | `/` | Página inicial com documentação |
| `GET` | `/health` | Status do servidor |

## 📝 Exemplos de Uso

### Submeter Resposta de Desafio

```bash
curl -X POST http://localhost:8080/challenges/submit \
  -H "Content-Type: application/json" \
  -d '{
    "questionId": 1,
    "answer": "Mercúrio",
    "timeSpent": 15
  }'
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "isCorrect": true,
    "correctAnswer": "Mercúrio",
    "explanation": "Mercúrio é o primeiro planeta do sistema solar...",
    "pointsEarned": 15,
    "basePoints": 10,
    "timeBonus": 5,
    "timeSpent": 15
  },
  "message": "Parabéns! Resposta correta!"
}
```

### Obter Desafio Diário

```bash
curl http://localhost:8080/challenges/daily
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "id": 3,
    "question": "Qual é o maior planeta do sistema solar?",
    "answers": ["Júpiter", "Saturno", "Urano", "Netuno"],
    "difficulty": "Fácil",
    "category": "Planetas",
    "points": 10,
    "date": "2024-01-15T10:30:00.000Z",
    "dayOfYear": 15
  },
  "message": "Desafio diário carregado!"
}
```

### Verificar Conquistas Disponíveis

```bash
curl http://localhost:8080/achievements/available/150
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "currentPoints": 150,
    "achievements": [
      {
        "id": 1,
        "name": "Explorador Iniciante",
        "description": "Respondeu sua primeira pergunta...",
        "icon": "🌍",
        "points_required": 10,
        "category": "Iniciante"
      }
    ],
    "unlockedCount": 1,
    "nextAchievement": {
      "id": 2,
      "name": "Astrônomo Amador",
      "points_required": 200
    }
  },
  "message": "Conquistas disponíveis carregadas!"
}
```

## 🗄️ Estrutura do Banco de Dados

### Tabela `questions`
- `id` - ID único da pergunta
- `question` - Texto da pergunta
- `correct_answer` - Resposta correta
- `wrong_answers` - Respostas incorretas (separadas por vírgula)
- `explanation` - Explicação da resposta
- `difficulty` - Nível de dificuldade (Fácil, Médio, Difícil)
- `category` - Categoria da pergunta
- `points` - Pontos base da pergunta
- `created_at` - Data de criação

### Tabela `achievements`
- `id` - ID único da conquista
- `name` - Nome da conquista
- `description` - Descrição da conquista
- `icon` - Emoji/ícone da conquista
- `points_required` - Pontos necessários para desbloquear
- `category` - Categoria da conquista
- `created_at` - Data de criação

### Tabela `global_stats`
- `id` - ID único
- `total_questions_answered` - Total de perguntas respondidas
- `total_correct_answers` - Total de respostas corretas
- `total_points_earned` - Total de pontos ganhos
- `most_popular_category` - Categoria mais popular
- `last_updated` - Última atualização

## 🎮 Sistema de Pontuação

### Pontos Base
- **Fácil**: 10 pontos
- **Médio**: 15 pontos  
- **Difícil**: 20 pontos

### Bônus de Tempo
- **≤ 10 segundos**: +5 pontos
- **≤ 20 segundos**: +3 pontos
- **≤ 30 segundos**: +1 ponto
- **> 30 segundos**: +0 pontos

## 🏆 Sistema de Conquistas

### Níveis
1. **🌍 Explorador Iniciante** - 10 pontos
2. **🔭 Astrônomo Amador** - 50 pontos
3. **🚀 Mestre do Sistema Solar** - 200 pontos
4. **⭐ Sábio Espacial** - 500 pontos
5. **🌟 Lenda do Cosmos** - 1000 pontos

## 📊 Estatísticas Disponíveis

- **Global**: Total de perguntas, acertos, pontos
- **Por Categoria**: Performance em cada área
- **Por Dificuldade**: Estatísticas por nível
- **Performance**: Métricas de eficiência
- **Resumo**: Visão geral compacta

## 🚀 Como Executar

1. **Desenvolvimento**:
   ```bash
   dart run lib/main.dart
   ```

2. **Produção**:
   ```bash
   dart compile exe lib/main.dart
   ./main
   ```

3. **Testes**:
   ```bash
   dart test
   ```

## 🌍 Configuração

O servidor roda por padrão em `http://localhost:8080`

Para alterar a porta, modifique a linha no `main.dart`:
```dart
final server = await io.serve(handler, 'localhost', 8080);
```

## 📱 Integração com App Flutter

O backend está preparado para integração com o app Flutter:

- **CORS habilitado** para requisições do app
- **Respostas JSON** padronizadas
- **Endpoints RESTful** para fácil consumo
- **Validação de dados** robusta

## 🔒 Segurança

- **Validação de entrada** em todos os endpoints
- **Tratamento de erros** abrangente
- **Sanitização de dados** antes do processamento
- **Logs de requisições** para monitoramento

## 📈 Monitoramento

- **Health check** em `/health`
- **Logs automáticos** de todas as requisições
- **Estatísticas em tempo real** disponíveis
- **Métricas de performance** detalhadas

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT.

## 📞 Suporte

Para dúvidas ou suporte, abra uma issue no repositório.

---

**Desenvolvido com ❤️ para o Sistema Solar Fukuta** 🚀✨
