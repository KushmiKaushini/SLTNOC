# Data Flow Documentation

## Overview

```mermaid
graph TB
    subgraph "External Systems"
        FMT[FMT SOAP API<br/>fmt.slt.com.lk]
        OLLAMA[Ollama LLM<br/>Local AI Server]
        ESC_API[Manual Escalation API<br/>Node.js/Express]
    end

    subgraph "Network Layer"
        HTTP[Custom HTTP Client<br/>http.dart]
        SOAP[XML Parser<br/>xml package]
        REST[JSON REST Client]
    end

    subgraph "Services"
        FC[FaultCountService]
        ME[ManualEscalationService]
        NS[NotificationService]
    end

    subgraph "Persistence"
        SP[SharedPreferences]
        MEM[In-Memory State]
    end

    subgraph "UI Layer"
        HOME[MyHomePage]
        ALARMS[Alarms Module]
        CLARITY[Clarity Module]
        ESCAL[Escalations Module]
        CHAT[AIChatPage]
    end

    FMT -->|SOAP/XML| HTTP
    HTTP -->|Parsed| SOAP
    SOAP --> FC
    SOAP --> ALARMS
    SOAP --> CLARITY
    
    OLLAMA -->|SSE/JSON| HTTP
    HTTP -->|Stream| REST
    REST --> CHAT
    
    ESC_API -->|REST/JSON| HTTP
    HTTP --> ME
    
    FC --> NS
    FC --> HOME
    FC --> ESCAL
    
    ME --> ESCAL
    ME --> ALARMS
    
    SP <-- Auth/Config --> HOME
    SP <-- Sessions --> CHAT
    SP <-- Server URL --> ME
    SP <-- Server URL --> CHAT
    
    MEM --> HOME
    MEM --> ALARMS
    MEM --> ESCAL
```

---

## Authentication Flow

```mermaid
sequenceDiagram
    participant User
    participant LoginPage
    participant SharedPrefs
    participant FMT_API
    participant HomePage

    User->>LoginPage: Enter credentials
    LoginPage->>FMT_API: POST login2 (SOAP)
    FMT_API-->>LoginPage: TRUE/FALSE
    alt Success
        LoginPage->>FMT_API: POST GetDisplayname (SOAP)
        FMT_API-->>LoginPage: Display Name
        LoginPage->>SharedPrefs: Save username, password, displayName
        LoginPage->>HomePage: Navigator.pushNamedAndRemoveUntil('/')
    else Failure
        LoginPage-->>User: Show "Invalid Credentials"
    end
```

### SOAP Login Request
```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <login2 xmlns="http://tempuri.org/">
      <username>6-digit-service-number</username>
      <password>user-password</password>
    </login2>
  </soap:Body>
</soap:Envelope>
```

### SOAP GetDisplayname Request
```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetDisplayname xmlns="http://tempuri.org/">
      <svcno>6-digit-service-number</svcno>
      <password>user-password</password>
    </GetDisplayname>
  </soap:Body>
</soap:Envelope>
```

---

## Home Dashboard Data Flow

```mermaid
sequenceDiagram
    participant HomePage
    participant FaultCountService
    participant FMT_API
    participant ManualEscalationService
    participant Escalation_API
    participant NotificationService

    HomePage->>HomePage: initState()
    HomePage->>FaultCountService: fetchFaultCount() [Timer: 1min]
    
    par Automatic Faults
        FaultCountService->>FMT_API: POST getSelection2 (FAULTS)
        FMT_API-->>FaultCountService: XML with fault records
        FaultCountService->>FaultCountService: Parse & count
    and Manual Faults
        FaultCountService->>ManualEscalationService: fetchActive()
        ManualEscalationService->>Escalation_API: GET /api/manual-escalations
        Escalation_API-->>ManualEscalationService: JSON array
        ManualEscalationService-->>FaultCountService: Filter FAULTS type
    end
    
    FaultCountService->>FaultCountService: total = auto + manual
    FaultCountService->>NotificationService: showFaultNotification() if changed
    FaultCountService-->>HomePage: Return total count
    HomePage->>HomePage: setState(_faultCount)
    
    par Node Down Alarms (Map)
        HomePage->>FMT_API: POST fullenglist
        FMT_API-->>HomePage: Engineer list
        HomePage->>FMT_API: POST faults3 (Node Down, 96h)
        FMT_API-->>HomePage: Fault records
        HomePage->>HomePage: Filter hours <= 96
        loop For each fault
            HomePage->>FMT_API: POST get_MSAN_Location
            FMT_API-->>HomePage: Lat/Lng + metadata
        end
        HomePage->>HomePage: Update GoogleMap markers
    end
```

