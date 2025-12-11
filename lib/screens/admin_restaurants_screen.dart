import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/restaurant_model.dart';

class AdminRestaurantsScreen extends StatefulWidget {
  final int? userId;

  const AdminRestaurantsScreen({super.key, this.userId});

  @override
  State<AdminRestaurantsScreen> createState() => _AdminRestaurantsScreenState();
}

class _AdminRestaurantsScreenState extends State<AdminRestaurantsScreen> {
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() => _isLoading = true);
    try {
      print('🔄 Carregando restaurantes...'); // Debug
      final result = await ApiService.getAllRestaurants();
      print('📦 Resultado: $result'); // Debug

      if (result['success'] == true && result['data'] != null) {
        // O ApiService já retorna List<Restaurant>, não precisa converter!
        final List<Restaurant> restaurants = result['data'] as List<Restaurant>;
        print('📋 Total de restaurantes: ${restaurants.length}'); // Debug

        setState(() {
          _restaurants = restaurants;
          _isLoading = false;
        });
        print('✅ ${_restaurants.length} restaurantes carregados'); // Debug
      } else {
        print('⚠️ Nenhum restaurante encontrado'); // Debug
        setState(() => _isLoading = false);
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao carregar restaurantes: $e'); // Debug
      print('📚 Stack trace: $stackTrace'); // Debug
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar restaurantes: $e')),
        );
      }
    }
  }

  void _showAddRestaurantDialog() {
    final formKey = GlobalKey<FormState>();
    final nomeFantasiaController = TextEditingController();
    final razaoSocialController = TextEditingController();
    final cnpjController = TextEditingController();
    final emailController = TextEditingController();
    final telefoneController = TextEditingController();
    final enderecoController = TextEditingController();
    final categoriaController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Restaurante'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeFantasiaController,
                  decoration: const InputDecoration(
                    labelText: 'Nome Fantasia*',
                    prefixIcon: Icon(Icons.restaurant),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: razaoSocialController,
                  decoration: const InputDecoration(
                    labelText: 'Razão Social*',
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cnpjController,
                  decoration: const InputDecoration(
                    labelText: 'CNPJ*',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email*',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone*',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: enderecoController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço*',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoriaController,
                  decoration: const InputDecoration(
                    labelText: 'Categoria*',
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                print('🔵 userId recebido: ${widget.userId}'); // Debug

                try {
                  final restaurant = Restaurant(
                    nomeFantasia: nomeFantasiaController.text,
                    razaoSocial: razaoSocialController.text,
                    cnpj: cnpjController.text,
                    email: emailController.text,
                    telefone: telefoneController.text,
                    endereco: enderecoController.text,
                    categoria: categoriaController.text,
                    userId: widget.userId,
                  );

                  print(
                      '🔵 Restaurant criado: ${restaurant.toJson()}'); // Debug

                  final result = await ApiService.createRestaurant(restaurant);

                  print('🔵 Resultado da API: $result'); // Debug

                  if (context.mounted) {
                    if (result['success'] == true) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Restaurante criado com sucesso!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadRestaurants();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Erro: ${result['message'] ?? 'Erro desconhecido'}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print('❌ Exceção ao criar restaurante: $e'); // Debug
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao criar restaurante: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showRestaurantDetails(Restaurant restaurant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.restaurant, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(restaurant.nomeFantasia)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('ID', restaurant.id.toString(), Icons.tag),
              const Divider(),
              _buildInfoRow(
                  'Razão Social', restaurant.razaoSocial, Icons.business),
              const Divider(),
              _buildInfoRow('CNPJ', restaurant.cnpj, Icons.badge),
              const Divider(),
              _buildInfoRow('Email', restaurant.email, Icons.email),
              const Divider(),
              _buildInfoRow('Telefone', restaurant.telefone, Icons.phone),
              const Divider(),
              _buildInfoRow('Endereço', restaurant.endereco, Icons.location_on),
              const Divider(),
              _buildInfoRow('Categoria', restaurant.categoria, Icons.category),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _restaurants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum restaurante cadastrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Clique no + para adicionar',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRestaurants,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = _restaurants[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => _showRestaurantDetails(restaurant),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.restaurant,
                                        color: Colors.blue,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            restaurant.nomeFantasia,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            restaurant.categoria,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right,
                                        color: Colors.grey[400]),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        restaurant.endereco,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.phone,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      restaurant.telefone,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRestaurantDialog,
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Novo Restaurante'),
      ),
    );
  }
}
