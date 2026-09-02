import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:sltnoc/secure_storage_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'shared_state.dart';

const List<String> _kChatFallbackUrls = [
  'http://192.168.1.8:3000', // Primary (from SharedPreferences)
  'http://172.20.10.6:3000', // Mobile hotspot
  'http://192.168.1.7:3000', // Alternate WiFi
  'http://10.16.188.228:3000', // Corporate network
  'http://192.168.1.10:3000', // Backup local
  'http://10.0.2.2:3000', // Android emulator
  'http://127.0.0.1:3000', // iOS Simulator / localhost
];
const Duration _kConnectionAttemptTimeout = Duration(seconds: 5);

// ─────────────────────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────────────────────

enum MessageStatus { sent, error, retrying }

class ChatMessage {
  final String id;
  String text;
  final bool isUser;
  final DateTime timestamp;
  MessageStatus status;
  String? retryPayload; // original user message that caused this error

  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.retryPayload,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        text: j['text'] as String,
        isUser: j['isUser'] as bool,
        timestamp: DateTime.parse(j['timestamp'] as String),
        status: MessageStatus.values.firstWhere(
          (e) => e.name == (j['status'] ?? 'sent'),
          orElse: () => MessageStatus.sent,
        ),
      );
}

class ChatSession {
  final String id;
  String name;
  List<ChatMessage> messages;
  DateTime lastUpdated;

  ChatSession({
    String? id,
    required this.name,
    List<ChatMessage>? messages,
    DateTime? lastUpdated,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        messages = messages ?? [],
        lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'messages': messages.map((m) => m.toJson()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> j) => ChatSession(
        id: j['id'] as String,
        name: j['name'] as String,
        messages: (j['messages'] as List)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        lastUpdated: DateTime.parse(j['lastUpdated'] as String),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Design constants
// ─────────────────────────────────────────────────────────────────────────────

const _kSurface = Colors.white;
const _kGlass = Color(0xFFE2E8F0);
const _kBorder = Color(0xFFCBD5E1);
const _kAccent1 = Color(0xFF0056A2);
const _kAccent2 = Color(0xFF0284C7);
const _kUserGrad1 = Color(0xFF0056A2);
const _kUserGrad2 = Color(0xFF0284C7);
const _kError = Color(0xFFEF4444);
const _kGreen = Color(0xFF22C55E);

const _kText = Color(0xFF0F172A);
const _kTextSec = Color(0xFF475569);
const _kTextTer = Color(0xFF94A3B8);

// ─────────────────────────────────────────────────────────────────────────────
// Main Widget
// ─────────────────────────────────────────────────────────────────────────────

class AIChatPage extends StatefulWidget {
  const AIChatPage({Key? key}) : super(key: key);

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // State
  bool _isLoading = false;
  bool _isStreaming = false;
  String _serverUrl = 'http://192.168.1.8:3000';
  String? _editingMessageId; // ID of user message being edited

  // Sessions
  List<ChatSession> _sessions = [];
  String _activeSessionId = '';

  // Speech
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isSpeechAvailable = false;
  final FlutterTts _flutterTts = FlutterTts();
  String? _currentlySpeakingMsgId;

  // Quick replies shown after last AI message
  List<String> _quickReplies = [];

  // Streaming accumulator
  ChatMessage? _streamingMessage;

  // Animation controllers
  late AnimationController _headerGlowController;
  late Animation<double> _headerGlowAnim;

  // Suggestions for welcome screen
  final List<String> _suggestedPrompts = [
    'What alarms are currently active?',
    'Show me network node locations',
    'Check service order status',
    'Recent escalations overview',
  ];

  // ── Getters ───────────────────────────────────────────────────────────────

  ChatSession? get _activeSession {
    try {
      return _sessions.firstWhere((s) => s.id == _activeSessionId);
    } catch (_) {
      return null;
    }
  }

  List<ChatMessage> get _messages => _activeSession?.messages ?? [];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    _headerGlowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _headerGlowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _headerGlowController, curve: Curves.easeInOut),
    );

    // Set global flag to hide floating chat button while chat screen is open
    isChatScreenOpen.value = true;

    _loadData();
    _initSpeech();
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _headerGlowController.dispose();
    _speechToText.stop();
    _flutterTts.stop();

    // Reset global flag when leaving chat screen
    isChatScreenOpen.value = false;

    super.dispose();
  }

  // Proactive Alerts State
  Map<String, dynamic>? _criticalAlert;
  bool _dismissAlertBanner = false;
  DateTime? _criticalAlertLastFetched;
  static const Duration _criticalAlertCacheTTL = Duration(seconds: 45);

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    final storage = SecureStorageService();
    String? savedUrl = await storage.read('serverUrl');
    if (savedUrl != null && savedUrl.trim().isNotEmpty) {
      final Uri uri = Uri.parse(savedUrl.trim());
      final String cleanUrl = uri.replace(userInfo: null).toString();
      if (cleanUrl != savedUrl.trim()) {
        await storage.write('serverUrl', cleanUrl);
      }
      _serverUrl = cleanUrl;
    } else {
      _serverUrl = 'http://192.168.1.8:3000';
    }

    final sessionsJson = await storage.read('chat_sessions');
    final activeId = await storage.read('active_session_id');

    if (sessionsJson != null) {
      final decoded = jsonDecode(sessionsJson) as List;
      _sessions = decoded
          .map((j) => ChatSession.fromJson(j as Map<String, dynamic>))
          .toList();
    }

    if (_sessions.isEmpty) {
      _sessions = [ChatSession(name: 'Chat 1')];
    }

    _activeSessionId =
        (activeId != null && _sessions.any((s) => s.id == activeId))
            ? activeId
            : _sessions.first.id;

    setState(() {});
    _fetchCriticalAlerts();
  }

