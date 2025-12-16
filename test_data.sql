-- Script SQL para inserir dados de teste no ReservasTopX
-- Execute este script no seu banco de dados PostgreSQL/MySQL

-- Inserir usuários de teste
INSERT INTO users (username, password, email, role, created_at) VALUES
('admin', '$2a$10$8K3dsH8VzJcG8VzJcG8VzJcG8VzJcG8VzJcG8VzJcG8VzJcG8VzJc', 'admin@reservastop.com', 'ADMIN', NOW()),
('user1', '$2a$10$8K3dsH8VzJcG8VzJcG8VzJcG8VzJcG8VzJcG8VzJcG8VzJcG8VzJc', 'user1@email.com', 'USER', NOW()),
('user2', '$2a$10$8K3dsH8VzJcG8VzJcG8VzJcG8VzJcG8VzJcG8VzJcG8VzJcG8VzJc', 'user2@email.com', 'USER', NOW());

-- Inserir restaurantes de teste
INSERT INTO restaurants (nome_fantasia, razao_social, cnpj, email, telefone, endereco, categoria, user_id, created_at) VALUES
('Restaurante Sabor Brasil', 'Sabor Brasil Ltda', '12.345.678/0001-90', 'contato@saborbrasil.com', '(11) 99999-0001', 'Rua das Flores, 123 - São Paulo/SP', 'Brasileira', 1, NOW()),
('Cantina Italiana', 'Cantina Italiana Ltda', '23.456.789/0001-80', 'contato@cantinaitaliana.com', '(11) 99999-0002', 'Av. Paulista, 456 - São Paulo/SP', 'Italiana', 1, NOW()),
('Sushi House', 'Sushi House Ltda', '34.567.890/0001-70', 'contato@sushihouse.com', '(11) 99999-0003', 'Rua Augusta, 789 - São Paulo/SP', 'Japonesa', 1, NOW()),
('Churrascaria Gaúcha', 'Churrascaria Gaúcha Ltda', '45.678.901/0001-60', 'contato@churrascaria.com', '(11) 99999-0004', 'Av. Brasil, 101 - São Paulo/SP', 'Churrascaria', 1, NOW());

