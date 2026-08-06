# Development Guide

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| **Flutter SDK** | 3.16+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| **Dart SDK** | 3.2+ | Included with Flutter |
| **Android Studio** | Latest | For Android emulator & build tools |
| **Xcode** | 15+ | For iOS simulator & build (macOS only) |
| **Git** | 2.40+ | Version control |
| **VS Code / IntelliJ** | Latest | Recommended IDEs |

### Flutter Doctor Checklist
```bash
flutter doctor
# Verify:
# ✅ Flutter (Channel stable, 3.16+)
# ✅ Android toolchain
# ✅ Xcode (macOS)
# ✅ Chrome (web debugging)
# ✅ Connected device / emulator
```

---

## Project Setup

### 1. Clone & Install
```bash
cd SLTNOC
flutter pub get
```

### 2. Verify Assets Exist
```bash
ls -la assets/
# Required:
# - Logo2.png, SLTLogo.png, NOCPORTAL.jpg, NEW.png
# - appbarbg2.png, CardBG.png, CardBGMetros.png, NoData.png
# - chatbot-icon.png, location.png, sltlogoforbg.png
# - certs/slt_ca.crt
# - fonts/Poppins-Regular.ttf
```

### 3. Run on Device/Emulator
```bash
# List devices
flutter devices

# Run debug
flutter run

# Run release profile
flutter run --release
```

---

## Build Commands

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK (single)
flutter build apk --release

# Release App Bundle (Play Store)
flutter build appbundle --release

# With custom API URL
flutter build apk --release --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://your-server:3000
```

### iOS (macOS only)
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release

# Archive for App Store (requires Xcode)
flutter build ipa --release
```

### Web (Experimental)
```bash
flutter build web --release
```

---

## Environment Configuration

### Compile-time Constants
```bash
# Manual Escalation API Base URL
flutter build apk --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://192.168.1.8:3000

# Multiple defines
flutter build apk --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://api.example.com \
                   --dart-define=OLLAMA_API_BASE_URL=http://ollama.example.com
```

### Access in Code
```dart
const String apiBaseUrl = String.fromEnvironment(
  'MANUAL_ESCALATION_API_BASE_URL',
  defaultValue: 'http://192.168.1.8:3000',
);
```

### Runtime Configuration (SharedPreferences)
| Key | Description | Default |
|-----|-------------|---------|
| `serverUrl` | Ollama/Escalation API URL | `http://192.168.1.8:3000` |
| `username` | Cached login username | — |
| `password` | Cached login password | — |
| `displayName` | User full name | — |

---

## Development Workflow

### Code Style
```bash
# Analyze (lint)
flutter analyze

# Format
dart format lib/

# Fix imports
dart fix --apply
```

### Testing
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Git Hooks (Recommended)
```bash
# .git/hooks/pre-commit
#!/bin/sh
flutter analyze
dart format --set-exit-if-changed lib/
```

---

## Project Structure Conventions

### File Naming
| Type | Convention | Example |
|------|------------|---------|
| **Widgets/Pages** | `snake_case.dart` | `login_page.dart`, `ai_chat_page.dart` |
| **Services** | `snake_case_service.dart` | `fault_count_service.dart` |
| **Models** | `snake_case.dart` | `manual_escalation.dart` |
| **Constants** | `snake_case.dart` | `app_config.dart` |

### Widget Structure
```dart
// Standard page widget
class FeaturePage extends StatelessWidget {
  final String title;
  
  const FeaturePage({Key? key, required this.title}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: title),  // TODO: Extract
      body: Container(
        decoration: backgroundDecoration,
        child: content,
      ),
    );
  }
}

// Standard stateful page
class FeaturePage extends StatefulWidget {
  final String title;
  
  const FeaturePage({Key? key, required this.title}) : super(key: key);
  
  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> {
  @override
  void initState() {
    super.initState();
    // Initialize
  }
  
  @override
  void dispose() {
    // Cleanup timers, controllers
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) { ... }
}
```

---

## Debugging

### Logging
```dart
// Use debugPrint for development (stripped in release)
debugPrint('🔍 Fetching alarms for $engineer');
debugPrint('📍 Marker update: ${markers.length} markers');

// Error logging
try {
  await riskyOperation();
} catch (e, stack) {
  debugPrint('❌ Error: $e');
  debugPrintStack(stackTrace: stack);
}
```

### Network Debugging
```dart
// Enable HTTP logging (in http.dart)
if (kDebugMode) {
  debugPrint('Request: $url');
  debugPrint('Headers: $headers');
  debugPrint('Body: $body');
  debugPrint('Response: ${response.statusCode} ${response.body}');
}
```

### Flutter DevTools
```bash
# Start DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Or from IDE: Run > Open DevTools
```

**Key DevTools Tabs:**
- **Inspector**: Widget tree, layout issues
- **Performance**: Frame rendering, rebuild profiling
- **Memory**: Heap snapshots, leak detection
- **Network**: HTTP/SSE requests
- **Logging**: Console output

---

## Common Tasks

