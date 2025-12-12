
# ===== Stage 1: Build Flutter Web =====
FROM ghcr.io/cirruslabs/flutter:stable AS build

# (Opcional) evitar warning de root:
# RUN adduser -D flutteruser
# USER flutteruser

WORKDIR /app

# Habilita Web no SDK do Flutter
RUN flutter config --enable-web

# Cache eficiente: copia apenas pubspec e resolve deps
COPY pubspec.* ./
RUN flutter pub get

# Copia o restante do projeto
COPY . .

# Se não existir a pasta web/, cria (resolve "project not configured for web")
RUN test -d web || flutter create . --platforms web

# Recebe a URL da API como ARG/ENV e injeta no build
ARG API_BASE_URL
ENV API_BASE_URL=${API_BASE_URL}
RUN flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL}

# ===== Stage 2: Nginx como servidor estático (SPA) =====
FROM nginx:alpine

# Dependência para envsubst
RUN apk add --no-cache bash gettext

# Copia os arquivos gerados do build
COPY --from=build /app/build/web /usr/share/nginx/html

# Template do nginx que usa ${PORT}
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# EntryPoint que substitui ${PORT} e sobe o nginx
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Exponha 8080 (Railway pode mapear a PORT de runtime)
EXPOSE 8080

# Usa o entrypoint pra renderizar a conf com a PORT
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
