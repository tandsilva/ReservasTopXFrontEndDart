# Reservas Top - Frontend Flutter

## 🎯 O que foi implementado

### ✅ Cadastro de Usuário (User Create)

1. **Model** (`lib/models/user_model.dart`)
   - Classe User com todos os campos do backend
   - Métodos `toJson()` e `fromJson()` para converter de/para JSON

2. **Service** (`lib/services/api_service.dart`)
   - Método `createUser()` - POST `/users`
   - Método `login()` - POST `/auth/login`
   - Método `forgotPassword()` - POST `/password-reset/forgot-password`
   - Método `resetPassword()` - POST `/password-reset/reset-password`
   - Base URL: `http://localhost:8080`

3. **Telas Implementadas**
   - `register_screen.dart` - Cadastro completo com validações
   - `login_screen.dart` - Autenticação de usuário
   - `forgot_password_screen.dart` - Solicitar recuperação de senha
   - `reset_password_screen.dart` - Redefinir senha com token

### ✅ Login (Auth)
- Endpoint: `POST /auth/login`
- Campos: username, password
- Retorna: token de autenticação
- Link "Esqueceu a senha?" para recuperação

### ✅ Recuperação de Senha (Password Reset)
- **Etapa 1**: Forgot Password
  - Endpoint: `POST /password-reset/forgot-password`
  - Campo: email
  - Envia token por email
  
- **Etapa 2**: Reset Password
  - Endpoint: `POST /password-reset/reset-password`
  - Campos: token, newPassword
  - Redefine a senha com o token recebido

## 🚀 Como testar

### 1. Verificar se o backend está rodando
```bash
# O backend deve estar rodando em http://localhost:8080
```

### 2. Testar em emulador Android/iOS
```bash
flutter run
```

### 3. Testar em dispositivo físico
Se for testar em celular físico, você precisa:
- Conectar na mesma rede WiFi
- Alterar a URL em `lib/services/api_service.dart`:
  ```dart
  static const String baseUrl = 'http://SEU_IP:8080';
  ```
  (Exemplo: `http://192.168.1.100:8080`)

## 📱 Fluxos da Aplicação

### Fluxo 1: Cadastro
1. **Tela Inicial** → Botão "Criar Conta"
2. **Tela de Cadastro** → Preenche formulário (username, password, CPF, telefone, email, role)
3. **Sucesso** → Volta para tela inicial

### Fluxo 2: Login
1. **Tela Inicial** → Link "Já tem conta? Faça login"
2. **Tela de Login** → Insere username e password
3. **Sucesso** → Autentica usuário (token salvo)

### Fluxo 3: Recuperação de Senha
1. **Tela de Login** → Link "Esqueceu a senha?"
2. **Forgot Password** → Insere email
3. **Email enviado** → Recebe token por email
4. **Reset Password** → Insere token + nova senha
5. **Sucesso** → Volta para tela inicial

## 🔧 Estrutura do Projeto

```
lib/
├── main.dart                          # Ponto de entrada, tela inicial
├── models/
│   └── user_model.dart                # Modelo de dados User
├── services/
│   └── api_service.dart               # Comunicação com backend (todos os endpoints)
└── screens/
    ├── register_screen.dart           # Tela de cadastro
    ├── login_screen.dart              # Tela de login
    ├── forgot_password_screen.dart    # Tela "esqueci a senha"
    └── reset_password_screen.dart     # Tela redefinir senha com token
```

## 📝 Próximos Passos

### Melhorias Sugeridas:
1. **Persistência de Token**
   - Salvar token no SharedPreferences após login
   - Adicionar middleware para verificar autenticação
   - Auto-login se token ainda válido

2. **Tela Principal Pós-Login**
   - Dashboard do usuário
   - Listagem de restaurantes
   - Sistema de reservas

3. **Endpoints de Reservas**
   - Me passe os endpoints de restaurantes e reservas do Swagger
   - Vou implementar as telas de listagem e criação de reservas

4. **Validações Avançadas**
   - Formatação de CPF (###.###.###-##)
   - Formatação de telefone ((##) #####-####)
   - Validação mais robusta de email

## 🐛 Troubleshooting

### Erro de conexão
- Verifique se o backend está rodando
- Teste a URL no navegador: `http://localhost:8080/swagger-ui/index.html`
- Se estiver em dispositivo físico, use o IP da máquina, não localhost

### Erro CORS
Se aparecer erro de CORS, adicione no backend (Spring Boot):
```java
@CrossOrigin(origins = "*")
```

## 🎨 Personalizações

Para mudar as cores do app, edite em `lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
```
