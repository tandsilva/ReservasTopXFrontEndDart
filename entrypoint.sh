
#!/usr/bin/env bash
set -e

# Default para 8080 se PORT não estiver setada
export PORT="${PORT:-8080}"

# Renderiza template substituindo ${PORT}
envsubst '${PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Sobe o nginx
exec "$@"
