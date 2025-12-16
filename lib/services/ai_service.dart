import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant_model.dart';

class AIService {
  // URL do backend local
  static const String baseUrl = 'http://localhost:8080';

  /// Busca inteligente de restaurantes
  /// Entende consultas como "restaurante romântico", "lugar barato", "melhor sushi", etc.
  static Future<Map<String, dynamic>> intelligentSearch(
      String query, int? userId) async {
    try {
      String url = '$baseUrl/ai/search?query=${Uri.encodeComponent(query)}';
      if (userId != null) {
        url += '&userId=$userId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Restaurant> restaurants =
            data.map((json) => Restaurant.fromJson(json)).toList();

        return {
          'success': true,
          'data': restaurants,
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao buscar restaurantes: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  /// Obter recomendações personalizadas baseadas no histórico do usuário
  static Future<Map<String, dynamic>> getRecommendations(int? userId) async {
    try {
      String url = '$baseUrl/ai/recommendations';
      if (userId != null) {
        url += '?userId=$userId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Restaurant> recommendations =
            data.map((json) => Restaurant.fromJson(json)).toList();

        return {
          'success': true,
          'data': recommendations,
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao obter recomendações: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  /// Análise preditiva de disponibilidade
  static Future<Map<String, dynamic>> predictAvailability(
      int restaurantId, DateTime date) async {
    try {
      final String formattedDate = date.toIso8601String();
      final String url =
          '$baseUrl/ai/availability?restaurantId=$restaurantId&date=${Uri.encodeComponent(formattedDate)}';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao prever disponibilidade: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  /// Chatbot/Assistente Virtual
  static Future<Map<String, dynamic>> chatAssistant(
      String message, int? userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          if (userId != null) 'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao processar mensagem: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  /// Dashboard de Insights com IA
  static Future<Map<String, dynamic>> getAIInsights(int restaurantId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ai/insights?restaurantId=$restaurantId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao obter insights: ${response.statusCode}',
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
