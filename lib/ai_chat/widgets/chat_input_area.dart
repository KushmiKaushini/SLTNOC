import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/chat_constants.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;
  final bool isLoading;
  final bool isStreaming;
  final bool isSpeechAvailable;
  final bool isListening;
  final VoidCallback onCancelEdit;
  final VoidCallback onOpenNocTools;
  final VoidCallback onToggleSpeech;
  final VoidCallback onSendMessage;

  const ChatInputArea({
    Key? key,
    required this.controller,
    required this.isEditing,
    required this.isLoading,
    required this.isStreaming,
    required this.isSpeechAvailable,
    required this.isListening,
    required this.onCancelEdit,
    required this.onOpenNocTools,
    required this.onToggleSpeech,
    required this.onSendMessage,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final canSend = controller.text.trim().isNotEmpty && !isLoading && !isStreaming;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          decoration: BoxDecoration(
            color: kChatSurface.withValues(alpha: 0.9),
            border: const Border(top: BorderSide(color: kChatBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Editing banner
              if (isEditing)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kChatAccent2.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kChatAccent2.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded,
                          size: 14, color: kChatAccent2),
                      const SizedBox(width: 6),
                      const Text(
                        'Editing message',
                        style: TextStyle(color: kChatAccent2, fontSize: 12),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onCancelEdit,
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: Colors.white38),
                      ),
                    ],
                  ),
                ),

              // Input Row
              Row(
                children: [
                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: kChatGlass,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isEditing
                              ? kChatAccent2.withValues(alpha: 0.5)
                              : kChatBorder,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: kChatText, fontSize: 14),
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: isEditing
                              ? 'Edit your message…'
                              : 'Ask the NOC AI…',
                          hintStyle:
                              const TextStyle(color: kChatTextTer, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => onSendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // NOC Tools Preset button
                  _circleButton(
                    onTap: onOpenNocTools,
                    icon: Icons.grid_view_rounded,
                    color: kChatAccent2,
                    bgColor: kChatGlass,
                    border: const BorderSide(color: kChatBorder),
                  ),
                  const SizedBox(width: 6),

                  // Speech Mic button
                  if (isSpeechAvailable) ...[
                    _circleButton(
                      onTap: isLoading || isStreaming ? null : onToggleSpeech,
                      icon: isListening
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      color: isListening ? kChatError : Colors.black54,
                      bgColor: isListening
                          ? kChatError.withValues(alpha: 0.15)
                          : kChatGlass,
                      border: isListening
                          ? BorderSide(color: kChatError.withValues(alpha: 0.4))
                          : const BorderSide(color: kChatBorder),
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Send button
                  GestureDetector(
                    onTap: canSend ? onSendMessage : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: canSend
                            ? const LinearGradient(
                                colors: [kChatAccent1, kChatAccent2],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: canSend ? null : kChatGlass,
                        border: Border.all(color: kChatBorder),
                        boxShadow: canSend
                            ? [
                                BoxShadow(
                                  color: kChatAccent1.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        isEditing ? Icons.check_rounded : Icons.send_rounded,
                        size: 18,
                        color: canSend ? Colors.white : kChatTextTer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
