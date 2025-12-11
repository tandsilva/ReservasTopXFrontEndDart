class Restaurant {
  final int? id;
  final String nomeFantasia;
  final String razaoSocial;
  final String cnpj;
  final String email;
  final String telefone;
  final String endereco;
  final String categoria;
  final DateTime? createdAt;
  final int? userId;

  Restaurant({
    this.id,
    required this.nomeFantasia,
    required this.razaoSocial,
    required this.cnpj,
    required this.email,
    required this.telefone,
    required this.endereco,
    required this.categoria,
    this.createdAt,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nomeFantasia': nomeFantasia,
      'razaoSocial': razaoSocial,
      'cnpj': cnpj,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'categoria': categoria,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (userId != null) 'userId': userId,
    };
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] is int ? json['id'] : (json['id'] as num?)?.toInt(),
      nomeFantasia: json['nomeFantasia'] ?? '',
      razaoSocial: json['razaoSocial'] ?? '',
      cnpj: json['cnpj'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'] ?? '',
      endereco: json['endereco'] ?? '',
      categoria: json['categoria'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      userId: json['userId'] is int
          ? json['userId']
          : (json['userId'] as num?)?.toInt(),
    );
  }
}
