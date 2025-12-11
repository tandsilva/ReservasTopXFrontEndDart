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
              leading: Icon(Icons.schedule, color: Colors.blue),
              title: const Text('Pendente'),
              onTap: () {
                Navigator.pop(context);
                if (reservation.id != null) {
                  _updateReservationStatus(reservation.id!, 'PENDING');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Confirmada'),
              onTap: () {
                Navigator.pop(context);
                if (reservation.id != null) {
                  _updateReservationStatus(reservation.id!, 'CONFIRMED');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.done_all, color: Colors.blue),
              title: const Text('Concluída'),
              onTap: () {
                Navigator.pop(context);
                if (reservation.id != null) {
                  _updateReservationStatus(reservation.id!, 'COMPLETED');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