-- Inserir reservas de teste (últimos 30 dias)
INSERT INTO reservations (user_id, restaurant_id, reservation_date, status, created_at, updated_at) VALUES
-- Restaurante 1 (Sabor Brasil) - 15 reservas
(2, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
(2, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
(3, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW()),
(2, 1, DATE_SUB(NOW(), INTERVAL 4 DAY), 'CANCELED', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW()),
(3, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW()),
(2, 1, DATE_SUB(NOW(), INTERVAL 6 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW()),
(3, 1, DATE_SUB(NOW(), INTERVAL 7 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 11 DAY), NOW()),
(2, 1, DATE_SUB(NOW(), INTERVAL 8 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW()),
(3, 1, DATE_SUB(NOW(), INTERVAL 9 DAY), 'CANCELED', DATE_SUB(NOW(), INTERVAL 13 DAY), NOW()),
(2, 1, DATE_SUB(NOW(), INTERVAL 10 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW()),
(3, 1, DATE_SUB(NOW(), INTERVAL 11 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 15 DAY), NOW()),
(2, 1, DATE_SUB(NOW(), INTERVAL 12 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 16 DAY), NOW()),
(3, 1, DATE_SUB(NOW(), INTERVAL 13 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 17 DAY), NOW()),
(2, 1, DATE_SUB(NOW(), INTERVAL 14 DAY), 'PENDING', DATE_SUB(NOW(), INTERVAL 18 DAY), NOW()),
(3, 1, DATE_SUB(NOW(), INTERVAL 15 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 19 DAY), NOW()),

-- Restaurante 2 (Cantina Italiana) - 12 reservas
(2, 2, DATE_SUB(NOW(), INTERVAL 1 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
(3, 2, DATE_SUB(NOW(), INTERVAL 2 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
(2, 2, DATE_SUB(NOW(), INTERVAL 3 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
(3, 2, DATE_SUB(NOW(), INTERVAL 4 DAY), 'CANCELED', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
(2, 2, DATE_SUB(NOW(), INTERVAL 5 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW()),
(3, 2, DATE_SUB(NOW(), INTERVAL 6 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW()),
(2, 2, DATE_SUB(NOW(), INTERVAL 7 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW()),
(3, 2, DATE_SUB(NOW(), INTERVAL 8 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW()),
(2, 2, DATE_SUB(NOW(), INTERVAL 9 DAY), 'PENDING', DATE_SUB(NOW(), INTERVAL 11 DAY), NOW()),
(3, 2, DATE_SUB(NOW(), INTERVAL 10 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW()),
(2, 2, DATE_SUB(NOW(), INTERVAL 11 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 13 DAY), NOW()),
(3, 2, DATE_SUB(NOW(), INTERVAL 12 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW()),

-- Restaurante 3 (Sushi House) - 8 reservas
(2, 3, DATE_SUB(NOW(), INTERVAL 1 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
(3, 3, DATE_SUB(NOW(), INTERVAL 3 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
(2, 3, DATE_SUB(NOW(), INTERVAL 5 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
(3, 3, DATE_SUB(NOW(), INTERVAL 7 DAY), 'CANCELED', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW()),
(2, 3, DATE_SUB(NOW(), INTERVAL 9 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW()),
(3, 3, DATE_SUB(NOW(), INTERVAL 11 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 12 DAY), NOW()),
(2, 3, DATE_SUB(NOW(), INTERVAL 13 DAY), 'PENDING', DATE_SUB(NOW(), INTERVAL 14 DAY), NOW()),
(3, 3, DATE_SUB(NOW(), INTERVAL 15 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 16 DAY), NOW()),

-- Restaurante 4 (Churrascaria Gaúcha) - 18 reservas
(2, 4, DATE_SUB(NOW(), INTERVAL 1 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
(3, 4, DATE_SUB(NOW(), INTERVAL 1 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
(2, 4, DATE_SUB(NOW(), INTERVAL 2 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
(3, 4, DATE_SUB(NOW(), INTERVAL 2 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 3 DAY), NOW()),
(2, 4, DATE_SUB(NOW(), INTERVAL 3 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
(3, 4, DATE_SUB(NOW(), INTERVAL 3 DAY), 'CANCELED', DATE_SUB(NOW(), INTERVAL 4 DAY), NOW()),
(2, 4, DATE_SUB(NOW(), INTERVAL 4 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
(3, 4, DATE_SUB(NOW(), INTERVAL 4 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
(2, 4, DATE_SUB(NOW(), INTERVAL 5 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
(3, 4, DATE_SUB(NOW(), INTERVAL 5 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 6 DAY), NOW()),
(2, 4, DATE_SUB(NOW(), INTERVAL 6 DAY), 'PENDING', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW()),
(3, 4, DATE_SUB(NOW(), INTERVAL 6 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 7 DAY), NOW()),
(2, 4, DATE_SUB(NOW(), INTERVAL 7 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW()),
(3, 4, DATE_SUB(NOW(), INTERVAL 7 DAY), 'CANCELED', DATE_SUB(NOW(), INTERVAL 8 DAY), NOW()),
(2, 4, DATE_SUB(NOW(), INTERVAL 8 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW()),
(3, 4, DATE_SUB(NOW(), INTERVAL 8 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 9 DAY), NOW()),
(2, 4, DATE_SUB(NOW(), INTERVAL 9 DAY), 'CONFIRMED', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW()),
(3, 4, DATE_SUB(NOW(), INTERVAL 9 DAY), 'COMPLETED', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW());

-- Inserir promoções de teste
INSERT INTO promotions (title, restaurant_id, description, discount, valid_until, image_url, active, created_at) VALUES
('20% OFF na primeira reserva!', 1, 'Válido para novos clientes', '20%', '2025-12-31', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800', true, NOW()),
('Sobremesa Grátis', 2, 'Em reservas acima de R$ 100', 'Grátis', '2025-12-15', 'https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800', true, NOW()),
('2 por 1 em Drinks', 3, 'Válido de segunda a quinta-feira', '50%', '2025-12-30', 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800', true, NOW()),
('Rodízio Especial', 4, 'Rodízio completo por R$ 59,90', 'R$ 59,90', '2025-12-20', 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800', true, NOW());

COMMIT;

-- Verificar dados inseridos
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Restaurants', COUNT(*) FROM restaurants
UNION ALL
SELECT 'Reservations', COUNT(*) FROM reservations
UNION ALL
SELECT 'Promotions', COUNT(*) FROM promotions;