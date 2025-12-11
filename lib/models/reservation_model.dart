class Reservation {
  final int? id;
  final int userId;
  final int restaurantId;
  final DateTime reservationDate;
  final DateTime? createdAt;
  final String status; // PENDING, CONFIRMED, CANCELED, COMPLETED

  Reservation({
    this.id,
    required this.userId,
    required this.restaurantId,
    required this.reservationDate,
    this.createdAt,
    this.status = 'PENDING',
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'reservationDate': reservationDate.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      'status': status,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['userId'],
      restaurantId: json['restaurantId'],
      reservationDate: DateTime.parse(json['reservationDate']),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      status: json['status'] ?? 'PENDING',
    );
  }

  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'Pendente';
      case 'CONFIRMED':
        return 'Confirmada';
      case 'CANCELED':
        return 'Cancelada';
      case 'COMPLETED':
        return 'Concluída';
      default:
        return status;
    }
  }
}
