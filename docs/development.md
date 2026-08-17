# Development Guide

> Comprehensive setup, debugging, and contribution guide for SLT NOC Portal

---

## 🛠️ Environment Setup

### Required Tools
| Tool | Version | Install |
|------|---------|---------|
| **Flutter SDK** | 3.19+ | [flutter.dev](https://flutter.dev/docs/get-started/install) |
| **Dart SDK** | 3.3+ | Included with Flutter |
| **Android Studio** | 2023.1+ | [developer.android.com](https://developer.android.com/studio) |
| **Xcode** | 15+ (macOS only) | App Store |
| **Git** | 2.40+ | [git-scm.com](https://git-scm.com/) |
| **VS Code** (optional) | Latest | [code.visualstudio.com](https://code.visualstudio.com/) |

### Flutter Extensions (VS Code)
- `Dart` (official)
- `Flutter` (official)
- `Flutter Riverpod Snippets` (optional, for reference)
- `Error Lens` (inline errors)

### Verify Setup
```bash
flutter doctor -v
# Should show: ✓ Flutter, ✓ Android toolchain, ✓ Xcode (macOS), ✓ Chrome, ✓ Connected device
```

---

## 📥 Project Setup

### 1. Clone & Configure
```bash
git clone <repository-url>
cd SLTNOC

# Verify Flutter version
flutter --version

# Get dependencies
flutter pub get

# Generate app icons
dart run flutter_launcher_icons:main
```

### 2. Configure API Endpoints

#### Option A: Runtime Configuration (Recommended)
The app stores server URL in `SharedPreferences`. On first launch:
1. Open **Settings** page
2. Enter Ollama/Escalation API base URL (e.g., `http://192.168.1.8:3000`)
3. Save

#### Option B: Compile-time Default
```bash
# Android
flutter build apk --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://your-server:3000

# iOS
flutter build ios --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://your-server:3000

# Debug run
flutter run --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://your-server:3000
```

### 3. SSL Certificate
Ensure `assets/certs/slt_ca.crt` exists for FMT SOAP pinning:
```bash
ls -la assets/certs/
# slt_ca.crt should be present
```

### 4. Google Maps API Key
**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_ANDROID_API_KEY"/>
```

**iOS** (`ios/Runner/AppDelegate.swift`):
```swift
GMSServices.provideAPIKey("YOUR_IOS_API_KEY")
```

---

## 🏃 Running the App

### Debug Mode
```bash
# Default device
flutter run

# Specific device
flutter run -d <device_id>

# With API URL
flutter run --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://192.168.1.8:3000
```

### Release Mode
```bash
# Android APK
flutter build apk --release \
  --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://your-server:3000

# Android App Bundle (Play Store)
flutter build appbundle --release \
  --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://your-server:3000

# iOS
flutter build ios --release \
  --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://your-server:3000
```

### Device Selection
```bash
flutter devices
# Choose from listed device IDs
```

---

## 🐛 Debugging

### Logging
```dart
// Use print() or debugPrint() for console output
import 'dart:developer' as developer;

developer.log('Fault count: $_faultCount', name: 'HomePage');
developer.log('SOAP Response: $response', name: 'SOAP');
```

### Network Debugging
```bash
# View HTTP traffic (requires proxy)
flutter run --verbose

# Or use flutter_dotenv with logging interceptor
```

### Common Issues

| Issue | Solution |
|-------|----------|
| **SSL Handshake Failed (FMT)** | Verify `slt_ca.crt` in assets; check cert validity |
| **Google Map Blank** | Verify API key; enable Maps SDK in Google Cloud |
| **SOAP Timeout** | Increase timeout in `http.dart`; check network |
| **Chat Not Streaming** | Verify Ollama `/api/chat-stream` returns SSE |
| **Notifications Not Showing** | Check Android 13+ permission; iOS UNUserNotificationCenter |
| **Build Failed (Gradle)** | `flutter clean && flutter pub get && flutter build apk` |

### Debugging FMT SOAP
```dart
// In any SOAP call, add response logging:
final response = await http.post(...);
print('Status: ${response.statusCode}');
print('Body: ${response.body}');

// Parse XML for debugging:
final doc = xml.XmlDocument.parse(response.body);
print(doc.toXmlString(pretty: true));
```

### Debugging AI Chat SSE
```dart
// In _sendMessage(), add stream debugging:
await for (final bytes in response.stream) {
  final chunk = utf8.decode(bytes);
  print('SSE Chunk: $chunk');  // Add this line
  // ... existing parsing
}
```

---

## 🔧 Common Development Tasks

### Adding a New Page

#### 1. Create the File
```bash
# Example: New alarm detail page
touch lib/alarms/current_alarms/new_detail_page.dart
```

#### 2. Implement Page Template
```dart
import 'package:flutter/material.dart';
import 'package:sltnoc/app_config.dart';

class NewDetailPage extends StatefulWidget {
  final String parameter;
  
  const NewDetailPage({super.key, required this.parameter});

  @override
  State<NewDetailPage> createState() => _NewDetailPageState();
}

class _NewDetailPageState extends State<NewDetailPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // SOAP call via http.dart
      final result = await _soapCall();
      setState(() {
        _data = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _soapCall() async {
    // Use http.post from http.dart (handles SSL pinning)
    // Return parsed data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail', style: AppConfig.headlineSmall),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        actions: [SettingsButton()],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const CustomLoadingIndicator();
    if (_error != null) return _buildError(_error!);
    return _buildContent();
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $error', style: AppConfig.bodyMedium),
          ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.spacingM),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConfig.spacingM),
          child: Column(
            children: _data!.entries.map((e) => 
              _buildRow(e.key, e.value.toString())
            ).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: AppConfig.labelStyle),
          ),
          Expanded(child: Text(value, style: AppConfig.bodyMedium)),
        ],
      ),
    );
  }
}
```

#### 3. Add Navigation
```dart
// In parent page:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => NewDetailPage(parameter: 'value')),
);
```

### Adding a New SOAP Endpoint

#### 1. Define in Service/Page
```dart
Future<Map<String, dynamic>> fetchNewData(String param) async {
  const action = 'NewActionName';
  const soapAction = 'http://tempuri.org/$action';
  
  final soapBody = '''<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <$action xmlns="http://tempuri.org/">
      <paramName>$param</paramName>
    </$action>
  </soap:Body>
</soap:Envelope>''';

  final response = await http.post(
    Uri.parse('https://fmt.slt.com.lk/fmt/WClogin.asmx'),
    headers: {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction': soapAction,
    },
    body: soapBody,
  ).timeout(const Duration(seconds: 15));

  if (response.statusCode == 200) {
    final doc = xml.XmlDocument.parse(response.body);
    final result = doc.findAllElements('{$action}Result').single.text;
    return _parseResult(result);
  }
  throw Exception('HTTP ${response.statusCode}');
}
```

#### 2. Update Documentation
- Add to `docs/api.md` endpoint table
- Add request/response examples
- Update sequence diagram if new flow

### Adding a New REST Endpoint (Escalation/Ollama)

#### 1. Add to Fallback URL Chain
```dart
// In manual_escalation_service.dart or ai_chat_page.dart
const _fallbackApiBaseUrls = [
  'http://192.168.1.8:3000',
  // ... existing URLs
  'http://your-new-server:3000',  // Add here
];
```

#### 2. Implement Service Method
```dart
Future<NewModel> fetchNewEndpoint() async {
  for (final baseUrl in _fallbackApiBaseUrls) {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/new-endpoint'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        return NewModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      continue; // Try next URL
    }
  }
  throw Exception('All fallback URLs failed');
}
```

### Extending AI Chat

#### Add a New NOC Tool
```dart
// In _showNocToolsSheet(), add to tools list:
{
  'title': 'New Tool',
  'icon': Icons.new_icon,
  'prompt': 'Your prompt here',
  'color': Colors.purple,
}
```

#### Add a New Quick Reply Pattern
```dart
// In _generateQuickReplies():
if (lower.contains('your_keyword')) {
  suggestions.addAll([
    'Suggested reply 1',
    'Suggested reply 2',
  ]);
}
```

#### Add a New Action Chip Pattern
```dart
// In _buildActionChips():
if (RegExp(r'your_pattern').hasMatch(text)) {
  chips.add(_buildActionChip(
    'Chip Label',
    Icons.icon_name,
    () => _sendMessage('Your query'),
  ));
}
```

---

## 📏 Code Style & Conventions

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| **Classes** | PascalCase | `MyHomePage`, `ManualEscalationService` |
| **Methods/Variables** | camelCase | `fetchFaultCount`, `_isLoading` |
| **Constants** | UPPER_SNAKE_CASE | `DEFAULT_TIMEOUT`, `PRIMARY_COLOR` |
| **Private Members** | `_prefix` | `_client`, `_fetchData()` |
| **Files** | snake_case | `my_card.dart`, `fault_count_service.dart` |

### Import Order
```dart
// 1. Dart core
import 'dart:async';
import 'dart:convert';

