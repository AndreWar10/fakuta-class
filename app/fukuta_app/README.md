# 🌌 Solar System Quiz App - Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.19.0-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.3.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **Um aplicativo educacional interativo sobre o Sistema Solar com sistema de desafios, conquistas e progresso personalizado.**

## 📱 Sobre o Projeto

O **Solar System Quiz App** é uma aplicação Flutter que oferece uma experiência educacional imersiva sobre astronomia e o Sistema Solar. Com uma interface moderna e intuitiva, os usuários podem testar seus conhecimentos através de desafios diários, rápidos e por categoria, ganhando pontos e desbloqueando conquistas.

### ✨ Características Principais

- 🎯 **Sistema de Desafios**: Desafios diários, rápidos e por categoria
- 🏆 **Sistema de Conquistas**: Desbloqueie conquistas baseadas no seu progresso
- 📊 **Progresso Personalizado**: Acompanhe seus pontos, acertos e estatísticas
- 🎨 **Interface Moderna**: Design responsivo com animações fluidas
- 💾 **Persistência Local**: Dados salvos localmente com sincronização opcional
- 🚀 **Arquitetura Limpa**: Implementação seguindo Clean Architecture
- 🌟 **Tema Espacial**: Interface imersiva com tema astronômico

## 🏗️ Arquitetura

O projeto segue os princípios da **Clean Architecture** com separação clara de responsabilidades:

```
lib/
├── core/                    # Configurações e utilitários
│   ├── config/             # Configurações do app
│   ├── di/                 # Injeção de dependências
│   └── utils/              # Utilitários gerais
├── data/                   # Camada de dados
│   ├── datasources/        # Fontes de dados (local/remoto)
│   ├── models/             # Modelos de dados
│   └── repositories/       # Implementações dos repositórios
├── domain/                 # Camada de domínio
│   ├── entities/           # Entidades do negócio
│   ├── repositories/       # Interfaces dos repositórios
│   └── usecases/           # Casos de uso
└── presentation/           # Camada de apresentação
    ├── providers/          # Gerenciadores de estado
    ├── screens/            # Telas do app
    └── widgets/            # Widgets reutilizáveis
```

## 🚀 Tecnologias Utilizadas

### Frontend (Flutter)
- **Flutter 3.19.0** - Framework de desenvolvimento
- **Dart 3.3.0** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **Hive** - Banco de dados local NoSQL
- **AnimatedBuilder** - Animações customizadas

### Backend (Dart)
- **Shelf** - Framework web server
- **SQLite** - Banco de dados relacional
- **Shelf Router** - Roteamento HTTP
- **CORS** - Cross-Origin Resource Sharing

### Persistência
- **Hive** - Cache local para dados do usuário
- **SQLite** - Backend para dados persistentes
- **Sincronização** - Entre cache local e backend

