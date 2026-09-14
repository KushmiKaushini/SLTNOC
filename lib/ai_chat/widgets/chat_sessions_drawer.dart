import 'package:flutter/material.dart';
import '../constants/chat_constants.dart';
import '../models/chat_session.dart';

class ChatSessionsDrawer extends StatelessWidget {
  final List<ChatSession> sessions;
  final String activeSessionId;
  final VoidCallback onNewSession;
  final void Function(String id) onSwitchSession;
  final void Function(String id) onDeleteSession;
  final void Function(ChatSession session) onRenameSession;

  const ChatSessionsDrawer({
    Key? key,
    required this.sessions,
    required this.activeSessionId,
    required this.onNewSession,
    required this.onSwitchSession,
    required this.onDeleteSession,
    required this.onRenameSession,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: kChatSurface,
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
                      colors: [kChatAccent1, kChatAccent2],
                    ).createShader(b),
                    child: const Icon(Icons.forum_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Sessions',
                    style: TextStyle(
                      color: kChatText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onNewSession,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kChatAccent1, kChatAccent2],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                    tooltip: 'New session',
                  ),
                ],
              ),
            ),
            const Divider(color: kChatBorder),
            // Session list
            Expanded(
              child: ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (ctx, i) {
                  final session = sessions[i];
                  final isActive = session.id == activeSessionId;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        color: isActive ? kChatAccent1 : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: isActive ? kChatAccent2 : kChatTextTer,
                        size: 20,
                      ),
                      title: Text(
                        session.name,
                        style: TextStyle(
                          color: isActive ? kChatAccent1 : kChatTextSec,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${session.messages.length} messages',
                        style: const TextStyle(color: kChatTextTer, fontSize: 11),
                      ),
                      onTap: () => onSwitchSession(session.id),
                      trailing: PopupMenuButton<String>(
                        color: kChatSurface,
                        icon: const Icon(Icons.more_vert,
                            color: kChatTextTer, size: 18),
                        onSelected: (val) {
                          if (val == 'rename') onRenameSession(session);
                          if (val == 'delete') onDeleteSession(session.id);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(children: [
                              Icon(Icons.edit, color: kChatAccent2, size: 16),
                              SizedBox(width: 8),
                              Text('Rename', style: TextStyle(color: kChatText)),
                            ]),
                          ),
                          if (sessions.length > 1)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete_outline,
                                    color: kChatError, size: 16),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: kChatError)),
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
}
