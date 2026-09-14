import 'chat_message.dart';

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
