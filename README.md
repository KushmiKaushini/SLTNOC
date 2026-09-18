# 🌐 SLT NOC Mobile Portal

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green.svg)]()
[![Security](https://img.shields.io/badge/Security-Encrypted%20Storage%20%26%20SSL%20Pinning-brightgreen.svg)]()

> **Sri Lanka Telecom — Network Operations Center Mobile Application**  
> Enterprise-grade operations portal for real-time telecom alarms monitoring, Clarity OSS fault tracking, planned outage coordination, manual escalations, and AI-powered operational assistance.

---

## 📋 Features

- 🚨 **Real-Time Alarms Monitoring**: Live regional fault surveillance, categorization by metro region, alarm details inspection, and interactive GPS map element plotting.
- 🛠️ **Clarity OSS Integration**: Work group ticket tracking, CEN/CSC customer circuit diagnostics, service order lookups, and network fault status.
- ⚡ **Escalations & Outages**: Multi-tier escalation management (FAULTS, PROBLEMS, PLANNED EVENTS, COMMON ISSUES) with offline-capable queuing and automatic synchronization.
- 🤖 **AI NOC Assistant**: Streaming LLM assistant with live token generation, voice recognition, NOC diagnostics tools, and interactive quick action chips.
- 🔐 **Enterprise Security**: Hardware-backed encrypted credential storage (`EncryptedSharedPreferences` & iOS Keychain), SSL pinning for critical SOAP endpoints, and role-based API protection.

---

## 🏗️ Architecture Overview

```mermaid
graph TB
    subgraph "Mobile Client (Flutter)"
        UI[Presentation Layer<br/>Alarms | Clarity | Escalations | AI Chat]
        SEC[SecureStorageService<br/>AES-256 / Keychain]
        Q[ManualEscalationQueue<br/>Offline Resiliency]
        NET[HTTP Factory<br/>SSL Pinning & Auth Interceptor]
    end

    subgraph "Backend Infrastructure"
        SOAP[FMT SOAP Gateway<br/>fmt.slt.com.lk]
        NODE[Node.js API Server<br/>Express & JWT / API Key]
        DB[(SQL Server - TMS DB)]
        LLM[Ollama / Azure AI]
    end

    UI --> SEC
    UI --> Q
    UI --> NET
    NET -->|mTLS / Pinning| SOAP
    NET -->|Bearer / API Key| NODE
    NODE --> DB
    NODE --> LLM
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: 3.x or later
- **Dart SDK**: 3.x
- **Android Studio** (Android 21+) / **Xcode** (iOS 12+)
- **Node.js** 18+ (for local backend services)

### Installation & Run

1. **Clone the repository and install dependencies:**
   ```bash
   git clone https://github.com/KaushiniEkanayake/SLTNOC.git
   cd SLTNOC
   flutter pub get
   ```

2. **Run Tests:**
   ```bash
   flutter test
   ```

3. **Run with Environment Variables:**
   ```bash
   flutter run --dart-define=API_BASE_URL=http://192.168.1.8:3000 --dart-define=DEV_MODE=true
   ```

4. **Build Release APK:**
   ```bash
   flutter build apk --release --dart-define=API_BASE_URL=https://noc-api.slt.lk
   ```

---

## 🧪 Testing

The codebase includes automated unit and widget test suites covering security, data serialization, offline queue resiliency, and UI components.

```bash
# Run all tests
flutter test

# Run static analysis
flutter analyze
```

---

## 📚 Documentation

For full architectural blueprints, data flow diagrams, security remediation logs, and API specifications, consult the [`docs/`](docs/) directory:

- 📖 [Documentation Index](docs/README.md)
- 🏛️ [System Architecture](docs/architecture.md)
- 🔄 [Data Flow & Lifecycles](docs/dataflow.md)
- 🔌 [API & Integration Guide](docs/api.md)
- ⚙️ [Environment Variables Guide](docs/environment_variables.md)
- 🛡️ [Security Audit Report](docs/audit_report.md)
- ✅ [Fixing Plan & Progress](docs/fixing_plan.md)

---

## 🔒 Security & Confidentiality

This software is confidential and proprietary to **Sri Lanka Telecom PLC (SLT)**. Unauthorized copying, reverse engineering, or distribution is strictly prohibited.