---

## Alarms Module Data Flow

```mermaid
sequenceDiagram
    participant AlarmsOptionsPage
    participant FMT_API
    participant AlarmsByAlarmTypesPage
    participant NodeAlarmsPage
    participant NodeDetailsPage

    AlarmsOptionsPage->>FMT_API: POST getSelection2 (Current Alarms)
    FMT_API-->>AlarmsOptionsPage: Alarm types summary
    
    AlarmsOptionsPage->>AlarmsByAlarmTypesPage: Navigate with type
    AlarmsByAlarmTypesPage->>FMT_API: POST getSelection2 (Specific Type)
    FMT_API-->>AlarmsByAlarmTypesPage: Filtered alarms
    
    AlarmsByAlarmTypesPage->>NodeAlarmsPage: Navigate with node
    NodeAlarmsPage->>FMT_API: POST getSelection2 (Node Alarms)
    FMT_API-->>NodeAlarmsPage: Node-specific alarms
    
    NodeAlarmsPage->>NodeDetailsPage: Tap alarm
    NodeDetailsPage->>FMT_API: POST get_MSAN_details_2_new
    FMT_API-->>NodeDetailsPage: Detailed node info
```

### Alarm Data Structure (SOAP Response)
```dart
// Parsed from '::' delimited string
{
  "Docket": "ALM-2024-001",
  "Status": "OPEN",
  "Description": "Node Down - MSAN Colombo",
  "Duration": "4 hours",
  // Additional fields from get_MSAN_Location:
  "Latitude": "6.9271",
  "Longitude": "79.8612",
  "Platform": "MSAN",
  "Region": "Western",
  "Site": "Colombo Central",
  "Vendor": "Huawei",
  "Contact1": "Eng. Perera",
  "Contact2": "Eng. Silva",
  // From get_MSAN_details_2_new:
  "Engineer": "A.Gunalathas",
  "AGG": "AGG-COL-01",
  "ODF": "ODF-12",
  "CSCID": "CSC-WEST-001"
}
```

---

## Clarity Module Data Flow

```mermaid
sequenceDiagram
    participant ClarityPage
    participant WorkGroupsPage
    participant CenCscPage
    participant FMT_API

    ClarityPage->>WorkGroupsPage: Navigate
    WorkGroupsPage->>FMT_API: POST getSelection2 (Work Groups)
    FMT_API-->>WorkGroupsPage: Work group list
    
    WorkGroupsPage->>WorkGroups2Page: Tap group
    WorkGroups2Page->>FMT_API: POST getSelection2 (Group Details)
    FMT_API-->>WorkGroups2Page: Fault dockets for group
    
    ClarityPage->>CenCscPage: Navigate (NW/DATA/CC/MS)
    CenCscPage->>FMT_API: POST getSelection2 (CEN-CSC-{type})
    FMT_API-->>CenCscPage: Clarity fault dockets
    
    ClarityPage->>ServiceOrderDetailsPage: Navigate
    ServiceOrderDetailsPage->>FMT_API: POST get_CCT_Details
    FMT_API-->>ServiceOrderDetailsPage: Circuit details
```

---

## Escalations Module Data Flow

