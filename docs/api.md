# API Integration

## Overview

The app integrates with **three distinct backend systems**:

| System | Protocol | Host | Purpose |
|--------|----------|------|---------|
| **FMT SOAP API** | SOAP 1.1 / XML | `fmt.slt.com.lk` | Alarms, Clarity, Node data, Engineer list |
| **Ollama LLM API** | REST / SSE | Configurable (default `192.168.1.8:3000`) | AI Chat, Critical Alerts |
| **Manual Escalation API** | REST / JSON | Configurable (same as Ollama) | CRUD for manual escalations |

---

## FMT SOAP API (fmt.slt.com.lk)

### Base Configuration
```dart
const String soapEndpoint = 'https://fmt.slt.com.lk/fmt/WClogin.asmx';
const String soapNamespace = 'http://tempuri.org/';
const Duration requestTimeout = Duration(seconds: 15);
```

### SSL Certificate Pinning
- **Certificate**: `assets/certs/slt_ca.crt` (loaded from assets)
- **Implementation**: Custom `SecurityContext` in `http.dart`
- **Host**: `fmt.slt.com.lk` only

### Common SOAP Envelope Structure
```xml
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
    xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <!-- Action-specific content -->
  </soap:Body>
</soap:Envelope>
```

### Headers
```dart
headers: {
  'Content-Type': 'text/xml; charset=utf-8',
  'SOAPAction': 'http://tempuri.org/{ActionName}',
}
```

---

### Endpoints Reference

#### 1. **Authentication**

| Action | Method | SOAPAction | Parameters | Response |
|--------|--------|------------|------------|----------|
| `login2` | POST | `http://tempuri.org/login2` | `username`, `password` | `TRUE` / `FALSE` |
| `GetDisplayname` | POST | `http://tempuri.org/GetDisplayname` | `svcno`, `password` | Display name string |

**Login Request:**
```xml
<soap:Body>
  <login2 xmlns="http://tempuri.org/">
    <username>123456</username>
    <password>mypassword</password>
  </login2>
</soap:Body>
```

**GetDisplayname Request:**
```xml
<soap:Body>
  <GetDisplayname xmlns="http://tempuri.org/">
    <svcno>123456</svcno>
    <password>mypassword</password>
  </GetDisplayname>
</soap:Body>
```

---

#### 2. **Engineer & Alarm Queries**

| Action | Method | SOAPAction | Parameters | Response Format |
|--------|--------|------------|------------|-----------------|
| `fullenglist` | POST | `http://tempuri.org/fullenglist` | — | `Name1::Data,Name2::Data,...` |
| `faults3` | POST | `http://tempuri.org/faults3` | `nweng`, `alarm_type` | `Docket::Status::Duration::Desc,...` |
| `getSelection2` | POST | `http://tempuri.org/getSelection2` | `selection`, `serviceno` | `Docket::Status::Duration::Desc,...` |

**faults3 Request:**
```xml
<soap:Body>
  <faults3 xmlns="http://tempuri.org/">
    <nweng>EngineerName</nweng>
    <alarm_type>Node Down</alarm_type>
  </faults3>
</soap:Body>
```

**getSelection2 Request:**
```xml
<soap:Body>
  <getSelection2 xmlns="http://tempuri.org/">
    <selection>FAULTS</selection>
    <serviceno></serviceno>
  </getSelection2>
</soap:Body>
```

*Selection values:* `FAULTS`, `PLANNED EVENTS`, `PROBLEMS`, `COMMON ISSUES`, `CEN-CSC-NW`, `CEN-CSC-DATA`, `CEN-CSC-CC`, `CEN-CSC-MS`, `Work Groups`, `CLARITY NW FAULTS`

---

#### 3. **Location & Node Details**

| Action | Method | SOAPAction | Parameters | Response |
|--------|--------|------------|------------|----------|
| `get_MSAN_Location` | POST | `http://tempuri.org/get_MSAN_Location` | `node` | `Lat::Lng::Platform::Region::Site::Vendor::Contacts...` |
| `get_MSAN_details_2_new` | POST | `http://tempuri.org/get_MSAN_details_2_new` | `msan` | 23-field `::` delimited string |
| `get_CCT_Details` | POST | `http://tempuri.org/get_CCT_Details` | `cct` | Circuit details |

**get_MSAN_Location Request:**
```xml
<soap:Body>
  <get_MSAN_Location xmlns="http://tempuri.org/">
    <node>COLO_MSAN_001</node>
  </get_MSAN_Location>
</soap:Body>
```

