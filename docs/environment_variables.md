# 🌐 SLTNOC — Environment Configuration Guide

This guide details how configuration is managed across the **Flutter mobile application** (via compile-time `--dart-define`) and the **Node.js Express backend** (via runtime `.env`).

---

## 📱 Flutter Mobile Application Configuration

All configuration in Flutter is centralized in [`lib/app_config.dart`](file:///D:/SLT_Projects/SLTNOC/lib/app_config.dart).

### 1. Supported Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `ENVIRONMENT` | String | `'production'` | Target environment: `development`, `staging`, or `production` |
| `API_BASE_URL` | String | `'https://sltnoc-api.azurewebsites.net'` | Node.js Backend API base URL |
| `SOAP_ENDPOINT` | String | `'https://fmt.slt.com.lk/fmt/WClogin.asmx'` | SLT internal SOAP server endpoint |
| `DEV_MODE` | bool | `false` | Enables quick dev bypass button on login screen |
| `DEV_USERNAME` | String | `'testuser'` | Pre-filled dev username when `DEV_MODE=true` |
| `DEV_PASSWORD` | String | `'dev-password'` | Pre-filled dev password when `DEV_MODE=true` |
| `DEV_DISPLAY_NAME` | String | `'Test User'` | Pre-filled dev display name when `DEV_MODE=true` |
| `API_KEY` | String | `'sltnoc-dev-secret-key-2026'` | API authentication key sent in `X-API-Key` header |

---

### 2. Usage Methods

#### Method A: Command-Line (`--dart-define`)
Pass variables individually via `--dart-define`:

```bash
# Run in local development mode pointing to local Express server
flutter run \
  --dart-define=ENVIRONMENT=development \
  --dart-define=API_BASE_URL=http://192.168.1.14:3000 \
  --dart-define=DEV_MODE=true

# Build production APK
flutter build apk --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=https://sltnoc-api.azurewebsites.net \
  --dart-define=DEV_MODE=false
```

#### Method B: JSON Config File (`--dart-define-from-file`)
Copy [`env.json.example`](file:///D:/SLT_Projects/SLTNOC/env.json.example) to `env.json`:

```bash
cp env.json.example env.json
```

Then run:
```bash
flutter run --dart-define-from-file=env.json
```

*(Note: `env.json` is automatically gitignored to prevent accidental credential commits.)*

#### Method C: VS Code `launch.json`
Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "SLTNOC (Local Dev)",
      "request": "launch",
      "type": "dart",
      "toolArgs": [
        "--dart-define-from-file=env.json"
      ]
    },
    {
      "name": "SLTNOC (Production)",
      "request": "launch",
      "type": "dart",
      "toolArgs": [
        "--dart-define=ENVIRONMENT=production",
        "--dart-define=DEV_MODE=false"
      ]
    }
  ]
}
```

---

## 🖥️ Node.js Backend Configuration

The Express backend loads environment variables on startup using `dotenv`.

### 1. Setup

Copy [`/.env.example`](file:///D:/SLT_Projects/SLTNOC/.env.example) to `/.env`:

```bash
cp .env.example .env
```

### 2. Supported Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `PORT` | Number | `3000` | Port for Express server to listen on |
| `NODE_ENV` | String | `'development'` | Environment mode (`development` or `production`) |
| `ALLOWED_ORIGINS` | String | `'https://sltnoc-api.azurewebsites.net,http://localhost:3000'` | Comma-separated list of allowed CORS origins |
| `API_KEY` | String | `'sltnoc-dev-secret-key-2026'` | Valid API key(s) accepted via `X-API-Key` or `Authorization: ApiKey` |
| `JWT_SECRET` | String | `(secure default)` | Secret key used to sign and verify Bearer JWT tokens |
| `JWT_EXPIRES_IN` | String | `'7d'` | Default expiration period for generated JWT tokens |
| `REQUIRE_AUTH` | bool | `'true'` | Set to `'false'` to disable authentication enforcement in development |
| `KEY_VAULT_NAME` | String | `""` (empty) | Azure Key Vault name for fetching DB secrets |
| `DB_USER` | String | `'sa'` | SQL Server username (if Key Vault is not used) |
| `DB_PASSWORD` | String | `""` | SQL Server password (if Key Vault is not used) |
| `DB_SERVER` | String | `'localhost\SQLEXPRESS'` | SQL Server host/instance |
| `DB_DATABASE` | String | `'TMS'` | Target database name |
| `DB_INSTANCE` | String | `'SQLEXPRESS'` | SQL Server named instance |
| `DB_PORT` | Number | `1433` | SQL Server TCP port |
| `OLLAMA_HOST` | String | `'http://localhost:11434'` | Ollama local AI server address |
| `OLLAMA_MODEL` | String | `'llama3'` | Ollama model tag |
| `DEBUG_CHUNKS` | bool | `false` | Log streaming SSE chunks to console |

---

## 🛡️ Security Best Practices

1. **Never commit `.env` or `env.json` to git**: Both are included in `.gitignore`.
2. **Production Builds**: In production APK and iOS builds, ensure `DEV_MODE=false` (which is the default).
3. **API Endpoints**: Point to `https://sltnoc-api.azurewebsites.net` in staging/production builds.