// 2. Flutter packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 4. Local packages (relative)
import '../app_config.dart';
import '../http.dart';
```

### Widget Structure
```dart
class MyWidget extends StatefulWidget {
  // 1. Constructor params (final)
  final String requiredParam;
  final int? optionalParam;
  
  const MyWidget({
    super.key,
    required this.requiredParam,
    this.optionalParam,
  });

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // 2. Private state variables
  bool _isLoading = false;
  String? _error;
  
  // 3. Controllers, subscriptions
  late final TextEditingController _controller;
  
  // 4. initState
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadInitialData();
  }
  
  // 5. dispose
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // 6. Private methods
  Future<void> _loadInitialData() async { ... }
  void _handleAction() { ... }
  
  // 7. build
  @override
  Widget build(BuildContext context) { ... }
  
  // 8. Private build helpers
  Widget _buildHeader() { ... }
  Widget _buildContent() { ... }
}
```

### Error Handling Pattern
```dart
try {
  final result = await riskyOperation();
  if (!mounted) return; // Check after await
  setState(() => _data = result);
} on TimeoutException {
  if (!mounted) return;
  setState(() => _error = 'Request timed out');
} on FormatException {
  if (!mounted) return;
  setState(() => _error = 'Invalid response format');
} catch (e) {
  if (!mounted) return;
  setState(() => _error = 'Error: $e');
  developer.log('Error in _loadData: $e', name: 'MyWidget');
}
```

---

## 🧪 Testing Strategy

### Unit Tests (Planned)
```bash
# Create test file
mkdir -p test/services
touch test/services/manual_escalation_service_test.dart
```

```dart
// test/services/manual_escalation_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sltnoc/escalations/manual_escalation_service.dart';

