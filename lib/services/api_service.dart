import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/restaurant_model.dart';
import '../models/reservation_model.dart';
import 'package:intl/intl.dart';

class ApiService {
  // Altere para o IP da sua máquina se estiver testando em dispositivo físico
  static const String baseUrl = 'http://localhost:8080';

  // Criar usuário
  static Future<Map<String, dynamic>> createUser(User user) async {
    try {
      final jsonBody = user.toJson();
      print('Enviando para backend: $jsonBody'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonBody),
      );

      print('Status Code: ${response.statusCode}'); // Debug
      print('Response Body: ${response.body}'); // Debug

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Usuário criado com sucesso!',
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ${response.statusCode}: ${response.body}',
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
        print('📥 Resposta do login completa: $data'); // Debug
        print('📥 userId na resposta: ${data['userId']}'); // Debug
        print('📥 Tipo do userId: ${data['userId'].runtimeType}'); // Debug

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

  // ========== RESTAURANTES ==========

  // Listar todos os restaurantes
  static Future<Map<String, dynamic>> getAllRestaurants() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants/all'),
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
          'message': 'Erro ao buscar restaurantes',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Criar restaurante (apenas ADMIN)
  static Future<Map<String, dynamic>> createRestaurant(
      Restaurant restaurant) async {
    try {
      final jsonBody = restaurant.toJson();
      print('🏪 Criando restaurante:');
      print('   JSON completo: $jsonBody'); // Debug
      print('   userId no JSON: ${jsonBody['userId']}'); // Debug
      print('   Tipo do userId: ${jsonBody['userId'].runtimeType}'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl/restaurants/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody),
      );

      print('📡 Status Code: ${response.statusCode}'); // Debug
      print('📡 Response completo: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Restaurante criado com sucesso!',
          'data': Restaurant.fromJson(jsonDecode(response.body)),
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ${response.statusCode}: ${response.body}',
        };
      }
    } catch (e) {
      print('❌ Erro ao criar restaurante: $e'); // Debug
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // ========== RESERVAS ==========

  // Fazer reserva
  static Future<Map<String, dynamic>> makeReservation({
    required int userId,
    required int restaurantId,
    required DateTime reservationDate,
  }) async {
    try {
      // Formatar data no formato que o backend espera: dd/MM/yyyy HH:mm
      final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
      final String formattedDate = formatter.format(reservationDate);

      // URL encode da data para evitar problemas com espaços
      final String encodedDate = Uri.encodeComponent(formattedDate);

      final response = await http.post(
        Uri.parse(
            '$baseUrl/reservas/fazer?userId=$userId&restaurantId=$restaurantId&reservationDate=$encodedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.body,
        };
      } else {
        return {
          'success': false,
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Listar todas as reservas
  static Future<Map<String, dynamic>> getAllReservations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Reservation> reservations =
            data.map((json) => Reservation.fromJson(json)).toList();

        return {
          'success': true,
          'data': reservations,
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao buscar reservas',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Buscar reserva por ID
  static Future<Map<String, dynamic>> getReservationById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': Reservation.fromJson(jsonDecode(response.body)),
        };
      } else {
        return {
          'success': false,
          'message': 'Reserva não encontrada',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Cancelar reserva
  static Future<Map<String, dynamic>> cancelReservation(int id) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/reservas/$id/cancelar'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.body,
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao cancelar reserva',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Atualizar status da reserva (ADMIN)
  static Future<Map<String, dynamic>> updateReservationStatus(
      int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/reservas/$id/status?status=$status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.body,
        };
      } else {
        return {
          'success': false,
          'message': response.body,
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
