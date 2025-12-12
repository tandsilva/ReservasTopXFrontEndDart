# ===== Stage 1: Build Flutter Web =====
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Habilita Web
RUN flutter config --enable-web

# Cria um projeto vazio para garantir que web/ exista
RUN flutter create . --platforms web

# Agora sim: copiar pubspec e baixar deps
COPY pubspec.* ./
RUN flutter pub get

# Copiar o restante do código
COPY . .

# Build
ARG API_BASE_URL
ENV API_BASE_URL=${API_BASE_URL}
RUN flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL}

# ===== Stage 2: Nginx (SPA + porta dinâmica) =====
FROM nginx:alpine
RUN apk add --no-cache bash gettext

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
