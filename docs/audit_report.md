# 🔍 SLTNOC — Full Code & Project Audit Report

> **Audit Date:** September 13, 2026  
> **Auditor:** Antigravity AI (Professional Project Manager & App Developer)  
> **Project:** SLTNOC — SLT Network Operations Center Mobile Application  
> **Version Audited:** `1.0.0+1`  
> **Scope:** Full project — Flutter frontend, Node.js backend, assets, documentation, configuration

---

## 📋 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Audit Scope & Methodology](#2-audit-scope--methodology)
3. [Project Overview](#3-project-overview)
4. [Security Audit](#4-security-audit)
5. [Code Quality Audit](#5-code-quality-audit)
6. [Architecture Audit](#6-architecture-audit)
7. [Performance Audit](#7-performance-audit)
8. [Asset & Resource Audit](#8-asset--resource-audit)
9. [Backend / API Audit](#9-backend--api-audit)
10. [Testing Audit](#10-testing-audit)
11. [Documentation Audit](#11-documentation-audit)
12. [Dependency Audit](#12-dependency-audit)
13. [Findings Summary Table](#13-findings-summary-table)
14. [Risk Register](#14-risk-register)

---

## 1. Executive Summary

The SLTNOC application is a **mature, production-grade enterprise mobile platform** built for SLT (Sri Lanka Telecom) Network Operations Center engineers. It successfully integrates real-time SOAP alarm monitoring, Clarity OSS data, escalation management, Google Maps visualization, and an AI-powered chatbot with Sinhala language support.

**Overall Audit Result: 🟡 CONDITIONAL PASS**

The application is functionally complete and well-architected at a high level. Key security findings around credential handling have been identified and resolved (migrated to `flutter_secure_storage`). Remaining high-severity security findings (CORS and API authentication on the Node.js backend) must be resolved before further external exposure.

| Category | Score | Status |
|----------|-------|--------|
| Security | 75/100 | 🟡 Improved (Credentials Migrated) |
| Code Quality | 72/100 | 🟡 Good Progress |
| Architecture | 80/100 | 🟢 Solid Layering |
| Performance | 82/100 | 🟢 Good |
| Testing | 10/100 | 🔴 Critical Gap |
| Documentation | 85/100 | 🟢 Excellent Docs |
| Dependencies | 75/100 | 🟡 Minor Updates Needed |
| Assets/Resources | 68/100 | 🟡 Unused Assets Detected |
| **OVERALL** | **74/100** | **🟡 Solid Production Grade** |

---

## 2. Audit Scope & Methodology

### Scope
- **Flutter Source**: `lib/` (40+ Dart files)
- **Node.js Backend**: `server.js` + `routes/` (10 files)
- **Configuration**: `pubspec.yaml`, `package.json`, `.fvmrc`, `analysis_options.yaml`
- **Assets**: `assets/` (33 image files, 1 SSL certificate)
- **Documentation**: `docs/` (7 markdown files)

### Methodology
- **Static Analysis**: Manual code inspection of all architecture layers
- **Security Review**: OWASP Mobile Top 10 checklist
- **Architecture Review**: Layering, separation of concerns, and dependency flow
- **Performance Review**: Network patterns, marker rendering, asset footprint

---

## 3. Security Audit

### SEC-01: Credential Storage (RESOLVED ✅)
- **Status:** **Fixed**
- **Resolution:** All credentials (`username`, `password`, `displayName`) fully migrated from `SharedPreferences` to `FlutterSecureStorage` with Android `EncryptedSharedPreferences` and iOS Keychain first-unlock accessibility. An automatic migration routine (`migrateFromSharedPreferences()`) now safely purges any legacy plaintext records on startup.

### SEC-02: Dev Mode Auth Bypass in Source Code
- **Severity:** 🔴 HIGH
- **Location:** `lib/login_page.dart`
- **Finding:** Hardcoded test credentials and a quick-login bypass button exist in `login_page.dart`.
- **Recommendation:** Guard bypass behind `--dart-define=DEV_MODE=true` compile-time flag and disable for production release builds.

### SEC-03: CORS Fully Open on Express Server
- **Severity:** 🔴 HIGH
- **Location:** `server.js`
- **Finding:** `app.use(cors())` allows requests from any web origin.
- **Recommendation:** Restrict CORS to allowed mobile/internal origins.

### SEC-04: API Authentication on Node.js Endpoints
- **Severity:** 🔴 HIGH
- **Location:** `server.js`, `routes/manualEscalations.js`
- **Finding:** Node endpoints lack JWT or API key middleware.
- **Recommendation:** Add JWT bearer authentication for sensitive endpoints.

### SEC-05: Server URL in User Error Messages
- **Severity:** 🟡 MEDIUM
- **Location:** `lib/escalations/manual_escalation_service.dart`
- **Finding:** Internal server URLs are shown in toast/connection error messages.

### SEC-06: Unguarded Print Calls
- **Severity:** 🟡 MEDIUM
- **Finding:** Plaintext `print()` calls in production logs.
- **Recommendation:** Replace with `debugPrint()` guarded by `kDebugMode`.

---

## 4. Code Quality & Architecture Audit

1. **Monolith Pages**: `ai_chat_page.dart` (~2400 lines) contains chat UI, SSE client, STT/TTS, and markdown parser. Recommend splitting into modular components.
2. **State Management**: App relies on `setState` and `Timer.periodic`. Recommend adopting Riverpod or Bloc for complex state.
3. **Escalations Flat JSON**: Stored in `data/manual_escalations.json`. Recommend migrating to the existing SQL Server (TMS) database.
4. **SSL Pinning**: Well implemented using `SecurityContext` for `fmt.slt.com.lk`.

---

## 5. Performance & Asset Audit

1. **chatbot-icon.png**: Currently 1.2MB. Should be compressed to WebP (<100KB).
2. **appbarbg2.png**: 471KB. Should be optimized.
3. **Unused Assets**: Multiple design drafts (`appbarbg20-31`, `CardBGMetros1-5`) can be deleted to save ~1.2MB APK size.
4. **Map Markers**: Correctly pre-rendered to `BitmapDescriptor`.

---

## 6. Testing & CI/CD Audit

- **Critical Gap**: Only boilerplate widget test exists.
- Needs unit tests for `SecureStorageService`, `ManualEscalationQueue`, `FaultCountService`, and Node API endpoints.

---

*SLTNOC Audit Report — Antigravity AI*