  Future<void> _saveSessions() async {
    final storage = SecureStorageService();
    await storage.write(
        'chat_sessions', jsonEncode(_sessions.map((s) => s.toJson()).toList()));
    await storage.write('active_session_id', _activeSessionId);
  }

  Future<void> _fetchCriticalAlerts() async {
    // Check cache: if we have a recent critical alert, use it and return.
    final now = DateTime.now();
    if (_criticalAlert != null &&
        _criticalAlertLastFetched != null &&
        now.difference(_criticalAlertLastFetched!) < _criticalAlertCacheTTL) {
      return;
    }

    // Try fallback URLs (same pattern as ManualEscalationService)
    final seen = <String>{};
    final List<Uri> uris = [];

    // 1. First try saved server URL
    try {
      final storage = SecureStorageService();
      final savedUrl = await storage.read('serverUrl');
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        final trimmed = savedUrl.trim();
        if (seen.add(trimmed)) {
          uris.add(Uri.parse('$trimmed/api/critical-alerts'));
        }
      }
    } catch (_) {}

    // 2. Then try fallback URLs
    for (final baseUrl in _kChatFallbackUrls) {
      final trimmed = baseUrl.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) continue;
      uris.add(Uri.parse('$trimmed/api/critical-alerts'));
    }

    for (final uri in uris) {
      try {
        final response =
            await http.get(uri).timeout(_kConnectionAttemptTimeout);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['alert'] != null) {
            if (!mounted) return;
            setState(() {
              _criticalAlert = data['alert'] as Map<String, dynamic>;
              _criticalAlertLastFetched = DateTime.now();
            });
            return; // Success - exit the fallback loop
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Critical alerts API failed for $uri: $e');
        }
        // Continue to next fallback URL
      }
    }
  }

  // ── Sessions management ────────────────────────────────────────────────────

  void _createNewSession() {
    final session = ChatSession(name: 'Chat ${_sessions.length + 1}');
    setState(() {
      _sessions.add(session);
      _activeSessionId = session.id;
      _quickReplies = [];
    });
    _saveSessions();
    Navigator.pop(context); // close drawer
  }

  void _switchSession(String sessionId) {
    setState(() {
      _activeSessionId = sessionId;
      _quickReplies = [];
    });
    _saveSessions();
    Navigator.pop(context);
  }

  void _deleteSession(String sessionId) {
    if (_sessions.length == 1) return; // never delete last session
    setState(() {
      _sessions.removeWhere((s) => s.id == sessionId);
      if (_activeSessionId == sessionId) {
        _activeSessionId = _sessions.first.id;
      }
      _quickReplies = [];
    });
    _saveSessions();
  }

  void _renameSession(ChatSession session) {
    final ctrl = TextEditingController(text: session.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Rename Session', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Session name',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _kAccent1),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kAccent1),
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                setState(() => session.name = name);
                _saveSessions();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Speech ─────────────────────────────────────────────────────────────────

  void _initSpeech() async {
    _isSpeechAvailable = await _speechToText.initialize();
    setState(() {});
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      await _speechToText.listen(
        onResult: (result) {
          setState(() => _messageController.text = result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
      setState(() => _isListening = true);
    }
  }

  Future<void> _speak(ChatMessage message) async {
    if (_currentlySpeakingMsgId == message.id) {
      await _flutterTts.stop();
      setState(() {
        _currentlySpeakingMsgId = null;
      });
      return;
    }

    await _flutterTts.stop();

    // Check if message text contains Sinhala characters
    final RegExp sinhalaRegex = RegExp(r'[඀-෿]');
    if (sinhalaRegex.hasMatch(message.text)) {
      await _flutterTts.setLanguage("si-LK");
    } else {
      await _flutterTts.setLanguage("en-US");
    }

    setState(() {
      _currentlySpeakingMsgId = message.id;
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _currentlySpeakingMsgId = null;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _currentlySpeakingMsgId = null;
      });
    });

    await _flutterTts.speak(message.text);
  }

  // ── Messaging ─────────────────────────────────────────────────────────────

  void _onTextChanged() => setState(() {});

  Future<void> _sendMessage([String? prompt]) async {
    final text = (prompt ?? _messageController.text).trim();
    if (text.isEmpty || _isLoading || _isStreaming) return;

    _messageController.clear();
    _editingMessageId = null;
    setState(() => _quickReplies = []);

    // If editing an existing user message, truncate history at that point
    // (This is handled before calling this method via _sendEditedMessage)

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _activeSession!.messages.add(userMsg);
      _isStreaming = true;
    });
    _scrollToBottom();

    // Create a placeholder streaming message
    final streamMsg = ChatMessage(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );
    setState(() {
      _streamingMessage = streamMsg;
      _activeSession!.messages.add(streamMsg);
    });
    _scrollToBottom();

    final conversationHistory = _messages
        .where((m) => m != userMsg && m != streamMsg)
        .map(
            (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();

    // Try fallback URLs (same pattern as ManualEscalationService)
    final seen = <String>{};
    final List<Uri> uris = [];

    // 1. First try saved server URL
    try {
      final storage = SecureStorageService();
      final savedUrl = await storage.read('serverUrl');
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        final trimmed = savedUrl.trim();
        if (seen.add(trimmed)) {
          uris.add(Uri.parse('$trimmed/api/chat-stream'));
        }
      }
    } catch (_) {}

    // 2. Then try fallback URLs
    for (final baseUrl in _kChatFallbackUrls) {
      final trimmed = baseUrl.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) continue;
      uris.add(Uri.parse('$trimmed/api/chat-stream'));
    }

    Object? lastError;
    for (final uri in uris) {
      try {
        final client = http.Client();
        final request = http.Request('POST', uri)
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode({
            'message': text,
            'conversationHistory': conversationHistory,
          });

        final response =
            await client.send(request).timeout(_kConnectionAttemptTimeout);
        if (!mounted) return;

        if (response.statusCode == 200) {
          final StringBuffer buffer = StringBuffer();
          await for (final bytes in response.stream) {
            if (!mounted) return;
            final chunk = utf8.decode(bytes);
            // SSE format: lines starting with "data: "
            for (final line in chunk.split('\n')) {
              final trimmed = line.trim();
              if (trimmed.startsWith('data: ')) {
                final data = trimmed.substring(6);
                if (data == '[DONE]') break;
                try {
                  final json = jsonDecode(data) as Map<String, dynamic>;
                  if (json.containsKey('token')) {
                    buffer.write(json['token']);
                    if (!mounted) return;
                    setState(() {
                      streamMsg.text = buffer.toString();
                      _activeSession!.lastUpdated = DateTime.now();
                    });
                    _scrollToBottom();
                  } else if (json.containsKey('error')) {
                    throw Exception(json['error']);
                  }
                } catch (_) {}
              }
            }
          }
          client.close();

          if (!mounted) return;
          // Final state after stream ends
          setState(() {
            _streamingMessage = null;
            _isStreaming = false;
            _isLoading = false;
          });

          if (streamMsg.text.isNotEmpty) {
            _generateQuickReplies(streamMsg.text);
          }
          _saveSessions();
          _scrollToBottom();
          return; // Success - exit the fallback loop
        } else {
          client.close();
          throw Exception('HTTP ${response.statusCode}');
        }
      } catch (e) {
        lastError = e;
        if (kDebugMode) {
          debugPrint('Chat API failed for $uri: $e');
        }
        // Continue to next fallback URL
      }
    }

    // All fallback URLs failed
    if (!mounted) return;
    setState(() {
      _activeSession!.messages.remove(streamMsg);
      _streamingMessage = null;
      _isStreaming = false;
      _isLoading = false;
    });
    _showError('Connection error: ${lastError ?? 'All servers unreachable'}',
        retryPayload: text);
  }

  /// Called when the user edits a previously sent message.
  void _sendEditedMessage(String messageId, String newText) {
    final session = _activeSession!;
    final idx = session.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    // Remove all messages from the edited one onwards
    session.messages.removeRange(idx, session.messages.length);
    setState(() {});

    // Now send as a fresh message
    _sendMessage(newText);
  }

  void _retryMessage(String userPayload) {
    // Remove the last error message
    final session = _activeSession!;
    if (session.messages.isNotEmpty &&
        session.messages.last.status == MessageStatus.error) {
      setState(() => session.messages.removeLast());
    }
    // Also remove the user message that triggered the error if it's still there
    if (session.messages.isNotEmpty && session.messages.last.isUser) {
      setState(() => session.messages.removeLast());
    }
    _sendMessage(userPayload);
  }

  void _showError(String message, {String? retryPayload}) {
    setState(() {
      _activeSession!.messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
        retryPayload: retryPayload,
      ));
    });
    _saveSessions();
    _scrollToBottom();
  }

  void _clearHistory() {
    setState(() {
      _activeSession!.messages.clear();
      _quickReplies = [];
    });
    _saveSessions();
  }

  // ── Quick Replies ─────────────────────────────────────────────────────────

  void _generateQuickReplies(String aiText) {
    final lower = aiText.toLowerCase();
    final suggestions = <String>[];

    if (lower.contains('alarm')) {
      suggestions.addAll(['Show active alarms', 'How many critical alarms?']);
    }
    if (lower.contains('node') || lower.contains('network')) {
      suggestions.addAll(['Node status summary', 'Show node locations']);
    }
    if (lower.contains('escalat')) {
      suggestions.add('List open escalations');
    }
    if (lower.contains('outage') || lower.contains('plan')) {
      suggestions.add('Planned outages this week');
    }
    if (lower.contains('service') || lower.contains('order')) {
      suggestions.add('Service order details');
    }
    if (lower.contains('clarity')) {
      suggestions.add('Open Clarity tickets');
    }

    // Fallback generic chips
    if (suggestions.isEmpty) {
      suggestions.addAll(['Tell me more', 'Summarise this', 'Show me data']);
    }

    setState(() => _quickReplies = suggestions.take(4).toList());
  }

  // ── Export ────────────────────────────────────────────────────────────────

  Future<void> _exportChat() async {
    final session = _activeSession;
    if (session == null || session.messages.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════');
    buffer.writeln('  NOC AI Assistant — ${session.name}');
    buffer.writeln('  Exported: ${DateTime.now().toString().substring(0, 16)}');
    buffer.writeln('══════════════════════════════════\n');

    for (final msg in session.messages) {
      final sender = msg.isUser ? 'You' : 'AI Assistant';
      final time = _formatTimestamp(msg.timestamp);
      buffer.writeln('[$time] $sender');
      buffer.writeln(msg.text);
      buffer.writeln();
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Chat transcript copied to clipboard!'),
            ],
          ),
          backgroundColor: _kAccent1,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ── Scroll ────────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Server Settings Dialog
  // ─────────────────────────────────────────────────────────────────────────────

  void _showSettingsDialog() {
    final controller = TextEditingController(text: _serverUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.wifi, color: _kAccent2),
            SizedBox(width: 8),
            Text('Server Connection', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kGlass,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder),
              ),
              child: const Text(
                '📱 On iPhone, use your laptop IP:\nhttp://192.168.x.x:3000\n\n💻 Find IP: ipconfig getifaddr en0',
                style:
                    TextStyle(fontSize: 12, color: Colors.white60, height: 1.5),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Server URL',
                labelStyle: const TextStyle(color: Colors.white54),
                hintText: 'http://192.168.1.x:3000',
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: const Icon(Icons.link, color: _kAccent2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _kAccent1, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save & Connect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent1,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                try {
                  final Uri uri = Uri.parse(newUrl);
                  final String cleanUrl = uri.replace(userInfo: null).toString();
                  final bool hadCredentials = uri.userInfo.isNotEmpty;

                  final storage = SecureStorageService();
                  await storage.write('serverUrl', cleanUrl);
                  setState(() => _serverUrl = cleanUrl);
                  Navigator.pop(ctx);
                  if (mounted) {
                    String message;
                    Color color;
                    if (hadCredentials) {
                      message = 'Credentials removed for security. Only the base URL is stored.';
                      color = _kAccent1;
                    } else {
                      message = 'Connected to $cleanUrl';
                      color = _kGreen;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                      backgroundColor: color,
                      duration: const Duration(seconds: 2),
                    ));
                  }
                } on FormatException catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Invalid URL'),
                      backgroundColor: _kError,
                      duration: const Duration(seconds: 2),
                    ));
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Message Actions Bottom Sheet
  // ─────────────────────────────────────────────────────────────────────────────

  void _showMessageActions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _actionTile(Icons.copy_rounded, Colors.white70, 'Copy text', () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: message.text));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 2),
                ));
              }),
              if (message.isUser)
                _actionTile(Icons.edit_rounded, _kAccent2, 'Edit & Resend', () {
                  Navigator.pop(ctx);
                  setState(() {
                    _editingMessageId = message.id;
                    _messageController.text = message.text;
                    _messageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: message.text.length));
                  });
                }),
              _actionTile(Icons.share_rounded, _kGreen, 'Share message', () {
                Navigator.pop(ctx);
                Clipboard.setData(ClipboardData(text: message.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Message copied to clipboard'),
                    backgroundColor: _kGreen,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  ListTile _actionTile(
      IconData icon, Color color, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: _buildSessionsDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/appbarbg2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCriticalAlertBanner(),
              Expanded(child: _buildMessagesArea()),
              if (_quickReplies.isNotEmpty) _buildQuickReplies(),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Sessions Drawer
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSessionsDrawer() {
    return Drawer(
      backgroundColor: _kSurface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [_kAccent1, _kAccent2],
                    ).createShader(b),
                    child: const Icon(Icons.forum_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Text('Sessions',
                      style: TextStyle(
                          color: _kText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    onPressed: _createNewSession,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_kAccent1, _kAccent2]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                    tooltip: 'New session',
                  ),
                ],
              ),
            ),
            const Divider(color: _kBorder),
            // Session list
            Expanded(
              child: ListView.builder(
                itemCount: _sessions.length,
                itemBuilder: (ctx, i) {
                  final session = _sessions[i];
                  final isActive = session.id == _activeSessionId;
                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [
                                Color(0x336C63FF),
                                Color(0x1F0056A2),
                                Color(0x1F0284C7),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isActive ? _kAccent1 : Colors.transparent),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: isActive ? _kAccent2 : _kTextTer,
                        size: 20,
                      ),
                      title: Text(
                        session.name,
                        style: TextStyle(
                          color: isActive ? _kAccent1 : _kTextSec,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${session.messages.length} messages',
                        style: const TextStyle(color: _kTextTer, fontSize: 11),
                      ),
                      onTap: () => _switchSession(session.id),
                      trailing: PopupMenuButton<String>(
                        color: _kSurface,
                        icon: const Icon(Icons.more_vert,
                            color: _kTextTer, size: 18),
                        onSelected: (val) {
                          if (val == 'rename') _renameSession(session);
                          if (val == 'delete') _deleteSession(session.id);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(children: [
                              Icon(Icons.edit, color: _kAccent2, size: 16),
                              SizedBox(width: 8),
                              Text('Rename', style: TextStyle(color: _kText)),
                            ]),
                          ),
                          if (_sessions.length > 1)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete_outline,
                                    color: _kError, size: 16),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: _kError)),
                              ]),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerGlowAnim,
      builder: (ctx, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _kSurface,
          border: Border(
            bottom: BorderSide(
              color: Color.lerp(_kAccent1, _kAccent2, _headerGlowAnim.value)!
                  .withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: _kAccent1.withValues(alpha: 0.15 * _headerGlowAnim.value),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
      child: Row(
        children: [
          // Sessions button
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: const Icon(Icons.menu_rounded, color: _kTextSec, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Sessions',
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [_kAccent1, _kAccent2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              boxShadow: [
                BoxShadow(
                    color: _kAccent1.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1)
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/chatbot-icon.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activeSession?.name ?? 'AI Assistant',
                  style: const TextStyle(
                    color: _kText,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _isStreaming ? 'Streaming response...' : 'Online',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _isStreaming ? _kAccent2 : _kGreen,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Export button
          if (_messages.isNotEmpty)
            IconButton(
              onPressed: _exportChat,
              icon: const Icon(Icons.ios_share_rounded,
                  size: 20, color: _kTextSec),
              tooltip: 'Export chat',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 4),
          // Clear button
          if (_messages.isNotEmpty)
            GestureDetector(
              onTap: _clearHistory,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kGlass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kBorder),
                ),
                child: const Text('Clear',
                    style: TextStyle(color: _kTextSec, fontSize: 12)),
              ),
            ),
          const SizedBox(width: 6),
          // Settings
          IconButton(
            onPressed: _showSettingsDialog,
            icon: const Icon(Icons.wifi_tethering_rounded,
                size: 20, color: _kTextSec),
            tooltip: 'Server',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // Close
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, size: 20, color: _kTextTer),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Messages Area
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildMessagesArea() {
    return _messages.isEmpty
        ? _buildWelcomeScreen()
        : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) {
              final msg = _messages[i];
              return _buildMessageBubble(msg);
            },
          );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Welcome Screen
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glowing logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [_kAccent1, _kAccent2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  boxShadow: [
                    BoxShadow(
                        color: _kAccent1.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 4)
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child:
                    Image.asset('assets/chatbot-icon.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (b) =>
                    const LinearGradient(colors: [_kAccent1, _kAccent2])
                        .createShader(b),
                child: const Text(
                  'NOC AI Assistant',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700, color: _kText),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ask me about network nodes, alarms, escalations, or system insights.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _kTextSec, height: 1.5),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _suggestedPrompts.map((p) {
                  return GestureDetector(
                    onTap: () => _sendMessage(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _kGlass,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Text(
                        p,
                        style: const TextStyle(
                            fontSize: 12,
                            color: _kAccent2,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Message Bubble
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildMessageBubble(ChatMessage message) {
    final isError = message.status == MessageStatus.error;
    final isStreaming = _streamingMessage?.id == message.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: () => _showMessageActions(message),
            child: Row(
              mainAxisAlignment: message.isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // AI avatar
                if (!message.isUser) ...[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isError
                          ? const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF3D3D)])
                          : const LinearGradient(
                              colors: [_kAccent1, _kAccent2]),
                      boxShadow: [
                        BoxShadow(
                            color: (isError ? _kError : _kAccent1)
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1)
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: isError
                        ? const Icon(Icons.error_outline,
                            color: Colors.white, size: 14)
                        : Image.asset('assets/chatbot-icon.png',
                            fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 8),
                ],
                // Bubble
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: message.isUser
                        ? BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_kUserGrad1, _kUserGrad2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: _kAccent1.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4))
                            ],
                          )
                        : BoxDecoration(
                            color: isError
                                ? const Color(0x26EF4444)
                                : Colors.white,
                            border: Border.all(
                                color: isError
                                    ? _kError.withValues(alpha: 0.4)
                                    : const Color(0xFFE2E8F0)),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: isError
                                ? [
                                    BoxShadow(
                                        color: _kError.withValues(alpha: 0.15),
                                        blurRadius: 12)
                                  ]
                                : [
                                    BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2))
                                  ],
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Editing indicator
                        if (_editingMessageId == message.id)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit,
                                    size: 11, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text('Editing…',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white
                                            .withValues(alpha: 0.7)))
                              ],
                            ),
                          ),
                        // Message content or streaming cursor
                        if (isStreaming && message.text.isEmpty)
                          _buildTypingIndicator()
                        else ...[
                          MarkdownText(
                            text:
                                isStreaming ? '${message.text}▍' : message.text,
                            style: TextStyle(
                              color: message.isUser
                                  ? Colors.white
                                  : isError
                                      ? _kError
                                      : _kText,
                              fontSize: 14,
                            ),
                          ),
                          if (!message.isUser &&
                              message.text.isNotEmpty &&
                              !isStreaming)
                            _buildActionChips(message),
                        ],
                        // Error retry button
                        if (isError && message.retryPayload != null) ...[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _retryMessage(message.retryPayload!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _kError.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: _kError.withValues(alpha: 0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh_rounded,
                                      size: 14, color: _kError),
                                  SizedBox(width: 6),
                                  Text('Retry',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: _kError,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // User avatar
                if (message.isUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [_kUserGrad1, _kUserGrad2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 14, color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              left: message.isUser ? 0 : 40,
              right: message.isUser ? 40 : 0,
              top: 4,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTimestamp(message.timestamp),
                  style: const TextStyle(fontSize: 10, color: Colors.white24),
                ),
                if (!message.isUser &&
                    message.text.isNotEmpty &&
                    !isStreaming) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _speak(message),
                    child: Icon(
                      _currentlySpeakingMsgId == message.id
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      size: 14,
                      color: _currentlySpeakingMsgId == message.id
                          ? _kAccent2
                          : Colors.white30,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return _BouncingDot(delay: Duration(milliseconds: i * 150));
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Quick Replies
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildQuickReplies() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _quickReplies.map((q) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _sendMessage(q),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _kGlass,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kAccent1.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 13, color: _kAccent2),
                      const SizedBox(width: 4),
                      Text(q,
                          style: const TextStyle(
                              fontSize: 12,
                              color: _kAccent2,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Input Area
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildInputArea() {
    final isEditing = _editingMessageId != null;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          decoration: BoxDecoration(
            color: _kSurface.withValues(alpha: 0.9),
            border: const Border(top: BorderSide(color: _kBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Editing indicator banner
              if (isEditing)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kAccent2.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kAccent2.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded,
                          size: 14, color: _kAccent2),
                      const SizedBox(width: 6),
                      const Text('Editing message',
                          style: TextStyle(color: _kAccent2, fontSize: 12)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          _editingMessageId = null;
                          _messageController.clear();
                        }),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              // Input Row
              Row(
                children: [
                  // Text field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _kGlass,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isEditing
                              ? _kAccent2.withValues(alpha: 0.5)
                              : _kBorder,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: _kText, fontSize: 14),
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: isEditing
                              ? 'Edit your message…'
                              : 'Ask the NOC AI…',
                          hintStyle:
                              const TextStyle(color: _kTextTer, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) {
                          if (isEditing && _editingMessageId != null) {
                            _sendEditedMessage(_editingMessageId!,
                                _messageController.text.trim());
                          } else {
                            _sendMessage();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // NOC Tools Preset button
                  _circleButton(
                    onTap: _showNocToolsSheet,
                    icon: Icons.grid_view_rounded,
                    color: _kAccent2,
                    bgColor: _kGlass,
                    border: const BorderSide(color: _kBorder),
                  ),
                  const SizedBox(width: 6),
                  // Mic button
                  if (_isSpeechAvailable)
                    _circleButton(
                      onTap:
                          _isLoading || _isStreaming ? null : _toggleListening,
                      icon: _isListening
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      color: _isListening ? _kError : Colors.white54,
                      bgColor: _isListening
                          ? _kError.withValues(alpha: 0.15)
                          : _kGlass,
                      border: _isListening
                          ? BorderSide(color: _kError.withValues(alpha: 0.4))
                          : const BorderSide(color: _kBorder),
                    ),
                  if (_isSpeechAvailable) const SizedBox(width: 6),
                  // Send button
                  _buildSendButton(isEditing),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Proactive Outage Alert Banner
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCriticalAlertBanner() {
    if (_dismissAlertBanner ||
        _criticalAlert == null ||
        _criticalAlert!['hasCriticalAlert'] != true) {
      return const SizedBox.shrink();
    }
    final alarmsCount = _criticalAlert!['totalOpenAlarms'] ?? 0;
    final topProvince = _criticalAlert!['topProvince'] ?? 'N/A';
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x33EF4444), Color(0x22F97316)],
        ),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚨 Critical Outage Alert',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                Text(
                  '$alarmsCount active faults detected ($topProvince Province peak)',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _sendMessage('Show open alarms in $topProvince province');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Inspect',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _dismissAlertBanner = true),
            child: const Icon(Icons.close_rounded,
                color: Colors.white38, size: 18),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Interactive Action Chips under AI Messages
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildActionChips(ChatMessage message) {
    final text = message.text;
    final chips = <Widget>[];

    // 1. Detect Nodes (MSAN, OLT, BTS, NODEB, ENODEB)
    final nodeMatch = RegExp(
            r'\b([A-Za-z0-9_-]*(MSAN|OLT|BTS|NODEB|ENODEB|CEA)[A-Za-z0-9_-]*)\b',
            caseSensitive: false)
        .firstMatch(text);
    if (nodeMatch != null) {
      final nodeName = nodeMatch.group(1)!;
      chips.add(_actionChip(
        icon: Icons.location_on_rounded,
        label: 'Node: $nodeName',
        color: _kAccent2,
        onTap: () => _sendMessage('Check node details for $nodeName'),
      ));
    }

    // 2. Detect Groups (CEN-CSC-NW, etc.)
    final groupMatch =
        RegExp(r'[A-Z]{3}-[A-Z]{3}(-[A-Z]{2,4})?').firstMatch(text);
    if (groupMatch != null) {
      final groupName = groupMatch.group(0)!;
      chips.add(_actionChip(
        icon: Icons.group_rounded,
        label: 'Group: $groupName',
        color: _kGreen,
        onTap: () =>
            _sendMessage('Show open alarms for engineering group $groupName'),
      ));
    }

    // 3. Detect Province
    for (final prov in [
      'Western',
      'Southern',
      'Central',
      'Sabaragamuwa',
      'Eastern',
      'Uva',
      'Northern',
      'North Western',
      'North Central'
    ]) {
      if (text.toLowerCase().contains(prov.toLowerCase())) {
        chips.add(_actionChip(
          icon: Icons.map_rounded,
          label: '$prov Alarms',
          color: const Color(0xFF8B5CF6),
          onTap: () => _sendMessage('Show open alarms in $prov province'),
        ));
        break;
      }
    }

    // 4. Escalations Trigger
    if (text.toLowerCase().contains('escalat')) {
      chips.add(_actionChip(
        icon: Icons.assignment_late_rounded,
        label: 'Active Escalations',
        color: _kError,
        onTap: () => _sendMessage('Show active manual escalations'),
      ));
    }

    // 5. Predictive Analytics Trigger
    if (text.toLowerCase().contains('recur') ||
        text.toLowerCase().contains('repeat') ||
        text.toLowerCase().contains('predict')) {
      chips.add(_actionChip(
        icon: Icons.auto_graph_rounded,
        label: 'Predictive Report',
        color: Colors.amber,
        onTap: () => _sendMessage('Show recurring fault nodes'),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: chips,
      ),
    );
  }

  Widget _actionChip(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // NOC Tools Bottom Sheet
  // ─────────────────────────────────────────────────────────────────────────────

  void _showNocToolsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '🛠️ NOC AI Assistant Tools',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select a tool preset or attach data to analyze.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: [
                    _nocToolCard(
                      icon: Icons.auto_graph_rounded,
                      color: Colors.amber,
                      title: 'Predict Faults',
                      subtitle: 'Recurring node report',
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendMessage(
                            'Show recurring and high-risk fault nodes');
                      },
                    ),
                    _nocToolCard(
                      icon: Icons.assignment_late_rounded,
                      color: _kError,
                      title: 'Escalations',
                      subtitle: 'Active escalation list',
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendMessage('Show active manual escalations');
                      },
                    ),
                    _nocToolCard(
                      icon: Icons.pie_chart_rounded,
                      color: _kAccent2,
                      title: 'Alarm Matrix',
                      subtitle: 'Provinces summary',
                      onTap: () {
                        Navigator.pop(ctx);
                        _sendMessage('Show general alarms summary');
                      },
                    ),
                    _nocToolCard(
                      icon: Icons.receipt_long_rounded,
                      color: _kGreen,
                      title: 'Log Analysis',
                      subtitle: 'Insert syslog sample',
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _messageController.text =
                              'SYS_LOG: Colombo_MSAN_02 Port Ethernet 0/1 Link Down. Duration 4.5h. Analyze root cause.';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _nocToolCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    VoidCallback? onTap,
    required IconData icon,
    required Color color,
    required Color bgColor,
    BorderSide border = BorderSide.none,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.fromBorderSide(border),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildSendButton(bool isEditing) {
    final canSend = _messageController.text.trim().isNotEmpty &&
        !_isLoading &&
        !_isStreaming;

    return GestureDetector(
      onTap: canSend
          ? () {
              if (isEditing && _editingMessageId != null) {
                _sendEditedMessage(
                    _editingMessageId!, _messageController.text.trim());
              } else {
                _sendMessage();
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: canSend
              ? const LinearGradient(
                  colors: [_kAccent1, _kAccent2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: canSend ? null : _kGlass,
          border: Border.all(color: _kBorder),
          boxShadow: canSend
              ? [
                  BoxShadow(
                    color: _kAccent1.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Icon(
          isEditing ? Icons.check_rounded : Icons.send_rounded,
          size: 18,
          color: canSend ? Colors.white : _kTextTer,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouncing Dot
// ─────────────────────────────────────────────────────────────────────────────

class _BouncingDot extends StatefulWidget {
  final Duration delay;
  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
    _anim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: _kAccent2,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Markdown Text Renderer
// ─────────────────────────────────────────────────────────────────────────────

class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MarkdownText({Key? key, required this.text, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> blocks = [];
    List<String> parts = text.split('```');

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 1) {
        String code = parts[i];
        String? language;
        int firstNewline = code.indexOf('\n');
        if (firstNewline != -1) {
          String possibleLang = code.substring(0, firstNewline).trim();
          if (possibleLang.isNotEmpty &&
              !possibleLang.contains(' ') &&
              possibleLang.length < 10) {
            language = possibleLang;
            code = code.substring(firstNewline + 1);
          }
        }
        blocks.add(_buildCodeBlock(code.trim(), language));
      } else {
        String normalText = parts[i];
        if (normalText.isNotEmpty) {
          blocks.addAll(_parseParagraphs(normalText));
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: blocks,
    );
  }

  Widget _buildCodeBlock(String code, String? language) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x336C63FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (language != null) ...[
            Text(
              language.toUpperCase(),
              style: const TextStyle(
                color: _kAccent2,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 6),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              code,
              style: const TextStyle(
                color: Color(0xFF4ADE80),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _parseParagraphs(String blockText) {
    List<Widget> widgets = [];
    List<String> lines = blockText.split('\n');
    List<String> currentParagraph = [];

    void flushParagraph() {
      if (currentParagraph.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: RichText(
            text: TextSpan(
              children: _parseInline(currentParagraph.join('\n')),
              style: TextStyle(
                fontSize: 14,
                color: style?.color ?? Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ));
        currentParagraph.clear();
      }
    }

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      String trimmed = line.trim();

      if (trimmed.startsWith('#')) {
        flushParagraph();
        int level = 0;
        while (level < trimmed.length && trimmed[level] == '#') {
          level++;
        }
        String headingText = trimmed.substring(level).trim();
        double fontSize = level == 1
            ? 20.0
            : level == 2
                ? 17.0
                : level == 3
                    ? 15.0
                    : 14.0;

        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: RichText(
            text: TextSpan(
              children: _parseInline(headingText),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: style?.color ?? Colors.white,
              ),
            ),
          ),
        ));
      } else if (trimmed.startsWith('- ') ||
          trimmed.startsWith('* ') ||
          trimmed.startsWith('• ')) {
        flushParagraph();
        String itemText = trimmed.substring(2).trim();
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ',
                  style: TextStyle(
                      fontSize: 14, color: style?.color ?? _kAccent2)),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: _parseInline(itemText),
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          style?.color ?? Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
      } else if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
        flushParagraph();
        Match match = RegExp(r'^(\d+\.)\s(.*)').firstMatch(trimmed)!;
        String number = match.group(1)!;
        String itemText = match.group(2)!;
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$number ',
                  style: TextStyle(
                      fontSize: 14, color: style?.color ?? _kAccent2)),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: _parseInline(itemText),
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          style?.color ?? Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
      } else if (trimmed.isEmpty) {
        flushParagraph();
        widgets.add(const SizedBox(height: 4));
      } else {
        currentParagraph.add(line);
      }
    }

    flushParagraph();
    return widgets;
  }

  List<TextSpan> _parseInline(String text) {
    List<TextSpan> spans = [];
    final regex = RegExp(r'(\*\*.*?\*\*|`.*?`|_.*?_)');
    final matches = regex.allMatches(text);

    int start = 0;
    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }

      String matchText = match.group(0)!;
      if (matchText.startsWith('**') && matchText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (matchText.startsWith('`') && matchText.endsWith('`')) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: TextStyle(
            fontFamily: 'monospace',
            backgroundColor: const Color(0x226C63FF),
            color: _kAccent2,
            fontSize: 13,
          ),
        ));
      } else if (matchText.startsWith('_') && matchText.endsWith('_')) {
        spans.add(TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      } else {
        spans.add(TextSpan(text: matchText));
      }

      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }
}