### Add New SOAP Endpoint
```dart
// 1. Define in service/page
Future<void> fetchNewData() async {
  const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
  String soapBody = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <NewAction xmlns="http://tempuri.org/">
          <param1>value1</param1>
        </NewAction>
      </soap:Body>
    </soap:Envelope>''';

  try {
    final response = await http.post(
      Uri.parse(soapEndpoint),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://tempuri.org/NewAction',
      },
      body: soapBody,
    );
    
    if (response.statusCode == 200) {
      final xmlDoc = xml.XmlDocument.parse(response.body);
      final result = xmlDoc.findAllElements('NewActionResult').single.text;
      // Parse result...
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
}
```

### Add New REST Endpoint (Escalation/Ollama)
```dart
// In manual_escalation_service.dart pattern
Future<NewModel> fetchNewData() async {
  final response = await _get('/api/new-endpoint');
  if (response.statusCode != 200) {
    throw Exception('Failed: ${response.statusCode}');
  }
  final json = jsonDecode(response.body);
  return NewModel.fromJson(json);
}
```

### Add New Navigation Card (Dashboard)
```dart
// In home_page.dart MyCard (or extract to shared widget)
MyCard(
  title: 'NEW FEATURE',
  displayName: widget.displayName,
  subtitle: 'Description',
  newSubtitle: 'Source',
  borderColor: Color(0xFF0056A2),
  page: 'newFeature',
  onTap: () {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => NewFeaturePage(),
    ));
  },
)
```

### Add New AI Chat Tool
```dart
// In ai_chat_page.dart _showNocToolsSheet()
_nocToolCard(
  icon: Icons.new_icon,
  color: Colors.purple,
  title: 'New Tool',
  subtitle: 'Description',
  onTap: () {
    Navigator.pop(context);
    _sendMessage('Your prompt here');
  },
)
```

---

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| **SSL Handshake Failed** | Cert expired/mismatch | Update `assets/certs/slt_ca.crt` |
| **Map not loading** | API key missing | Add Google Maps API key to `AndroidManifest.xml` & `AppDelegate.swift` |
| **SOAP Timeout** | Network/FMT down | Check connectivity, increase timeout |
| **Fallback URLs exhausted** | Backend not running | Start Node.js backend, check IP |
| **TTS not speaking** | Language mismatch | Check Sinhala detection regex |
| **Chat not streaming** | SSE parsing error | Check `data:` format, `[DONE]` marker |
| **Notifications not showing** | Channel permissions | Grant notification permission in settings |

### Debug Checklist
```bash
# 1. Clean build
flutter clean
flutter pub get

# 2. Check device connection
flutter devices

# 3. Run with verbose
flutter run -v

# 4. Check logs
flutter logs

# 5. Analyze for errors
flutter analyze
```

---

## CI/CD Pipeline (Suggested)

```yaml
# .github/workflows/build.yml
name: Build & Test

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16'
      - run: flutter pub get
      - run: flutter analyze

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  build-android:
    needs: [analyze, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: app-release.apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: [analyze, test]
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

---

## Release Checklist

### Pre-Release
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Version bump in `pubspec.yaml` (`version: 1.0.1+2`)
- [ ] Update `CHANGELOG.md`
- [ ] Test on physical devices (Android + iOS)
- [ ] Verify SSL certificate validity (`openssl x509 -in assets/certs/slt_ca.crt -text -noout`)
- [ ] Generate app icons: `flutter pub run flutter_launcher_icons:main`

### Android Release
- [ ] Sign with release keystore
- [ ] `flutter build appbundle --release`
- [ ] Test bundle: `bundletool build-apks --bundle=app.aab --output=test.apks`
- [ ] Upload to Play Console

### iOS Release
- [ ] Configure signing in Xcode
- [ ] `flutter build ipa --release`
- [ ] Test via TestFlight
- [ ] Submit to App Store Connect

---

## Useful Commands Reference

```bash
# Dependencies
flutter pub get                    # Install
flutter pub upgrade                # Upgrade all
flutter pub outdated               # Check outdated
flutter pub deps                   # Dependency tree

# Build
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android AAB
flutter build ios --release        # iOS
flutter build ipa --release        # iOS IPA

# Devices
flutter devices                    # List
flutter emulators                  # List emulators
flutter emulators --launch <id>    # Launch emulator

# Debug
flutter run                        # Debug run
flutter run --release              # Profile run
flutter attach                     # Attach to running
flutter logs                       # Device logs

# Analysis
flutter analyze                    # Static analysis
dart format lib/                   # Format code
dart fix --apply                   # Auto-fix

# Testing
flutter test                       # Unit/widget tests
flutter test --coverage            # With coverage
flutter drive --target=test_driver/app.dart  # Integration

# Clean
flutter clean                      # Clean build artifacts
flutter pub cache repair           # Fix pub cache
```

---

## Performance Profiling

```bash
# Profile build
flutter run --profile

# Performance overlay
# In app: Toggle "Performance Overlay" in DevTools

# Frame timeline
# DevTools > Performance > Record

# Memory profile
# DevTools > Memory > Load snapshot

# Shader compilation (first run)
flutter run --cache-sksl
```