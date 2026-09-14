import 'package:flutter/material.dart';
import '../constants/chat_constants.dart';

class ChatWelcomeScreen extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String prompt) onSelectPrompt;

  const ChatWelcomeScreen({
    Key? key,
    this.suggestions = kSuggestedPrompts,
    required this.onSelectPrompt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    colors: [kChatAccent1, kChatAccent2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kChatAccent1.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 4,
                    )
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Image.asset('assets/chatbot-icon.webp', fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [kChatAccent1, kChatAccent2],
                ).createShader(b),
                child: const Text(
                  'NOC AI Assistant',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kChatText,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ask me about network nodes, alarms, escalations, or system insights.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kChatTextSec, height: 1.5),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: suggestions.map((p) {
                  return GestureDetector(
                    onTap: () => onSelectPrompt(p),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: kChatGlass,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kChatBorder),
                      ),
                      child: Text(
                        p,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kChatAccent2,
                          fontWeight: FontWeight.w500,
                        ),
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
}
