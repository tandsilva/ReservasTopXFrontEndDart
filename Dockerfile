
# ===== Stage 1: Build Flutter Web =====
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Evita rodar no root só se quiser tirar o warning (opcional):
# RUN adduser -D flutteruser
# USER flutteruser

WORKDIR /app

# 1) Copiar apenas pubspec para aproveitar cache do pub get
COPY pubspec.* ./
RUN flutter config --enable-web
RUN flutter pub get

# 2) Agora copie o restante do app
COPY . .

# 3) Se o projeto ainda não tiver a pasta web/, cria automaticamente
#    (isso resolve o erro "This project is not configured for the web")
RUN test -d web || flutter create . --platforms web

# 4) Build web (adicione dart-define se precisa passar URL do backend)
# Exemplo: --dart-define=API_BASE_URL=https://seuservice.up.railway.app
RUN flutter build web --release

# ===== Stage 2: Serve with Nginx =====
FROM nginx:alpine

# Copia o build gerado
COPY --from=build /app/build/web /usr/share/nginx/html

# Copia a config do Nginx (SPA + gzip)
COPY nginx.conf /etc/nginx/nginx.conf

# Em Railway, a plataforma injeta a variável PORT: mapeamos para Nginx.
# Você pode manter EXPOSE 8080, mas é comum usar 80. Se quiser usar a PORT:
# Vamos manter 8080, mas ver nota abaixo.
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
