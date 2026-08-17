# Architecture Overview

## System Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        A[LoginPage] --> B[MyHomePage]
        B --> C[AlarmsPage]
        B --> D[ClarityPage]
        B --> E[EscalationsPage]
        B --> F[PlanOutagesPage]
        B --> G[AIChatPage]
        B --> H[SettingsPage]
    end

    subgraph "Feature Modules"
        C --> C1[Current Alarms]
        C --> C2[Element Locations]
        C --> C3[Update Element Location]
        C --> C4[Elements Map]
        
        D --> D1[Clarity NW Faults]
        D --> D2[CEN-CSC Variants]
        D --> D3[Work Groups]
        D --> D4[Service Order Details]
        
        E --> E1[Faults]
        E --> E2[Planned Events]
        E --> E3[Problems]
        E --> E4[Common Issues]
        E --> E5[Manual Escalation Form]
        
        G --> G1[Chat Sessions]
        G --> G2[Streaming Responses]
        G --> G3[Speech I/O]
        G --> G4[NOC Tools]
    end

    subgraph "Core Services"
        S1[NotificationService]
        S2[FaultCountService]
        S3[ManualEscalationService]
        S4[HTTP Client<br/>(Custom + SSL Pinning)]
    end

    subgraph "Data Layer"
        DL1[SharedPreferences<br/>Auth + Sessions]
        DL2[SOAP API<br/>FMT Backend]
        DL3[REST API<br/>Ollama + Escalation]
    end

    S1 --> DL1
    S2 --> DL2
    S2 --> S3
    S3 --> DL3
    S4 --> DL2
    S4 --> DL3
    B --> S1
    B --> S2
    E --> S3
    G --> S4
```

---

## Design Patterns

### 1. **Repository Pattern** (Services)
```mermaid
classDiagram
    class ManualEscalationService {
        +fetchActive() Future<List>
        +create(escalation) Future<void>
        +delete(id) Future<void>
        +hasActive() Future<bool>
        -_uris(path) Future<List<Uri>>
        -_get(path) Future<Response>
        -_post(path, headers, body) Future<Response>
        -_delete(path) Future<Response>
    }

    class FaultCountService {
        +fetchFaultCount() Future<int>
        -_fetchAutomaticFaultCount() Future<int>
        -_fetchManualFaultCount() Future<int>
    }

    class NotificationService {
        +initialize() Future<void>
        +showFaultNotification(count, silent) Future<void>
        +cancelNotification() Future<void>
    }
```

### 2. **Provider-less State Management**
- **Local State**: `setState` in `StatefulWidget` for UI-bound state
- **Persistence**: `SharedPreferences` for auth tokens, chat sessions, server URL
- **Background**: `Timer.periodic` for polling (fault counts, AI alerts)
- **Cross-widget**: `GlobalKey<NavigatorState>` + `RouteObserver` for overlay (chat button)

### 3. **Factory Pattern** (HTTP Client)
```mermaid
classDiagram
    class HTTPClient {
        <<interface>>
        +get(url, headers) Future<Response>
        +post(url, headers, body) Future<Response>
    }

    class DefaultClient {
        +get()
        +post()
    }

    class TrustedClient {
        -SecurityContext context
        +get()
        +post()
    }

    HTTPClient <|-- DefaultClient
    HTTPClient <|-- TrustedClient

    class ClientFactory {
        +_clientFor(url) Future<Client>
        +get()
        +post()
    }
    ClientFactory --> HTTPClient
```

---

## Security Architecture

### SSL Certificate Pinning
```mermaid
sequenceDiagram
    participant App
    participant HTTPClient
    participant TrustedCA
    participant FMT_API
    participant Ollama_API

    App->>HTTPClient: post(Uri, headers, body)
    HTTPClient->>HTTPClient: _clientFor(url)
    alt url.host == fmt.slt.com.lk
        HTTPClient->>TrustedCA: Load slt_ca.crt from assets
        TrustedCA-->>HTTPClient: SecurityContext
        HTTPClient->>FMT_API: IOClient with pinned cert
    else
        HTTPClient->>Ollama_API: Standard http.Client
    end
    HTTPClient-->>App: Response
```

### SSL Certificate Pinning Details
- **Asset**: `assets/certs/slt_ca.crt`
- **Host**: `fmt.slt.com.lk`
- **Implementation**: Custom `SecurityContext` with trusted cert bytes
- **Fallback**: Standard client if cert load fails (debug only)

---

## Dependency Graph

```mermaid
graph LR
    subgraph "Core"
        Flutter[flutter sdk]
        Cupertino[cupertino_icons]
    end

    subgraph "Network"
        HTTP[http ^0.13.3]
        XML[xml ^6.5.0]
        IO[io_client]
    end

    subgraph "Maps & Location"
        GMaps[google_maps_flutter ^2.2.4]
        Perm[permission_handler ^11.3.1]
        Loc[location ^5.0.3]
        Conn[connectivity_plus ^5.0.2]
    end

    subgraph "Storage & Notifications"
        SP[shared_preferences ^2.0.8]
        Notif[flutter_local_notifications ^18.0.1]
        Badge[flutter_app_badger ^1.5.0]
    end

    subgraph "AI & Voice"
        STT[speech_to_text ^7.0.0]
        TTS[flutter_tts ^3.8.5]
    end

    subgraph "UI Helpers"
        Toast[fluttertoast ^8.0.7]
        Scroll[scrollable_positioned_list ^0.3.8]
        CustInfo[custom_info_window ^1.0.1]
    end

    Flutter --> HTTP
    Flutter --> XML
    Flutter --> GMaps
    Flutter --> Perm
    Flutter --> Loc
    Flutter --> SP
    Flutter --> Notif
    Flutter --> STT
    Flutter --> TTS
    Flutter --> Toast
    Flutter --> Conn
    HTTP --> IO
```

---

## Build Configuration

### App Icons & Assets
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/NOCPORTAL.jpg"
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "assets/NEW.png"
  min_sdk_android: 21
```

### Environment Variables
```bash
# Manual Escalation API Base URL (compile-time)
flutter build apk --dart-define=MANUAL_ESCALATION_API_BASE_URL=http://your-server:3000
```

---

## Performance Considerations

| Area | Strategy |
|------|----------|
| **Map Markers** | Pre-rendered `BitmapDescriptor` from `PictureRecorder` (custom icons) |
| **SOAP Parsing** | Streaming XML parse with `xml` package; batch location requests |
| **Chat Streaming** | SSE parsing with `http.Client.send()` + `Stream` subscription |
| **Image Assets** | WebP/PNG optimized; background images use `BoxFit.cover` |
| **List Rendering** | `SingleChildScrollView` + `DataTable` for tabular data |
| **Background Polling** | 1-min (home) / 30-sec (escalations) with `Timer.periodic` |