**Response Parsing (get_MSAN_Location):**
```dart
// Expected 7+ parts: Node::Status::Duration::Desc::Platform::Lat::Lng::Region::Site::Vendor::Contacts...
final parts = response.split('::');
final lat = double.tryParse(parts[5]);
final lng = double.tryParse(parts[6]);
final platform = parts[4]; // MSAN, CEA, RPB, OTHER
```

**Response Parsing (get_MSAN_details_2_new):**
```dart
// 23 fields (0-22)
final fields = result.split('::');
{
  'eleName': fields[0],        // Element name
  'nwEngName': fields[3],      // Network engineer
  'site': fields[5],           // Site name
  'vendor': fields[18],        // Vendor (Huawei, ZTE, etc.)
  'contacts': fields[6..17],   // 6 contact pairs (name/number)
  'issues': fields[19],        // Issues description
  'CSCID': fields[20],         // CSC ID
  'AGG': fields[21],           // Aggregation node
  'ODF': fields[22],           // ODF info
}
```

---

#### 4. **Element Location Updates**

| Action | Method | SOAPAction | Parameters |
|--------|--------|------------|------------|
| `update_MSAN_Location` | POST | `http://tempuri.org/update_MSAN_Location` | `node`, `lat`, `lng`, `updatedBy` |

---

### Error Handling (SOAP)
```dart
try {
  final response = await http.post(uri, headers: headers, body: soapBody)
      .timeout(const Duration(seconds: 15));
  
  if (response.statusCode == 200) {
    final xmlDoc = xml.XmlDocument.parse(response.body);
    final result = xmlDoc.findAllElements('{ActionName}Result').single.text;
    // Parse result...
  } else {
    print('HTTP ${response.statusCode}: ${response.body}');
  }
} catch (e) {
  print('SOAP Error: $e');
  // Handle timeout, parse error, network error
}
```

---

## Ollama LLM API (AI Chat)

### Base URL
- **Configurable**: Stored in `SharedPreferences` as `serverUrl`
- **Default**: `http://192.168.1.8:3000`
- **Fallback Chain**: 8 URLs tried sequentially (see `manual_escalation_service.dart`)

### Endpoints

#### 1. **Chat Streaming** (`POST /api/chat-stream`)

**Request:**
```http
POST /api/chat-stream
Content-Type: application/json

{
  "message": "Show active alarms in Western province",
  "conversationHistory": [
    {"role": "user", "content": "What alarms are active?"},
    {"role": "assistant", "content": "There are 23 active alarms..."}
  ]
}
```

**Response (Server-Sent Events):**
```http
HTTP/1.1 200 OK
Content-Type: text/event-stream
Cache-Control: no-cache
Connection: keep-alive

data: {"token": "There"}
data: {"token": " are"}
data: {"token": " 23"}
data: {"token": " active"}
data: {"token": " alarms"}
data: {"token": " in"}
data: {"token": " Western"}
data: {"token": " province"}
data: {"token": "."}
data: [DONE]
```

**Client Implementation:**
```dart
final request = http.Request('POST', Uri.parse('$serverUrl/api/chat-stream'))
  ..headers['Content-Type'] = 'application/json'
  ..body = jsonEncode({'message': text, 'conversationHistory': history});

final response = await client.send(request);
await for (final bytes in response.stream) {
  final chunk = utf8.decode(bytes);
  for (final line in chunk.split('\n')) {
    if (line.trim().startsWith('data: ')) {
      final data = line.trim().substring(6);
      if (data == '[DONE]') break;
      final json = jsonDecode(data);
      if (json.containsKey('token')) {
        buffer.write(json['token']);
        // Update UI with buffer.toString()
      }
    }
  }
}
```

---

#### 2. **Critical Alerts** (`GET /api/critical-alerts`)

**Request:**
```http
GET /api/critical-alerts
```

**Response:**
```json
{
  "success": true,
  "alert": {
    "hasCriticalAlert": true,
    "totalOpenAlarms": 47,
    "topProvince": "Western",
    "topProvinceCount": 18,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

---

## Manual Escalation API

### Base URL
Same as Ollama (configurable `serverUrl`)

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/manual-escalations` | List all active escalations |
| GET | `/api/manual-escalations/summary` | Check if any active (`{hasActive: true}`) |
| POST | `/api/manual-escalations` | Create new escalation |
| DELETE | `/api/manual-escalations/{id}` | Delete escalation |

---

### Data Models

