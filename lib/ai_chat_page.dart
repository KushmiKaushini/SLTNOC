import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sltnoc/secure_storage_service.dart';
import 'shared_state.dart';

// Modular ai_chat components
import 'ai_chat/constants/chat_constants.dart';
import 'ai_chat/models/chat_message.dart';
import 'ai_chat/models/chat_session.dart';
import 'ai_chat/services/chat_api_service.dart';
import 'ai_chat/services/speech_service.dart';
import 'ai_chat/widgets/chat_header.dart';
import 'ai_chat/widgets/chat_input_area.dart';
import 'ai_chat/widgets/chat_message_bubble.dart';
import 'ai_chat/widgets/chat_sessions_drawer.dart';
import 'ai_chat/widgets/chat_welcome_screen.dart';
import 'ai_chat/widgets/critical_alert_banner.dart';
import 'ai_chat/widgets/noc_tools_sheet.dart';
import 'ai_chat/widgets/server_settings_dialog.dart';

// Re-export core models and markdown widget for backward compatibility
export 'ai_chat/models/chat_message.dart';
export 'ai_chat/models/chat_session.dart';
export 'ai_chat/widgets/markdown_text.dart';

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
  String? _editingMessageId;

  // Sessions
  List<ChatSession> _sessions = [];
  String _activeSessionId = '';

  // Services
  final ChatApiService _apiService = ChatApiService();
  final SpeechService _speechService = SpeechService();

  // Quick replies
  List<String> _quickReplies = [];

  // Streaming accumulator
  ChatMessage? _streamingMessage;

  // Animation controller
  late AnimationController _headerGlowController;
  late Animation<double> _headerGlowAnim;

  // Proactive Alerts State
  Map<String, dynamic>? _criticalAlert;
  bool _dismissAlertBanner = false;

  ChatSession? get _activeSession {
    try {
      return _sessions.firstWhere((s) => s.id == _activeSessionId);
    } catch (_) {
      return null;
    }
  }

  List<ChatMessage> get _messages => _activeSession?.messages ?? [];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);

    _headerGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _headerGlowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _headerGlowController, curve: Curves.easeInOut),
    );

    // Hide floating chat button while chat screen is open
    isChatScreenOpen.value = true;

    _loadData();
    _speechService.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _headerGlowController.dispose();
    _speechService.stop();

    // Re-enable floating button on exit
    isChatScreenOpen.value = false;

    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  Future<void> _loadData() async {
    final storage = SecureStorageService();
    final savedUrl = await storage.getServerUrl();
    if (savedUrl != null && savedUrl.trim().isNotEmpty) {
      _serverUrl = savedUrl.trim();
    } else {
      _serverUrl = 'http://192.168.1.8:3000';
    }

    final sessionsJson = await storage.read('chat_sessions');
    final activeId = await storage.read('active_session_id');

    if (sessionsJson != null) {
      try {
        final decoded = jsonDecode(sessionsJson) as List;
        _sessions = decoded
            .map((j) => ChatSession.fromJson(j as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    if (_sessions.isEmpty) {
      _sessions = [ChatSession(name: 'Chat 1')];
    }

    _activeSessionId =
        (activeId != null && _sessions.any((s) => s.id == activeId))
            ? activeId
            : _sessions.first.id;

    if (mounted) setState(() {});

    final alert = await _apiService.fetchCriticalAlerts();
    if (mounted && alert != null) {
      setState(() => _criticalAlert = alert);
    }
  }

  Future<void> _saveSessions() async {
    final storage = SecureStorageService();
    await storage.write(
      'chat_sessions',
      jsonEncode(_sessions.map((s) => s.toJson()).toList()),
    );
    await storage.write('active_session_id', _activeSessionId);
  }

  void _createNewSession() {
    final session = ChatSession(name: 'Chat ${_sessions.length + 1}');
    setState(() {
      _sessions.add(session);
      _activeSessionId = session.id;
      _quickReplies = [];
    });
    _saveSessions();
    Navigator.pop(context);
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
    if (_sessions.length <= 1) return;
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
        backgroundColor: kChatSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename Session', style: TextStyle(color: kChatText)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: kChatText),
          decoration: InputDecoration(
            hintText: 'Session name',
            hintStyle: const TextStyle(color: kChatTextTer),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kChatBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kChatAccent1),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kChatTextSec)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kChatAccent1),
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

  Future<void> _sendMessage([String? prompt]) async {
    final text = (prompt ?? _messageController.text).trim();
    if (text.isEmpty || _isLoading || _isStreaming || _activeSession == null) return;

    _messageController.clear();
    _editingMessageId = null;
    setState(() => _quickReplies = []);

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final streamMsg = ChatMessage(
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _activeSession!.messages.add(userMsg);
      _streamingMessage = streamMsg;
      _activeSession!.messages.add(streamMsg);
      _isStreaming = true;
    });
    _scrollToBottom();

    final conversationHistory = _messages
        .where((m) => m != userMsg && m != streamMsg)
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();

    final StringBuffer buffer = StringBuffer();

    await _apiService.streamChatMessage(
      text: text,
      conversationHistory: conversationHistory,
      onToken: (token) {
        if (!mounted) return;
        buffer.write(token);
        setState(() {
          streamMsg.text = buffer.toString();
          _activeSession!.lastUpdated = DateTime.now();
        });
        _scrollToBottom();
      },
      onComplete: () {
        if (!mounted) return;
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
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _activeSession!.messages.remove(streamMsg);
          _streamingMessage = null;
          _isStreaming = false;
          _isLoading = false;
        });
        _showError('Connection error: $error', retryPayload: text);
      },
    );
  }

  void _sendEditedMessage(String messageId, String newText) {
    final session = _activeSession;
    if (session == null) return;
    final idx = session.messages.indexWhere((m) => m.id == messageId);
    if (idx == -1) return;

    session.messages.removeRange(idx, session.messages.length);
    setState(() {});
    _sendMessage(newText);
  }

  void _retryMessage(String userPayload) {
    final session = _activeSession;
    if (session == null) return;

    if (session.messages.isNotEmpty &&
        session.messages.last.status == MessageStatus.error) {
      setState(() => session.messages.removeLast());
    }
    if (session.messages.isNotEmpty && session.messages.last.isUser) {
      setState(() => session.messages.removeLast());
    }
    _sendMessage(userPayload);
  }

  void _showError(String message, {String? retryPayload}) {
    if (_activeSession == null) return;
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
    if (_activeSession == null) return;
    setState(() {
      _activeSession!.messages.clear();
      _quickReplies = [];
    });
    _saveSessions();
  }

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

    if (suggestions.isEmpty) {
      suggestions.addAll(['Tell me more', 'Summarise this', 'Show me data']);
    }

    setState(() => _quickReplies = suggestions.take(4).toList());
  }

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
      buffer.writeln('[$sender]: ${msg.text}\n');
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
          backgroundColor: kChatAccent1,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

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

  void _showMessageActions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kChatSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: kChatTextSec),
                title: const Text('Copy text', style: TextStyle(color: kChatText)),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: message.text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ));
                },
              ),
              if (message.isUser)
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: kChatAccent2),
                  title: const Text('Edit & Resend', style: TextStyle(color: kChatText)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _editingMessageId = message.id;
                      _messageController.text = message.text;
                      _messageController.selection = TextSelection.fromPosition(
                        TextPosition(offset: message.text.length),
                      );
                    });
                  },
                ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: kChatGreen),
                title: const Text('Share message', style: TextStyle(color: kChatText)),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: message.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Message copied to clipboard'),
                      backgroundColor: kChatGreen,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: ChatSessionsDrawer(
        sessions: _sessions,
        activeSessionId: _activeSessionId,
        onNewSession: _createNewSession,
        onSwitchSession: _switchSession,
        onDeleteSession: _deleteSession,
        onRenameSession: _renameSession,
      ),
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
              ChatHeader(
                title: _activeSession?.name ?? 'AI Assistant',
                isStreaming: _isStreaming,
                hasMessages: _messages.isNotEmpty,
                glowAnim: _headerGlowAnim,
                onOpenDrawer: () => Scaffold.of(context).openDrawer(),
                onExportChat: _exportChat,
                onClearHistory: _clearHistory,
                onOpenSettings: () {
                  ServerSettingsDialog.show(
                    context: context,
                    currentUrl: _serverUrl,
                    onUrlSaved: (url) => setState(() => _serverUrl = url),
                  );
                },
                onClose: () => Navigator.pop(context),
              ),
              CriticalAlertBanner(
                alertData: _criticalAlert,
                isDismissed: _dismissAlertBanner,
                onInspect: (prompt) => _sendMessage(prompt),
                onDismiss: () => setState(() => _dismissAlertBanner = true),
              ),
              Expanded(
                child: _messages.isEmpty
                    ? ChatWelcomeScreen(
                        onSelectPrompt: (prompt) => _sendMessage(prompt),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) {
                          final msg = _messages[i];
                          return ChatMessageBubble(
                            message: msg,
                            isStreaming: _streamingMessage?.id == msg.id,
                            isEditing: _editingMessageId == msg.id,
                            isCurrentlySpeaking:
                                _speechService.currentlySpeakingId == msg.id,
                            onLongPress: () => _showMessageActions(msg),
                            onSpeak: () => _speechService.speak(
                              messageId: msg.id,
                              text: msg.text,
                              onSpeakingStateChanged: () {
                                if (mounted) setState(() {});
                              },
                            ),
                            onRetry: (payload) => _retryMessage(payload),
                            onActionPrompt: (prompt) => _sendMessage(prompt),
                          );
                        },
                      ),
              ),
              if (_quickReplies.isNotEmpty)
                Container(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: kChatGlass,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: kChatAccent1.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt_rounded,
                                      size: 13, color: kChatAccent2),
                                  const SizedBox(width: 4),
                                  Text(
                                    q,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: kChatAccent2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ChatInputArea(
                controller: _messageController,
                isEditing: _editingMessageId != null,
                isLoading: _isLoading,
                isStreaming: _isStreaming,
                isSpeechAvailable: _speechService.isSpeechAvailable,
                isListening: _speechService.isListening,
                onCancelEdit: () {
                  setState(() {
                    _editingMessageId = null;
                    _messageController.clear();
                  });
                },
                onOpenNocTools: () {
                  NocToolsSheet.show(
                    context: context,
                    onSelectPrompt: (p) => _sendMessage(p),
                    onInsertLogSnippet: (s) {
                      setState(() => _messageController.text = s);
                    },
                  );
                },
                onToggleSpeech: () {
                  _speechService.toggleListening(
                    onResult: (text) {
                      setState(() => _messageController.text = text);
                    },
                    onStateChange: (listening) {
                      if (mounted) setState(() {});
                    },
                  );
                },
                onSendMessage: () {
                  if (_editingMessageId != null) {
                    _sendEditedMessage(
                      _editingMessageId!,
                      _messageController.text.trim(),
                    );
                  } else {
                    _sendMessage();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
