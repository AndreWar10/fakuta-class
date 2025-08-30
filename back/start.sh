#!/bin/bash

echo "🚀 Iniciando Fukuta Backend - Sistema de Desafios Espaciais"
echo "=========================================================="

# Verificar se o Dart está instalado
if ! command -v dart &> /dev/null; then
    echo "❌ Dart não está instalado. Por favor, instale o Dart SDK primeiro."
    echo "📖 Visite: https://dart.dev/get-dart"
    exit 1
fi

echo "✅ Dart encontrado: $(dart --version)"

# Verificar se as dependências estão instaladas
if [ ! -f "pubspec.lock" ]; then
    echo "📦 Instalando dependências..."
    dart pub get
fi

# Criar diretório de dados se não existir
if [ ! -d "data" ]; then
    echo "🗄️ Criando diretório de dados..."
    mkdir -p data
fi

echo "🌍 Iniciando servidor na porta 8080..."
echo "📱 Acesse: http://localhost:8080"
echo "🔍 Health check: http://localhost:8080/health"
echo ""
echo "Pressione Ctrl+C para parar o servidor"
echo ""

# Executar o backend
dart run lib/main.dart
