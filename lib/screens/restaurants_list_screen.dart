import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';
import '../services/ai_service.dart';
import 'restaurant_detail_screen.dart';

class RestaurantsListScreen extends StatefulWidget {
  final int? userId;

  const RestaurantsListScreen({super.key, this.userId});

  @override
  State<RestaurantsListScreen> createState() => _RestaurantsListScreenState();
}

class _RestaurantsListScreenState extends State<RestaurantsListScreen> {
  List<Restaurant> _restaurants = [];
  List<Restaurant> _recommendations = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // URLs de imagens de exemplo baseadas na categoria
  String _getRestaurantImageUrl(Restaurant restaurant) {
    final category = restaurant.categoria.toLowerCase();
    final imageMap = {
      'italiano':
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
      'japonês':
          'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
      'japones':
          'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
      'pizzaria':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
      'churrascaria':
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
      'hamburgueria':
          'https://images.unsplash.com/photo-1550547660-d9450f859349?w=400',
      'bar':
          'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=400',
      'lanchonete':
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
    };

    for (var entry in imageMap.entries) {
      if (category.contains(entry.key)) {
        return entry.value;
      }
    }

    // Imagem padrão
    return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400';
  }

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getAllRestaurants();

    if (result['success']) {
      setState(() {
        _restaurants = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecommendations() async {
    if (widget.userId == null) return;

    final result = await AIService.getRecommendations(widget.userId);

    if (result['success']) {
      setState(() {
        _recommendations = result['data'];
      });
    }
  }

  Future<void> _performIntelligentSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
      });
      _loadRestaurants();
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AIService.intelligentSearch(query, widget.userId);

    if (result['success']) {
      setState(() {
        _restaurants = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurantes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Busca Inteligente'),
                  content: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText:
                          'Ex: restaurante romântico, lugar barato, melhor sushi...',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                    onSubmitted: (value) {
                      Navigator.pop(context);
                      _performIntelligentSearch(value);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        Navigator.pop(context);
                        _loadRestaurants();
                      },
                      child: const Text('Limpar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _performIntelligentSearch(_searchController.text);
                      },
                      child: const Text('Buscar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRestaurants,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSearching ? Icons.search_off : Icons.restaurant,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching
                  ? 'Nenhum restaurante encontrado para sua busca.'
                  : 'Nenhum restaurante cadastrado ainda.',
            ),
            if (_isSearching) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _loadRestaurants();
                },
                child: const Text('Ver todos os restaurantes'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_isSearching)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resultados para: "${_searchController.text}"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                    });
                    _loadRestaurants();
                  },
                ),
              ],
            ),
          ),
        if (!_isSearching && _recommendations.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Recomendados para Você',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _recommendations.length,
                    itemBuilder: (context, index) {
                      final restaurant = _recommendations[index];
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 8),
                        child: Card(
                          elevation: 3,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RestaurantDetailScreen(
                                    restaurant: restaurant,
                                    userId: widget.userId,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagem do restaurante
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      Image.network(
                                        _getRestaurantImageUrl(restaurant),
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            height: 120,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.restaurant,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            height: 120,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                      ),
                                      // Badge de recomendação IA
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Informações do restaurante
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        restaurant.nomeFantasia,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.category,
                                              size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              restaurant.categoria,
                                              style:
                                                  const TextStyle(fontSize: 11),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadRestaurants();
              await _loadRecommendations();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index];
                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.restaurant, color: Colors.white),
                    ),
                    title: Text(
                      restaurant.nomeFantasia,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.category,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(restaurant.categoria),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                restaurant.endereco,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestaurantDetailScreen(
                            restaurant: restaurant,
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
