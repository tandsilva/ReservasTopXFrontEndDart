import 'package:flutter/material.dart';

class PromotionsScreen extends StatelessWidget {
  final int? userId;

  const PromotionsScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    // Lista de promoções mockadas (depois conectar com backend)
    final List<Map<String, dynamic>> promotions = [
      {
        'title': '20% OFF na primeira reserva!',
        'restaurant': 'Restaurante Sabor Brasil',
        'description':
            'Válido para novos clientes. Use o cupom: PRIMEIRAVISITA',
        'discount': '20%',
        'validUntil': '31/12/2025',
        'icon': Icons.local_offer,
        'color': Colors.green,
      },
      {
        'title': 'Sobremesa Grátis',
        'restaurant': 'Cantina Italiana',
        'description':
            'Ganhe uma sobremesa grátis em reservas acima de R\$ 100',
        'discount': 'Grátis',
        'validUntil': '15/12/2025',
        'icon': Icons.cake,
        'color': Colors.purple,
      },
      {
        'title': '2 por 1 em Drinks',
        'restaurant': 'Bar do Porto',
        'description': 'Válido de segunda a quinta-feira',
        'discount': '50%',
        'validUntil': '30/12/2025',
        'icon': Icons.local_bar,
        'color': Colors.blue,
      },
      {
        'title': 'Rodízio Especial',
        'restaurant': 'Churrascaria Gaúcha',
        'description': 'Rodízio completo por R\$ 59,90',
        'discount': 'R\$ 59,90',
        'validUntil': '20/12/2025',
        'icon': Icons.restaurant,
        'color': Colors.red,
      },
    ];

    return Scaffold(
      body: promotions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma promoção disponível',
                    style: TextStyle(fontSize: 18, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Volte em breve!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promo = promotions[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      _showPromotionDetails(context, promo);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header com ícone e desconto
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: promo['color'].withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: promo['color'],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  promo['icon'],
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      promo['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      promo['restaurant'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: promo['color'],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  promo['discount'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Body com descrição
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                promo['description'],
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Válido até ${promo['validUntil']}',
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
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showPromotionDetails(BuildContext context, Map<String, dynamic> promo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(promo['icon'], color: promo['color']),
            const SizedBox(width: 8),
            Expanded(child: Text(promo['title'])),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promo['restaurant'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(promo['description']),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text('Válido até ${promo['validUntil']}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navegar para fazer reserva no restaurante
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Vá para a aba Restaurantes para fazer sua reserva!'),
                ),
              );
            },
            child: const Text('Fazer Reserva'),
          ),
        ],
      ),
    );
  }
}
