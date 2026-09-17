# ✅ SLTNOC — Fixing Plan & TODO Checklist

> **Created:** September 13, 2026  
> **Updated:** September 13, 2026  
> **Owner:** SLTNOC Engineering Team  
> **Purpose:** Step-by-step remediation guide based on `audit_report.md`

---

## 📊 Progress Overview

| Phase | Category | Status |
|---|---|---|
| Phase 1 | Credential Storage Migration | ✅ **COMPLETED** |
| Phase 2 | Backend & API Security | ✅ **COMPLETED** |
| Phase 3 | Code Quality & Refactoring | 🟡 In Progress |
| Phase 4 | Asset Optimization & Performance | 🟡 In Progress |
| Phase 5 | Unit & Integration Testing | ⬜ Pending |
| Phase 6 | Documentation & CI/CD | ⬜ Pending |

---

## 🔴 Phase 1: Credential Security (COMPLETED ✅)

- [x] **SEC-01-A** Audit all credential read/write operations across `lib/`
- [x] **SEC-01-B** Upgrade `SecureStorageService` with:
  - Android `EncryptedSharedPreferences: true`
  - iOS `KeychainAccessibility.first_unlock`
  - Helper methods: `saveCredentials()`, `getUsername()`, `getPassword()`, `getDisplayName()`, `hasValidCredentials()`, `clearCredentials()`
  - Server config helpers: `getServerUrl()`, `getUseLocalServer()`
- [x] **SEC-01-C** Implement automatic startup migration (`migrateFromSharedPreferences()`) to import any legacy plaintext credentials and purge them from `SharedPreferences`
- [x] **SEC-01-D** Update `main.dart` to trigger migration on startup and verify login using `SecureStorageService`
- [x] **SEC-01-E** Update `login_page.dart` to save credentials via `saveCredentials()` and remove legacy commented `SharedPreferences` blocks
- [x] **SEC-01-F** Update `settings_page.dart` logout to call `clearCredentials()`
- [x] **SEC-01-G** Update `current_alarms.dart` and `selected_metro_region.dart` to read settings from `SecureStorageService`

---

## 🔴 Phase 2: Backend Security (COMPLETED ✅)

- [x] **SEC-02-A** Guard `_DEV_MODE` in `login_page.dart` with `bool.fromEnvironment('DEV_MODE', defaultValue: false)`
- [x] **SEC-03-A** Restrict CORS in `server.js` to authorized origins (mobile client & local LAN subnet)
- [x] **SEC-04-A** Implement JWT & API Key authentication middleware for sensitive Node.js endpoints (`/api/manual-escalations`, `/api/chat`, `/api/chat-stream`, `/api/critical-alerts`, `/api/alarms1`, `/api/alarms2`, `/api/provinces`, `/api/alarm-details`, `/api/node-details`)
- [x] **SEC-04-B** Add `/api/auth/token` and `/api/auth/verify` endpoints on Node backend to issue secure tokens
- [x] **SEC-05-A** Sanitize connection error messages in `manual_escalation_service.dart` to hide raw internal URLs
- [x] **SEC-06-A** Replace bare `print()` statements with `if (kDebugMode) debugPrint(...)` and prevent credential exposure in logs
- [x] **SEC-07-A** Parameterize SQL queries across `routes/alarms1.js`, `routes/provinces.js`, and `routes/alarmsDetails1.js` using `request.input()` to eliminate SQL Injection vulnerabilities
- [x] **SEC-08-A** Remove hardcoded database passwords and legacy configuration from `routes/dbConfig.js` and `routes/alarms1.js`

---

## 🟡 Phase 3: Code Quality & Architecture

- [x] **CQ-01-A** Split `ai_chat_page.dart` (~2400 lines) into:
  - `lib/ai_chat/widgets/` (markdown text, message bubble, chat input)
  - `lib/ai_chat/services/` (chat stream service, speech service)
  - `lib/ai_chat/models/` (chat message, session models)
- [ ] **CQ-02-A** Remove or archive `lib/backup.dart` (58KB dead file)
- [ ] **CQ-03-A** Introduce Riverpod for centralized state management (replacing scattered `setState` + `Timer.periodic`)
- [ ] **CQ-04-A** Migrate manual escalations from flat file (`manual_escalations.json`) to the SQL Server (TMS) database
- [ ] **CQ-05-A** Deduplicate Azure Key Vault credential retrieval between `server.js` and `routes/db.js` into `routes/utils/keyVault.js`

---

## 🟡 Phase 4: Asset Optimization & Performance

- [x] **PERF-01-A** Convert `assets/chatbot-icon.png` (1.2MB) to WebP format (<100KB) — *Compressed to 47.5KB (96% reduction)*
- [ ] **PERF-02-A** Compress `assets/appbarbg2.png` (471KB)
- [ ] **PERF-03-A** Delete unreferenced assets (`assets/CardBGMetros1-5.png`, `assets/appbarbg20-31.png`, `assets/Logo2Old.png`, etc.)
- [ ] **PERF-04-A** Implement client-side location caching for network nodes to avoid repetitive SOAP calls

---

## 🟡 Phase 5: Automated Testing

- [ ] **TEST-01-A** Unit test `SecureStorageService` (save, read, clear, migration)
- [ ] **TEST-01-B** Unit test `ManualEscalationQueue` offline queuing & sync logic
- [ ] **TEST-01-C** Unit test `FaultCountService` total fault calculation
- [ ] **TEST-01-D** Widget test `LoginPage` validation and submit states
- [ ] **TEST-01-E** Add Jest tests for Node.js routes (`manualEscalations`, `aiTools`)

---

## 🟢 Phase 6: Documentation & CI/CD

- [ ] **DOC-01-A** Replace default Flutter `README.md` in root with comprehensive project guide
- [ ] **DOC-02-A** Update `pubspec.yaml` description
- [x] **DOC-ENV-A** Create `docs/environment_variables.md` documenting `--dart-define` and `.env` configuration
- [ ] **CI-01-A** Add GitHub Actions / Azure DevOps pipeline for `flutter analyze` and `flutter test`

---

*SLTNOC Fixing Plan — Maintained by Antigravity AI*
