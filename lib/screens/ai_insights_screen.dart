import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/api_service.dart';
import '../models/restaurant_model.dart';

class AIInsightsScreen extends StatefulWidget {
  final int? restaurantId;

  const AIInsightsScreen({super.key, this.restaurantId});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  Map<String, dynamic>? _insights;
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  int? _selectedRestaurantId;
  bool _isInsertingTestData = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    final result = await ApiService.getAllRestaurants();
    if (result['success']) {
      setState(() {
        _restaurants = result['data'];
        if (_restaurants.isNotEmpty) {
          // Sempre selecionar o primeiro restaurante e carregar insights
          _selectedRestaurantId = widget.restaurantId ?? _restaurants.first.id;
          _loadInsights(_selectedRestaurantId!);
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _insertTestData() async {
    if (_selectedRestaurantId == null) {
      print('❌ Nenhum restaurante selecionado');
      return;
    }

    print(
        '📊 Iniciando inserção de dados para restaurante ID: $_selectedRestaurantId');

    setState(() {
      _isInsertingTestData = true;
    });

    try {
      // Simular inserção de dados de teste
      await Future.delayed(const Duration(seconds: 1));

      // Sempre usar dados mockados para demonstração
      print('🔄 Carregando insights mockados...');
      _loadInsights(_selectedRestaurantId!);

      print('✅ Dados carregados com sucesso. Insights: $_insights');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Dados demonstrativos carregados!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Erro ao inserir dados: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao inserir dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isInsertingTestData = false;
      });
    }
  }

  void _loadInsights(int restaurantId) {
    print('🎯 _loadInsights chamado com restaurantId: $restaurantId');
    // Sempre carregar dados mockados imediatamente
    setState(() {
      _insights = _getMockInsights(restaurantId);
      print('📈 Insights definidos: $_insights');
    });
  }

  Map<String, dynamic> _getMockInsights(int restaurantId) {
    print('🏪 Gerando insights mockados para restaurante ID: $restaurantId');
    final restaurant = _restaurants.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => Restaurant(
        id: restaurantId,
        nomeFantasia: 'Restaurante Demo',
        razaoSocial: 'Demo Ltda',
        cnpj: '00.000.000/0001-00',
        email: 'demo@demo.com',
        telefone: '(11) 99999-9999',
        endereco: 'Rua Demo, 123',
        categoria: 'Italiana',
        userId: 1,
      ),
    );

    print(
        '🍽️ Restaurante encontrado: ${restaurant.nomeFantasia} - Categoria: ${restaurant.categoria}');

    // Gerar dados baseados na categoria do restaurante
    final category = restaurant.categoria.toLowerCase();
    int baseReservations;
    String busiestDay;
    String peakHour;
    String recommendation;

    if (category.contains('italian') || category.contains('italiano')) {
      baseReservations = 35;
      busiestDay = 'Sábado';
      peakHour = '20:30';
      recommendation =
          'Clientes italianos preferem jantar mais tarde. Considere manter mesas disponíveis até 22h!';
    } else if (category.contains('japon') || category.contains('japanese')) {
      baseReservations = 28;
      busiestDay = 'Sexta-feira';
      peakHour = '19:00';
      recommendation =
          'Jantar cedo é popular. Adicione mais reservas para happy hour!';
    } else if (category.contains('churrasc') || category.contains('barbecue')) {
      baseReservations = 42;
      busiestDay = 'Domingo';
      peakHour = '12:00';
      recommendation =
          'Domingo é dia de família. Prepare mesas maiores para grupos!';
    } else {
      baseReservations = 25;
      busiestDay = 'Sexta-feira';
      peakHour = '20:00';
      recommendation = 'Padrão normal detectado. Monitore sazonalidade!';
    }

    final totalReservations =
        baseReservations + (restaurantId % 20); // Variação por restaurante

    final result = {
      'restaurantName': restaurant.nomeFantasia,
      'totalReservations': totalReservations,
      'estimatedOccupancy': '${65 + (restaurantId % 25)}%',
      'busiestDay': busiestDay,
      'peakHour': peakHour,
      'recommendation': recommendation,
      'reservationsByDay': {
        'MONDAY': (totalReservations * 0.08).round(),
        'TUESDAY': (totalReservations * 0.12).round(),
        'WEDNESDAY': (totalReservations * 0.10).round(),
        'THURSDAY': (totalReservations * 0.15).round(),
        'FRIDAY': (totalReservations * 0.25).round(),
        'SATURDAY': (totalReservations * 0.20).round(),
        'SUNDAY': (totalReservations * 0.10).round(),
      },
    };

    print('📊 Dados mockados gerados: $result');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.insights, color: Colors.purple),
            SizedBox(width: 8),
            Text('Dashboard de Insights IA'),
          ],
        ),
        backgroundColor: Colors.purple.shade50,
        actions: [
          if (_selectedRestaurantId != null)
            IconButton(
              icon: _isInsertingTestData
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_chart),
              tooltip: 'Inserir Dados de Teste',
              onPressed: _isInsertingTestData ? null : _insertTestData,
            ),
        ],
      ),
      body: _restaurants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Seletor de restaurante
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade100,
                  child: DropdownButtonFormField<int>(
                    value: _selectedRestaurantId,
                    decoration: const InputDecoration(
                      labelText: 'Selecione o Restaurante',
                      border: OutlineInputBorder(),
                    ),
                    items: _restaurants.map((restaurant) {
                      return DropdownMenuItem<int>(
                        value: restaurant.id,
                        child: Text(restaurant.nomeFantasia),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRestaurantId = value;
                        });
                        _loadInsights(value);
                      }
                    },
                  ),
                ),

                // Conteúdo dos insights
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _insights == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.analytics_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Nenhum dado disponível',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Clique no ícone 📊 no topo para inserir dados de teste',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : _buildInsightsContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildInsightsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card de resumo
          Card(
            elevation: 4,
            color: Colors.purple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _insights!['restaurantName'] ?? 'Restaurante',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildStatCard(
                    'Total de Reservas',
                    _insights!['totalReservations'].toString(),
                    Icons.book_online,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    'Taxa de Ocupação Estimada',
                    _insights!['estimatedOccupancy'] ?? '0%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Card de recomendações
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Análise de Padrões (IA)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Dia Mais Movimentado',
                    _insights!['busiestDay'] ?? 'N/A',
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Horário de Pico',
                    _insights!['peakHour'] ?? 'N/A',
                    Icons.access_time,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _insights!['recommendation'] ?? 'Sem recomendações',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Gráfico de reservas por dia (simulado)
          if (_insights!['reservationsByDay'] != null)
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reservas por Dia da Semana',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...(_insights!['reservationsByDay'] as Map<String, dynamic>)
                        .entries
                        .map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(_translateDay(entry.key)),
                            ),
                            Text(
                              entry.value.toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _translateDay(String day) {
    final translations = {
      'MONDAY': 'Segunda-feira',
      'TUESDAY': 'Terça-feira',
      'WEDNESDAY': 'Quarta-feira',
      'THURSDAY': 'Quinta-feira',
      'FRIDAY': 'Sexta-feira',
      'SATURDAY': 'Sábado',
      'SUNDAY': 'Domingo',
    };
    return translations[day] ?? day;
  }
}
