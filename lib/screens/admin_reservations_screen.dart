import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/reservation_model.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String _filterStatus = 'TODAS';

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    if (!mounted) return; // Verifica se ainda está montado
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getAllReservations();
      if (!mounted) return; // Verifica novamente antes de setState

      if (result['success'] == true && result['data'] != null) {
        // O ApiService já retorna List<Reservation>, não precisa converter!
        final List<Reservation> reservations =
            result['data'] as List<Reservation>;
        setState(() {
          _reservations = reservations;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return; // Verifica antes de setState
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar reservas: $e')),
        );
      }
    }
  }

  List<Reservation> get _filteredReservations {
    if (_filterStatus == 'TODAS') return _reservations;
    return _reservations
        .where((r) => r.status.toUpperCase() == _filterStatus)
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.blue;
      case 'CANCELED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return 'Confirmada';
      case 'PENDING':
        return 'Pendente';
      case 'CANCELED':
        return 'Cancelada';
      case 'COMPLETED':
        return 'Concluída';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.schedule;
      case 'CANCELED':
        return Icons.cancel;
      case 'COMPLETED':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  Future<void> _updateReservationStatus(
      int reservationId, String newStatus) async {
    try {
      await ApiService.updateReservationStatus(reservationId, newStatus);
      await _loadReservations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Status atualizado para ${_getStatusText(newStatus)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status: $e')),
        );
      }
    }
  }

  void _showStatusChangeDialog(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text('Pendente'),
              onTap: () {
                Navigator.pop(context);
                if (reservation.id != null) {
                  _updateReservationStatus(reservation.id!, 'PENDING');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Confirmada'),
              onTap: () {
                Navigator.pop(context);
                if (reservation.id != null) {
                  _updateReservationStatus(reservation.id!, 'CONFIRMED');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.done_all, color: Colors.blue),
              title: const Text('Concluída'),
              onTap: () {
                Navigator.pop(context);
                if (reservation.id != null) {
                  _updateReservationStatus(reservation.id!, 'COMPLETED');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancelada'),
              onTap: () {
                Navigator.pop(context);
                if (reservation.id != null) {
                  _updateReservationStatus(reservation.id!, 'CANCELED');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> get _aiStatistics {
    final total = _reservations.length;
    final confirmed =
        _reservations.where((r) => r.status == 'CONFIRMED').length;
    final pending = _reservations.where((r) => r.status == 'PENDING').length;
    final completed =
        _reservations.where((r) => r.status == 'COMPLETED').length;
    final canceled = _reservations.where((r) => r.status == 'CANCELED').length;

    final confirmationRate = total > 0 ? (confirmed / total * 100) : 0.0;
    final completionRate = total > 0 ? (completed / total * 100) : 0.0;

    // Análise de padrões por horário
    final hourCounts = <int, int>{};
    for (var res in _reservations) {
      final hour = res.reservationDate.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    final peakHour = hourCounts.entries.isEmpty
        ? null
        : hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return {
      'total': total,
      'confirmed': confirmed,
      'pending': pending,
      'completed': completed,
      'canceled': canceled,
      'confirmationRate': confirmationRate,
      'completionRate': completionRate,
      'peakHour': peakHour,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _aiStatistics;

    return Scaffold(
      body: Column(
        children: [
          // Dashboard de Estatísticas com IA
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange.shade400,
                  Colors.deepOrange.shade600
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Dashboard de Estatísticas IA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        stats['total'].toString(),
                        Icons.event_note,
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Confirmadas',
                        stats['confirmed'].toString(),
                        Icons.check_circle,
                        Colors.green.shade100,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Pendentes',
                        stats['pending'].toString(),
                        Icons.schedule,
                        Colors.blue.shade100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (stats['peakHour'] != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insights, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Horário de pico: ${stats['peakHour']}:00h | Taxa de confirmação: ${stats['confirmationRate'].toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('TODAS'),
                  const SizedBox(width: 8),
                  _buildFilterChip('PENDING'),
                  const SizedBox(width: 8),
                  _buildFilterChip('CONFIRMED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('COMPLETED'),
                  const SizedBox(width: 8),
                  _buildFilterChip('CANCELED'),
                ],
              ),
            ),
          ),
          // Lista de reservas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReservations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_busy,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma reserva encontrada',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadReservations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredReservations.length,
                          itemBuilder: (context, index) {
                            final reservation = _filteredReservations[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () =>
                                    _showStatusChangeDialog(reservation),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Reserva #${reservation.id}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${reservation.reservationDate.day.toString().padLeft(2, '0')}/${reservation.reservationDate.month.toString().padLeft(2, '0')}/${reservation.reservationDate.year} ${reservation.reservationDate.hour.toString().padLeft(2, '0')}:${reservation.reservationDate.minute.toString().padLeft(2, '0')}',
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                  reservation.status),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getStatusIcon(
                                                      reservation.status),
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _getStatusText(
                                                      reservation.status),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              size: 20,
                                              color: Colors.grey[600]),
                                          const SizedBox(width: 8),
                                          Text(
                                              'Cliente ID: ${reservation.userId}'),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.restaurant,
                                              size: 20,
                                              color: Colors.grey[600]),
                                          const SizedBox(width: 8),
                                          Text(
                                              'Restaurante ID: ${reservation.restaurantId}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon,
              color: color == Colors.white
                  ? Colors.deepOrange
                  : Colors.deepOrange),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color == Colors.white ? Colors.deepOrange : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color == Colors.white
                  ? Colors.deepOrange.shade700
                  : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    final isSelected = _filterStatus == status;
    final label = status == 'TODAS' ? 'Todas' : _getStatusText(status);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = status);
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue,
      backgroundColor: Colors.grey[200],
    );
  }
}
