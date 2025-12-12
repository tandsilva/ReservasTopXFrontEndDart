
# ===== Stage 1: Build Flutter Web =====
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Habilita Web
RUN flutter config --enable-web

# Cache de deps
COPY pubspec.* ./
RUN flutter pub get

# Código
COPY . .

# Cria suporte web se faltar a pasta
RUN test -d web || flutter create . --platforms web

# Injeta a URL da API (se necessário) via ARG/ENV
ARG API_BASE_URL
ENV API_BASE_URL=${API_BASE_URL}
RUN flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL}

# ===== Stage 2: Nginx (SPA + porta dinâmica) =====
FROM nginx:alpine

# envsubst
RUN apk add --no-cache bash gettext

# Build
COPY --from=build /app/build/web /usr/share/nginx/html

# Template e entrypoint
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose (aid debugging; PORT é dinâmico)
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