```mermaid
sequenceDiagram
    participant EscalationsPage
    participant FaultsPage
    participant ManualEscalationService
    participant Escalation_API
    participant FaultCountService

    EscalationsPage->>FaultCountService: fetchFaultCount() [Timer: 30s]
    FaultCountService->>Escalation_API: GET /api/manual-escalations/summary
    Escalation_API-->>FaultCountService: {hasActive: true}
    FaultCountService-->>EscalationsPage: badge count
    
    EscalationsPage->>FaultsPage: Navigate
    FaultsPage->>Escalation_API: GET /api/manual-escalations
    Escalation_API-->>FaultsPage: All manual escalations
    FaultsPage->>FaultsPage: Filter type == FAULTS
    FaultsPage->>FaultsPage: Merge with SOAP faults (prepend manual)
    
    EscalationsPage->>ManualEscalationFormPage: FAB Tap
    ManualEscalationFormPage->>ManualEscalationFormPage: Form validation
    ManualEscalationFormPage->>ManualEscalationService: create(escalation)
    ManualEscalationService->>Escalation_API: POST /api/manual-escalations
    Escalation_API-->>ManualEscalationService: 201 Created
    ManualEscalationService-->>ManualEscalationFormPage: Success
    ManualEscalationFormPage->>EscalationsPage: Pop with refresh
    EscalationsPage->>FaultCountService: fetchFaultCount() [immediate]
```

### Manual Escalation Data Model
```dart
class ManualEscalation {
  final String id;                    // MongoDB ObjectId
  final String escalationType;        // FAULTS | PLANNED EVENTS | PROBLEMS | COMMON ISSUES
  final String node;                  // Node identifier
  final String platform;              // MSAN | CEA | GPON | RPB | OTHER
  final String severity;              // CRITICAL | MAJOR | MINOR | POWER | SECURITY
  final String tag;                   // Optional tag
  final String description;           // Detailed description
  final DateTime startAt;             // ISO 8601
  final String reportingBy;           // Reporter name
  final String responsibleOfficer;    // Assigned engineer
  final String status;                // OPEN | IN_PROGRESS | RESOLVED | CLOSED
  
  int get durationHours => DateTime.now().difference(startAt).inHours;
}
```

---

## AI Chat Data Flow

```mermaid
sequenceDiagram
    participant User
    participant AIChatPage
    participant SharedPrefs
    participant Ollama_API
    participant NotificationService

    User->>AIChatPage: Open chat
    AIChatPage->>SharedPrefs: Load sessions, serverUrl
    AIChatPage->>Ollama_API: GET /api/critical-alerts
    Ollama_API-->>AIChatPage: Critical alert banner data
    
    User->>AIChatPage: Type message / Voice input
    AIChatPage->>AIChatPage: Add user message to session
    AIChatPage->>Ollama_API: POST /api/chat-stream (SSE)
    Note over AIChatPage,Ollama_API: conversationHistory + current message
    
    loop Streaming Response
        Ollama_API-->>AIChatPage: data: {"token": "partial"}
        AIChatPage->>AIChatPage: Append to streaming message
        AIChatPage->>AIChatPage: setState + scrollToBottom
    end
    
    Ollama_API-->>AIChatPage: data: [DONE]
    AIChatPage->>AIChatPage: Finalize message, generate quick replies
    AIChatPage->>SharedPrefs: Save sessions
    
    alt Error
        AIChatPage->>AIChatPage: Show error with retry button
        User->>AIChatPage: Tap Retry
        AIChatPage->>Ollama_API: Resend with same payload
    end
```

### Chat Streaming Protocol (SSE)
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

Response (Server-Sent Events):
data: {"token": "There"}
data: {"token": " are"}
data: {"token": " 23"}
data: {"token": " active"}
data: {"token": " alarms"}
data: {"token": " in"}
data: {"token": " Western"}
data: {"token": " province"}
data: [DONE]
```

---

## Background Services Data Flow

```mermaid
graph TB
    subgraph "Timer: 1 minute (HomePage)"
        T1[Timer.periodic] --> FC1[FaultCountService.fetchFaultCount]
        FC1 --> SP1[SharedPrefs: serverUrl]
        FC1 --> API1[FMT SOAP + Escalation REST]
        API1 --> FC1
        FC1 --> NS1[NotificationService.showFaultNotification]
        FC1 --> HP[HomePage.setState]
    end

    subgraph "Timer: 30 seconds (EscalationsPage)"
        T2[Timer.periodic] --> FC2[FaultCountService.fetchFaultCount]
        FC2 --> ES[EscalationsPage.setState]
    end

    subgraph "Timer: On Demand (AIChatPage)"
        T3[User Action] --> CA[fetchCriticalAlerts]
        CA --> OA[Ollama API: /api/critical-alerts]
        OA --> CA
        CA --> HP2[AIChatPage.setState]
    end