void main() {
  group('ManualEscalationService', () {
    test('fetchActive returns list on success', () async {
      // TODO: Implement with Mockito
    });
    
    test('create throws on network error', () async {
      // TODO: Implement
    });
  });
}
```

### Widget Tests (Planned)
```dart
// test/pages/login_page_test.dart
testWidgets('Login shows error on invalid credentials', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));
  // ...
});
```

### Run Tests
```bash
flutter test
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📦 Release Checklist

### Pre-Release
- [ ] Update version in `pubspec.yaml` (`version: 1.0.0+1`)
- [ ] Update `CHANGELOG.md`
- [ ] Run `flutter analyze` - zero issues
- [ ] Run `flutter test` - all pass
- [ ] Test on physical Android device
- [ ] Test on physical iOS device (if available)
- [ ] Verify SSL certificate not expired
- [ ] Verify Google Maps API keys configured

### Build Commands
```bash
# Clean build
flutter clean
flutter pub get
dart run flutter_launcher_icons:main

# Android
flutter build apk --release \
  --dart-define=MANUAL_ESCALATION_API_BASE_URL=https://api.prod.slt.com.lk:3000

# iOS
flutter build ios --release \
  --dart-define=MANUAL_ESCALATION_API_BASE_URL=https://api.prod.slt.com.lk:3000

# Verify builds
ls -la build/app/outputs/flutter-apk/app-release.apk
ls -la build/ios/ipa/Runner.ipa
```

### Post-Release
- [ ] Tag release in git: `git tag v1.0.0`
- [ ] Push tags: `git push origin v1.0.0`
- [ ] Upload to distribution (Play Store, TestFlight, MDM)
- [ ] Update internal documentation

---

## 🔍 Performance Profiling

### Flutter DevTools
```bash
# Start DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Run app with observatory
flutter run --observatory-port=8888
```

### Key Metrics to Monitor
| Metric | Target | Tool |
|--------|--------|------|
| **Frame Render Time** | < 16ms (60fps) | DevTools Timeline |
| **Memory Usage** | < 150MB | DevTools Memory |
| **Startup Time** | < 3s | `flutter run --profile` |
| **SOAP Response** | < 5s | Network tab |
| **SSE First Token** | < 2s | DevTools Network |

### Common Optimizations
```dart
// 1. Const constructors where possible
const MyWidget();

// 2. ListView.builder for long lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)

// 3. RepaintBoundary for complex static widgets
RepaintBoundary(child: ComplexStaticWidget())

// 4. Avoid setState in loops - batch updates
setState(() {
  _items = newItems;
  _count = newItems.length;
});
```

---

## 📚 Reference Links

### Flutter/Dart
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

### Packages Used
- [http](https://pub.dev/packages/http)
- [xml](https://pub.dev/packages/xml)
- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- [speech_to_text](https://pub.dev/packages/speech_to_text)
- [flutter_tts](https://pub.dev/packages/flutter_tts)

### Internal Docs
- [`architecture.md`](architecture.md) - System design
- [`api.md`](api.md) - API reference
- [`dataflow.md`](dataflow.md) - Data flows
- [`modules.md`](modules.md) - Module structure
- [`features.md`](features.md) - Feature details

---

## 🆘 Getting Help

### Internal
- Check existing documentation in `docs/`
- Search codebase: `grep -r "pattern" lib/`
- Review git history: `git log --oneline -20`

### External
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow flutter tag](https://stackoverflow.com/questions/tagged/flutter)
- [GitHub Issues](https://github.com/flutter/flutter/issues)

---

*Last Updated: 2026-08-17*