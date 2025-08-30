# 🚀 Fukuta Backend - Sistema Solar

Backend para o app **Fukuta** com sistema de desafios espaciais desenvolvido em **Dart** usando **Shelf**.

## 🌟 **Funcionalidades**

- **Sistema de Desafios** - Perguntas sobre astronomia e sistema solar
- **Sistema de Conquistas** - Desbloqueie conquistas baseadas em pontos
- **Progresso do Usuário** - Persistência completa no SQLite
- **Estatísticas Globais** - Métricas de uso do sistema
- **API RESTful** - Endpoints para integração com frontend

## 🛠️ **Tecnologias**

- **Dart** - Linguagem principal
- **Shelf** - Framework web para Dart
- **SQLite** - Banco de dados local
- **Shelf Router** - Roteamento HTTP

## 📋 **Pré-requisitos**

- **Dart SDK** versão 3.6.0 ou superior
- **Git** para clonar o repositório

### **Instalar Dart SDK**

#### **macOS (Homebrew)**
```bash
brew tap dart-lang/dart
brew install dart
```

#### **Ubuntu/Debian**
```bash
sudo apt-get update
sudo apt-get install apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'wget -q -O /etc/apt/sources.list.d/dart_stable.list https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list'
sudo apt-get update
sudo apt-get install dart
```

#### **Windows**
1. Baixe o Dart SDK em: https://dart.dev/get-dart
2. Extraia para `C:\dart`
3. Adicione `C:\dart\bin` ao PATH

## 🚀 **Instalação e Execução**

### **1. Clonar o repositório**
```bash
git clone <URL_DO_REPOSITORIO>
cd fakuta-class/back
```

### **2. Instalar dependências**
```bash
dart pub get
```

### **3. Executar o backend**
```bash
dart run lib/main.dart
```

### **4. Verificar se está funcionando**
```bash
curl http://localhost:8081/health
```

**Resposta esperada:**
```
Fukuta Backend - Sistema Solar Online! 🚀
```

## 📚 **Endpoints Disponíveis**

### **🏥 Health Check**
- `GET /health` - Status do servidor

### **❓ Perguntas**
- `GET /questions` - Listar todas as perguntas
- `GET /questions/random` - Pergunta aleatória

### **🎯 Desafios**
- `GET /challenges/daily` - Desafio diário
- `GET /challenges/quick` - Desafio rápido
- `GET /challenges/category/{category}` - Desafio por categoria
- `POST /challenges/submit` - Submeter resposta

### **🏆 Conquistas**
- `GET /achievements` - Listar conquistas disponíveis

### **📊 Estatísticas**
- `GET /stats` - Estatísticas globais

### **👤 Progresso do Usuário**
- `POST /user-progress` - Salvar progresso
- `GET /user-progress/{deviceId}` - Obter progresso
- `PUT /user-progress/{deviceId}` - Atualizar progresso
- `DELETE /user-progress/{deviceId}` - Resetar progresso

## 🗄️ **Banco de Dados**

O backend usa **SQLite** localmente. O arquivo é criado automaticamente em:
```
back/data/fukuta_challenges.db
```

### **Tabelas**
- `questions` - Perguntas do sistema
- `achievements` - Conquistas disponíveis
- `global_stats` - Estatísticas globais
- `user_progress` - Progresso dos usuários

## 🔧 **Desenvolvimento**

### **Estrutura do Projeto**
```
back/
├── lib/
│   ├── main.dart                 # Ponto de entrada
│   ├── database/
│   │   └── database_service.dart # Serviço de banco
│   └── routes/
│       ├── challenge_routes.dart  # Rotas de desafios
│       ├── question_routes.dart   # Rotas de perguntas
│       ├── achievement_routes.dart # Rotas de conquistas
│       ├── stats_routes.dart      # Rotas de estatísticas
│       └── user_progress_routes.dart # Rotas de progresso
├── data/                         # Banco SQLite
└── pubspec.yaml                  # Dependências
```

### **Comandos Úteis**

#### **Análise de Código**
```bash
dart analyze
```

#### **Formatação**
```bash
dart format .
```

#### **Testes**
```bash
dart test
```

#### **Limpar Cache**
```bash
dart pub cache clean
```

## 🌐 **Configuração**

### **Porta**
O servidor roda na porta **8081** por padrão.

### **Host**
Configurado para `localhost` (127.0.0.1).

### **URL Base**
```
http://localhost:8081
```

## 🐛 **Troubleshooting**

### **Erro: Porta já em uso**
```bash
# Encontrar processo usando a porta 8081
lsof -i :8081

# Matar o processo
kill -9 <PID>
```

### **Erro: Dependências não encontradas**
```bash
dart pub get
dart pub cache repair
```

### **Erro: Banco de dados corrompido**
```bash
# Remover arquivo do banco (cuidado: perde todos os dados!)
rm data/fukuta_challenges.db

# Reiniciar o backend
dart run lib/main.dart
```

### **Erro: Permissões**
```bash
# Dar permissões de escrita na pasta data
chmod 755 data/
```

## 📱 **Integração com Frontend**

O frontend Flutter se conecta automaticamente ao backend através dos endpoints REST.

### **Configuração do Frontend**
```dart
static const String baseUrl = 'http://localhost:8080';
```

### **Teste de Conexão**
```bash
# Testar se o backend responde
curl -X GET http://localhost:8081/health

# Testar endpoint de progresso
curl -X GET http://localhost:8081/user-progress/test-device
```

## 🤝 **Contribuição**

1. **Fork** o repositório
2. **Crie** uma branch para sua feature
3. **Commit** suas mudanças
4. **Push** para a branch
5. **Abra** um Pull Request

## 📄 **Licença**

Este projeto está sob a licença MIT.

## 👨‍💻 **Desenvolvedor**

- **André Guerra** - Desenvolvedor Full Stack
- **FATEC** - Projeto Acadêmico

---

## 🎯 **Próximos Passos**

1. ✅ **Backend funcionando** - Sistema de rotas implementado
2. ✅ **Banco SQLite** - Persistência de dados
3. ✅ **API RESTful** - Endpoints para todas as funcionalidades
4. 🔄 **Integração Frontend** - Sincronização em tempo real
5. 🚀 **Deploy** - Preparar para produção

**🌟 Sistema de Desafios Espaciais - Explore o universo! 🌟**
