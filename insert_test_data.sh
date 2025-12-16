#!/bin/bash

# Script para inserir dados de teste no ReservasTopX
# Execute este script quando o banco PostgreSQL estiver rodando

echo "🔄 Inserindo dados de teste no ReservasTopX..."

# Verificar se o container está rodando
if ! docker ps | grep -q postgres_reservas; then
    echo "❌ Container PostgreSQL não está rodando!"
    echo "Execute: docker start postgres_reservas"
    exit 1
fi

# Caminho do arquivo SQL
SQL_FILE="/home/jarin/Área de Trabalho/Task-IA/dartOne/test_data.sql"

if [ ! -f "$SQL_FILE" ]; then
    echo "❌ Arquivo test_data.sql não encontrado!"
    exit 1
fi

echo "📁 Executando script SQL..."
echo "Arquivo: $SQL_FILE"

# Tentar conectar e executar o script
# Nota: Você pode precisar ajustar as credenciais do banco
docker exec -i postgres_reservas psql -U postgres -d reservastopx < "$SQL_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Dados inseridos com sucesso!"
    echo ""
    echo "📊 Verificando dados inseridos:"

    # Verificar quantos registros foram inseridos
    docker exec -i postgres_reservas psql -U postgres -d reservastopx -c "
    SELECT 'Users' as tabela, COUNT(*) as quantidade FROM users
    UNION ALL
    SELECT 'Restaurants', COUNT(*) FROM restaurants
    UNION ALL
    SELECT 'Reservations', COUNT(*) FROM reservations
    UNION ALL
    SELECT 'Promotions', COUNT(*) FROM promotions;
    " 2>/dev/null

else
    echo "❌ Erro ao executar script SQL"
    echo ""
    echo "🔧 Possíveis soluções:"
    echo "1. Verifique se o banco está rodando: docker ps"
    echo "2. Verifique as credenciais do banco"
    echo "3. Execute manualmente: docker exec -it postgres_reservas psql -U [user] -d [database]"
    echo "4. Ou use o botão 'Inserir Dados de Teste' no app Flutter"
fi

echo ""
echo "🎯 Ou simplesmente use o botão 📊 no Dashboard de Insights IA do app!"