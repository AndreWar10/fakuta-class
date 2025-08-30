// ignore_for_file: unused_import

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

abstract class UserProgressRemoteDataSource {
  Future<Map<String, dynamic>> getUserProgress();
  Future<void> saveUserProgress(Map<String, dynamic> progress);
  Future<void> updateUserProgress(Map<String, dynamic> progress);
  Future<void> resetUserProgress();
}

class UserProgressRemoteDataSourceImpl implements UserProgressRemoteDataSource {
  static const String baseUrl = 'http://localhost:8081';
  String? _cachedDeviceId;
  
  Future<String> _getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }
    
    // Usar timestamp + random para criar um ID único e persistir
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000000).toString().padLeft(6, '0');
    _cachedDeviceId = 'device_${timestamp}_$random';
    return _cachedDeviceId!;
  }
  
  @override
  Future<Map<String, dynamic>> getUserProgress() async {
    try {
      final deviceId = await _getDeviceId();
      final response = await http.get(Uri.parse('$baseUrl/user-progress/$deviceId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      
      throw Exception('Falha ao carregar progresso do usuário');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
  
  @override
  Future<void> saveUserProgress(Map<String, dynamic> progress) async {
    try {
      final deviceId = await _getDeviceId();
      final response = await http.post(
        Uri.parse('$baseUrl/user-progress'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'deviceId': deviceId,
          ...progress,
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Falha ao salvar progresso do usuário');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
  
  @override
  Future<void> updateUserProgress(Map<String, dynamic> progress) async {
    try {
      final deviceId = await _getDeviceId();
      final response = await http.put(
        Uri.parse('$baseUrl/user-progress/$deviceId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(progress),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar progresso do usuário');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
  
  @override
  Future<void> resetUserProgress() async {
    try {
      final deviceId = await _getDeviceId();
      final response = await http.delete(Uri.parse('$baseUrl/user-progress/$deviceId'));
      
      if (response.statusCode != 200) {
        throw Exception('Falha ao resetar progresso do usuário');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