```

---

## Offline / Fallback Behavior

| Service | Offline Strategy |
|---------|------------------|
| **FMT SOAP** | Request timeout (15s); shows error in UI; map shows last cached markers |
| **Escalation API** | Falls through `_fallbackApiBaseUrls` (8 URLs); tries each with 5s timeout |
| **Ollama AI** | Falls through `_kChatFallbackUrls` (8 URLs); tries each with 5s timeout for both `/api/chat-stream` and `/api/critical-alerts` |
| **Notifications** | Local only; no server dependency |
| **Auth** | Cached credentials in SharedPreferences allow offline login |

### Fallback URL Chain (Manual Escalation)
```dart
const _fallbackApiBaseUrls = [
  'http://192.168.1.8:3000',      // Primary (saved in prefs)
  'http://172.20.10.6:3000',      // Hotspot fallback
  'http://192.168.1.7:3000',      // Alt WiFi
  'http://10.16.188.228:3000',    // Corporate
  'http://192.168.1.10:3000',     // Alt local
  manualEscalationApiBaseUrl,      // Compile-time --dart-define
  'http://10.0.2.2:3000',         // Android emulator
  'http://127.0.0.1:3000',        // iOS simulator / localhost
];
```

### Fallback URL Chain (AI Chat)
```dart
// In lib/ai_chat_page.dart
const _kChatFallbackUrls = [
  'http://192.168.1.8:3000',      // Primary (from SharedPreferences)
  'http://172.20.10.6:3000',      // Mobile hotspot
  'http://192.168.1.7:3000',      // Alternate WiFi
  'http://10.16.188.228:3000',    // Corporate network
  'http://192.168.1.10:3000',     // Backup local
  'http://10.0.2.2:3000',         // Android emulator
  'http://127.0.0.1:3000',        // iOS Simulator / localhost
];
const _kConnectionAttemptTimeout = Duration(seconds: 5);
```

---

## Data Persistence Schema

### SharedPreferences Keys
| Key | Type | Description |
|-----|------|-------------|
| `username` | String | 6-digit SLT service number |
| `password` | String | User password (plaintext - TODO: encrypt) |
| `displayName` | String | Full name from GetDisplayname |
| `serverUrl` | String | Ollama/Escalation API base URL |
| `chat_sessions` | String (JSON) | Array of ChatSession objects |
| `active_session_id` | String | Currently active chat session ID |

### ChatSession JSON Structure
```json
{
  "id": "1704067200000",
  "name": "Chat 1",
  "messages": [
    {
      "id": "1704067201000",
      "text": "Show active alarms",
      "isUser": true,
      "timestamp": "2024-01-01T10:00:01.000Z",
      "status": "sent"
    },
    {
      "id": "1704067202000",
      "text": "There are 23 active alarms...",
      "isUser": false,
      "timestamp": "2024-01-01T10:00:02.000Z",
      "status": "sent"
    }
  ],
  "lastUpdated": "2024-01-01T10:00:02.000Z"
}
```

---

## Error Handling Flow

```mermaid
flowchart TD
    A[Network Request] --> B{Success?}
    B -->|200 OK| C[Parse Response]
    C --> D{Parse Valid?}
    D -->|Yes| E[Update State / Return Data]
    D -->|No| F[Log Parse Error]
    F --> G[Show User Error]
    
    B -->|Timeout| H[Log Timeout]
    H --> I[Try Fallback URL?]
    I -->|Yes| J[Next URL in Chain]
    J --> A
    I -->|No| K[Show Connection Error]
    
    B -->|Non-200| L[Log HTTP Error]
    L --> M[Show User Error]
    
    B -->|Exception| N[Catch Exception]
    N --> O[Log Exception]
    O --> P[Show User Error + Retry]
    
    G --> Q[Return Empty/Default]
    K --> Q
    M --> Q
    P --> Q
```