**ManualEscalation (Request/Response):**
```json
{
  "id": "507f1f77bcf86cd799439011",
  "escalationType": "FAULTS",
  "node": "COLO_MSAN_001",
  "platform": "MSAN",
  "severity": "MAJOR",
  "tag": "POWER",
  "description": "Node down due to power failure at site",
  "startAt": "2024-01-15T08:00:00.000Z",
  "reportingBy": "NOC Engineer",
  "responsibleOfficer": "Eng. Perera",
  "status": "OPEN"
}
```

**Create Request:** (excludes `id`, `status`)
```json
{
  "escalationType": "FAULTS",
  "node": "COLO_MSAN_001",
  "platform": "MSAN",
  "severity": "MAJOR",
  "tag": "POWER",
  "description": "Node down due to power failure at site",
  "startAt": "2024-01-15T08:00:00.000Z",
  "reportingBy": "NOC Engineer",
  "responsibleOfficer": "Eng. Perera"
}
```

**Response Codes:**
| Code | Meaning |
|------|---------|
| 200 | Success (GET) |
| 201 | Created (POST) |
| 400 | Validation Error |
| 404 | Not Found |
| 500 | Server Error |

---

### Fallback URL Strategy

```dart
const _fallbackApiBaseUrls = [
  'http://192.168.1.8:3000',      // Primary (from SharedPreferences)
  'http://172.20.10.6:3000',      // Mobile hotspot
  'http://192.168.1.7:3000',      // Alternate WiFi
  'http://10.16.188.228:3000',    // Corporate network
  'http://192.168.1.10:3000',     // Backup local
  manualEscalationApiBaseUrl,      // Compile-time --dart-define
  'http://10.0.2.2:3000',         // Android emulator
  'http://127.0.0.1:3000',        // iOS Simulator / localhost
];

// Each tried with 5-second timeout
const _connectionAttemptTimeout = Duration(seconds: 5);
```

---

## Network Layer Architecture

```mermaid
classDiagram
    class HttpClient {
        <<interface>>
        +get(Uri, headers) Future<Response>
        +post(Uri, headers, body) Future<Response>
        +delete(Uri) Future<Response>
    }

    class DefaultHttpClient {
        -http.Client _client
        +get()
        +post()
    }

    class PinnedHttpClient {
        -IOClient _ioClient
        -SecurityContext _context
        +get()
        +post()
    }

    class HttpFactory {
        +_getDefaultClient() Client
        +_getTrustedClient() Future<Client>
        +_clientFor(Uri) Future<Client>
        +get(Uri, headers)
        +post(Uri, headers, body)
    }

    HttpFactory --> HttpClient
    HttpClient <|-- DefaultHttpClient
    HttpClient <|-- PinnedHttpClient
```

### http.dart Implementation
```dart
// Exports http package + custom get/post with timeout & pinning
export 'package:http/http.dart';

const String _trustedHost = 'fmt.slt.com.lk';
const String _trustedCaAssetPath = 'assets/certs/slt_ca.crt';
const Duration _requestTimeout = Duration(seconds: 15);

Future<http.Client> _getTrustedClient() async {
  if (_trustedClient != null) return _trustedClient!;
  
  final ByteData data = await rootBundle.load(_trustedCaAssetPath);
  final SecurityContext context = SecurityContext(withTrustedRoots: true);
  context.setTrustedCertificatesBytes(data.buffer.asUint8List());
  
  final HttpClient ioClient = HttpClient(context: context);
  _trustedClient = IOClient(ioClient);
  return _trustedClient!;
}

Future<http.Client> _clientFor(Uri url) async {
  if (url.host == _trustedHost) return _getTrustedClient();
  return _getDefaultClient();
}

Future<http.Response> post(Uri url, {headers, body, encoding}) async {
  final client = await _clientFor(url);
  return client.post(url, headers: headers, body: body, encoding: encoding)
      .timeout(_requestTimeout);
}
```

---

## API Versioning & Compatibility

| API | Version | Breaking Changes | Notes |
|-----|---------|------------------|-------|
| FMT SOAP | v1 (legacy) | None expected | Stable enterprise endpoint |
| Ollama | v1 | Possible | Local deployment, version controlled |
| Escalation | v1 | Possible | Internal Node.js service |

### Future-Proofing Recommendations
1. **API Version Header**: Add `Accept-Version: 1` to requests
2. **Response Envelope**: Standardize `{success: bool, data: T, error?: string}`
3. **Rate Limiting**: Implement exponential backoff
4. **Caching**: Add ETag/Last-Modified for GET endpoints