import 'package:flutter/material.dart';
import '../constants/chat_constants.dart';
import '../models/chat_message.dart';
import 'bouncing_dot.dart';
import 'markdown_text.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isStreaming;
  final bool isEditing;
  final bool isCurrentlySpeaking;
  final VoidCallback onLongPress;
  final VoidCallback onSpeak;
  final void Function(String payload) onRetry;
  final void Function(String prompt) onActionPrompt;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.isStreaming,
    required this.isEditing,
    required this.isCurrentlySpeaking,
    required this.onLongPress,
    required this.onSpeak,
    required this.onRetry,
    required this.onActionPrompt,
  }) : super(key: key);

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final isError = message.status == MessageStatus.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: onLongPress,
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
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF3D3D)],
                            )
                          : const LinearGradient(
                              colors: [kChatAccent1, kChatAccent2],
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: (isError ? kChatError : kChatAccent1)
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: isError
                        ? const Icon(Icons.error_outline,
                            color: Colors.white, size: 14)
                        : Image.asset('assets/chatbot-icon.webp',
                            fit: BoxFit.contain),
                  ),
                  const SizedBox(width: 8),
                ],

                // Bubble Body
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
                              colors: [kChatUserGrad1, kChatUserGrad2],
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
                                color: kChatAccent1.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          )
                        : BoxDecoration(
                            color: isError
                                ? const Color(0x26EF4444)
                                : Colors.white,
                            border: Border.all(
                              color: isError
                                  ? kChatError.withValues(alpha: 0.4)
                                  : const Color(0xFFE2E8F0),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: isError
                                ? [
                                    BoxShadow(
                                      color: kChatError.withValues(alpha: 0.15),
                                      blurRadius: 12,
                                    )
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                          ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isEditing)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit,
                                    size: 11, color: Colors.white70),
                                const SizedBox(width: 4),
                                Text(
                                  'Editing…',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (isStreaming && message.text.isEmpty)
                          _buildTypingIndicator()
                        else ...[
                          MarkdownText(
                            text: isStreaming
                                ? '${message.text}▍'
                                : message.text,
                            style: TextStyle(
                              color: message.isUser
                                  ? Colors.white
                                  : isError
                                      ? kChatError
                                      : kChatText,
                              fontSize: 14,
                            ),
                          ),
                          if (!message.isUser &&
                              message.text.isNotEmpty &&
                              !isStreaming)
                            _buildActionChips(message.text),
                        ],
                        if (isError && message.retryPayload != null) ...[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => onRetry(message.retryPayload!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: kChatError.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: kChatError.withValues(alpha: 0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh_rounded,
                                      size: 14, color: kChatError),
                                  SizedBox(width: 6),
                                  Text(
                                    'Retry',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kChatError,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                        colors: [kChatUserGrad1, kChatUserGrad2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 14, color: Colors.white),
                  ),
                ],
              ],
            ),
          ),

          // Timestamp & TTS volume
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
                    onTap: onSpeak,
                    child: Icon(
                      isCurrentlySpeaking
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      size: 14,
                      color: isCurrentlySpeaking ? kChatAccent2 : Colors.white30,
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
        return BouncingDot(delay: Duration(milliseconds: i * 150));
      }),
    );
  }

  Widget _buildActionChips(String text) {
    final chips = <Widget>[];

    // 1. Nodes
    final nodeMatch = RegExp(
      r'\b([A-Za-z0-9_-]*(MSAN|OLT|BTS|NODEB|ENODEB|CEA)[A-Za-z0-9_-]*)\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (nodeMatch != null) {
      final nodeName = nodeMatch.group(1)!;
      chips.add(_actionChip(
        icon: Icons.location_on_rounded,
        label: 'Node: $nodeName',
        color: kChatAccent2,
        onTap: () => onActionPrompt('Check node details for $nodeName'),
      ));
    }

    // 2. Groups
    final groupMatch =
        RegExp(r'[A-Z]{3}-[A-Z]{3}(-[A-Z]{2,4})?').firstMatch(text);
    if (groupMatch != null) {
      final groupName = groupMatch.group(0)!;
      chips.add(_actionChip(
        icon: Icons.group_rounded,
        label: 'Group: $groupName',
        color: kChatGreen,
        onTap: () =>
            onActionPrompt('Show open alarms for engineering group $groupName'),
      ));
    }

    // 3. Provinces
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
          onTap: () => onActionPrompt('Show open alarms in $prov province'),
        ));
        break;
      }
    }

    // 4. Escalations Trigger
    if (text.toLowerCase().contains('escalat')) {
      chips.add(_actionChip(
        icon: Icons.assignment_late_rounded,
        label: 'Active Escalations',
        color: kChatError,
        onTap: () => onActionPrompt('Show active manual escalations'),
      ));
    }

    // 5. Predictive Analytics
    if (text.toLowerCase().contains('recur') ||
        text.toLowerCase().contains('repeat') ||
        text.toLowerCase().contains('predict')) {
      chips.add(_actionChip(
        icon: Icons.auto_graph_rounded,
        label: 'Predictive Report',
        color: Colors.amber.shade700,
        onTap: () => onActionPrompt('Show recurring fault nodes'),
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

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
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
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
