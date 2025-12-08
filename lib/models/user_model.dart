class User {
  final int? id;
  final String username;
  final String password;
  final String role; // "ADMIN" ou "USER"
  final String cpf;
  final String telefone;
  final String email;
  final int pontos;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.cpf,
    required this.telefone,
    required this.email,
    this.pontos = 0,
  });

  // Converter para JSON (enviar para o backend)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'role': role,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'pontos': pontos,
    };
  }

  // Criar a partir do JSON (receber do backend)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'USER',
      cpf: json['cpf'] ?? '',
      telefone: json['telefone'] ?? '',
      email: json['email'] ?? '',
      pontos: json['pontos'] ?? 0,
    );
  }
}
