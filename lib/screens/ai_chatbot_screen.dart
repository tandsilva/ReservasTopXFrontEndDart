import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../models/restaurant_model.dart';
import 'restaurant_detail_screen.dart';

class AIChatbotScreen extends StatefulWidget {
  final int? userId;

  const AIChatbotScreen({super.key, this.userId});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        'Olá! Sou seu assistente virtual de reservas. Como posso ajudar você hoje?');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    setState(() {
      _isLoading = true;
    });

    final result = await AIService.chatAssistant(message, widget.userId);

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      final data = result['data'] as Map<String, dynamic>;
      String botMessage = data['message'] ?? 'Desculpe, não entendi.';

      // Se houver restaurantes na resposta, adicionar ao final
      if (data['restaurants'] != null) {
        final restaurants = (data['restaurants'] as List)
            .map((r) => Restaurant.fromJson(r))
            .toList();

        _addBotMessage(botMessage);

        // Adicionar cards de restaurantes
        for (var restaurant in restaurants) {
          _addRestaurantCard(restaurant);
        }
      } else {
        _addBotMessage(botMessage);
      }
    } else {
      _addBotMessage('Desculpe, ocorreu um erro: ${result['message']}');
    }
  }

  void _addRestaurantCard(Restaurant restaurant) {
    setState(() {
      _messages.add({
        'text': null,
        'restaurant': restaurant,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.blue),
            SizedBox(width: 8),
            Text('Assistente Virtual IA'),
          ],
        ),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 8),
                        Text('Assistente está digitando...'),
                      ],
                    ),
                  );
                }

                final message = _messages[index];

                if (message['restaurant'] != null) {
                  final restaurant = message['restaurant'] as Restaurant;
                  return _buildRestaurantCard(restaurant);
                }

                return _buildMessageBubble(message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['isUser'] as bool;
    final text = message['text'] as String;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.restaurant, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.nomeFantasia,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.category,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.categoria,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