## 📦 Instalação e Configuração

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.19.0+
- [Dart SDK](https://dart.dev/get-dart) 3.3.0+
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/solar-system-quiz-app.git
cd solar-system-quiz-app
```

### 2. Instale as Dependências

```bash
# No diretório do app Flutter
cd app/fukuta_app
flutter pub get

# No diretório do backend
cd ../../back
dart pub get
```

### 3. Configure o Backend

```bash
# Inicie o servidor backend
cd back
dart run lib/main.dart
```

O backend estará disponível em `http://localhost:8081`

### 4. Execute o App Flutter

```bash
# Em outro terminal, execute o app
cd app/fukuta_app
flutter run
```

## 🎮 Como Jogar

### Tipos de Desafios

1. **🌅 Desafio Diário**
   - Uma pergunta nova a cada dia
   - Pontuação baseada no tempo de resposta
   - Dificuldade variável

2. **⚡ Desafio Rápido**
   - 3 perguntas consecutivas
   - Cronômetro para cada pergunta
   - Pontuação por velocidade

3. **🏷️ Desafios por Categoria**
   - Perguntas específicas por tema
   - Atmosfera, Geologia, História Espacial
   - Dificuldade progressiva

### Sistema de Pontuação

- **Resposta Correta**: 20 pontos base
- **Bônus de Velocidade**: Até 5 pontos extras
- **Multiplicador de Dificuldade**: Fácil (1x), Médio (1.5x), Difícil (2x)
- **Pontos por Categoria**: Acumulativos por área de conhecimento

### Conquistas Disponíveis

- 🥉 **Iniciante**: 50 pontos
- 🥈 **Explorador**: 150 pontos
- 🥇 **Astrônomo**: 300 pontos
- 💎 **Mestre Espacial**: 500 pontos
- 🌟 **Lenda Cósmica**: 1000 pontos

## 🔧 Configuração do Desenvolvimento

### Estrutura de Dependências

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1          # Gerenciamento de estado
  hive: ^2.2.3              # Banco de dados local
  hive_flutter: ^1.1.0      # Integração Flutter-Hive
  http: ^1.1.0              # Requisições HTTP
  device_info_plus: ^9.1.1  # Informações do dispositivo

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1    # Geração de código Hive
  build_runner: ^2.4.7      # Executor de builds
```

### Variáveis de Ambiente

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String backendUrl = 'http://localhost:8081';
  static const int connectionTimeout = 10000;
  static const String appName = 'Solar System Quiz';
}
```

## 📱 Funcionalidades do App

### Telas Principais

1. **🏠 Tela Inicial**
   - Apresentação do app
   - Navegação para desafios
   - Estatísticas rápidas

2. **🎯 Tela de Desafios**
   - Lista de desafios disponíveis
   - Progresso atual
   - Conquistas desbloqueadas

3. **⚡ Tela de Desafio Ativo**
   - Pergunta atual
   - Opções de resposta
   - Cronômetro
   - Barra de progresso

4. **📊 Tela de Estatísticas**
   - Pontuação total
   - Acertos e tentativas
   - Progresso por categoria
   - Histórico de jogadas

### Sistema de Cache

- **Hive Database**: Armazenamento local rápido
- **Sincronização**: Entre cache local e backend
- **Fallback**: Funciona offline com dados locais
- **Performance**: Carregamento instantâneo de dados

## 🧪 Testes

### Executar Testes

```bash
# Testes unitários
flutter test

# Testes de widget
flutter test test/widget_test.dart

# Testes de integração
flutter test integration_test/
```

### Cobertura de Testes

```bash
# Gerar relatório de cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🚀 Deploy

### Build para Produção

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Configurações de Build

```yaml
# android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

## 📊 Métricas e Analytics

### Dados Coletados

- **Progresso do Usuário**: Pontos, acertos, tentativas
- **Tempo de Resposta**: Performance em cada pergunta
- **Categorias Favoritas**: Áreas de maior interesse
- **Padrões de Jogo**: Frequência e duração das sessões

### Privacidade

- **Dados Locais**: Armazenados apenas no dispositivo
- **Sem Rastreamento**: Não coleta dados pessoais
- **Transparência**: Usuário controla seus dados
- **GDPR Compliant**: Conformidade com regulamentações

## 🤝 Contribuição

### Como Contribuir

1. **Fork** o projeto
2. **Crie** uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. **Push** para a branch (`git push origin feature/AmazingFeature`)
5. **Abra** um Pull Request

### Padrões de Código

- **Clean Code**: Código limpo e legível
- **Documentação**: Comentários explicativos
- **Testes**: Cobertura mínima de 80%
- **Arquitetura**: Seguir Clean Architecture
- **Nomenclatura**: Padrões consistentes

## 📝 Changelog

### [1.0.0] - 2024-01-XX

#### Adicionado
- Sistema de desafios diários e rápidos
- Sistema de conquistas e progresso
- Interface moderna com tema espacial
- Persistência local com Hive
- Backend Dart com SQLite
- Sistema de pontuação dinâmico

#### Melhorado
- Performance de carregamento
- Experiência do usuário
- Estabilidade da aplicação

#### Corrigido
- Bugs de navegação
- Problemas de persistência
- Inconsistências na UI

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autores

- **Seu Nome** - *Desenvolvimento inicial* - [SeuGitHub](https://github.com/seu-usuario)

## 🙏 Agradecimentos

- **Flutter Team** - Framework incrível
- **Hive Team** - Banco de dados local rápido
- **Comunidade Flutter** - Suporte e inspiração
- **NASA** - Conteúdo educacional sobre o Sistema Solar

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/seu-usuario/solar-system-quiz-app/issues)
- **Discord**: [Servidor da Comunidade](https://discord.gg/seu-servidor)
- **Email**: seu-email@exemplo.com

## 🌟 Estrelas

Se este projeto te ajudou, considere dar uma ⭐ no GitHub!

---

**Desenvolvido com ❤️ e ☕ para a comunidade Flutter**
