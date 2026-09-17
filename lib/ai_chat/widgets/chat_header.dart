import 'package:flutter/material.dart';
import '../constants/chat_constants.dart';

class ChatHeader extends StatelessWidget {
  final String title;
  final bool isStreaming;
  final bool hasMessages;
  final Animation<double> glowAnim;
  final VoidCallback onOpenDrawer;
  final VoidCallback onExportChat;
  final VoidCallback onClearHistory;
  final VoidCallback onOpenSettings;
  final VoidCallback onClose;

  const ChatHeader({
    Key? key,
    required this.title,
    required this.isStreaming,
    required this.hasMessages,
    required this.glowAnim,
    required this.onOpenDrawer,
    required this.onExportChat,
    required this.onClearHistory,
    required this.onOpenSettings,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (ctx, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kChatSurface,
          border: Border(
            bottom: BorderSide(
              color: Color.lerp(kChatAccent1, kChatAccent2, glowAnim.value)!
                  .withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: kChatAccent1.withValues(alpha: 0.15 * glowAnim.value),
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
          IconButton(
            onPressed: onOpenDrawer,
            icon: const Icon(Icons.menu_rounded, color: kChatTextSec, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Sessions',
          ),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kChatAccent1, kChatAccent2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kChatAccent1.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset('assets/chatbot-icon.webp', fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kChatText,
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
                        color: kChatGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        isStreaming ? 'Streaming response...' : 'Online',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isStreaming ? kChatAccent2 : kChatGreen,
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
          if (hasMessages)
            IconButton(
              onPressed: onExportChat,
              icon: const Icon(Icons.ios_share_rounded,
                  size: 20, color: kChatTextSec),
              tooltip: 'Export chat',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          const SizedBox(width: 4),
          // Clear button
          if (hasMessages)
            GestureDetector(
              onTap: onClearHistory,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kChatGlass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kChatBorder),
                ),
                child: const Text('Clear',
                    style: TextStyle(color: kChatTextSec, fontSize: 12)),
              ),
            ),
          const SizedBox(width: 6),
          // Settings
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.wifi_tethering_rounded,
                size: 20, color: kChatTextSec),
            tooltip: 'Server',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // Close
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 20, color: kChatTextTer),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
