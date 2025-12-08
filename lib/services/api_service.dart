import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  // Altere para o IP da sua máquina se estiver testando em dispositivo físico
  static const String baseUrl = 'http://localhost:8080';

  // Criar usuário
  static Future<Map<String, dynamic>> createUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Usuário criado com sucesso!',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao criar usuário: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Login
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Login realizado com sucesso!',
          'data': data,
          'token': data['token'], // Assumindo que o backend retorna um token
        };
      } else {
        return {
          'success': false,
          'message': 'Credenciais inválidas',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Solicitar reset de senha (forgot password)
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Backend retorna String, não JSON
        String message = response.body;

        // Extrair token da mensagem se estiver presente no log/resposta
        String? token;
        final tokenMatch = RegExp(r'token=([a-f0-9-]+)').firstMatch(message);
        if (tokenMatch != null) {
          token = tokenMatch.group(1);
        }

        return {
          'success': true,
          'message': message,
          'data': token != null ? {'token': token} : null,
        };
      } else {
        return {
          'success': false,
          'message': response.body,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Resetar senha com token
  static Future<Map<String, dynamic>> resetPassword(
      String token, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        // Backend retorna String "Senha redefinida com sucesso!"
        return {
          'success': true,
          'message': response.body,
          'data': null,
        };
      } else {
        return {
          'success': false,
          'message': response.body,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }
}
