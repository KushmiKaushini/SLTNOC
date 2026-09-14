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
