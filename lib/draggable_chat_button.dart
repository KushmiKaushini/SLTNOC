import 'package:flutter/material.dart';
import 'ai_chat_page.dart';
import 'main.dart';

class DraggableChatButton extends StatefulWidget {
  const DraggableChatButton({Key? key}) : super(key: key);

  @override
  State<DraggableChatButton> createState() => _DraggableChatButtonState();
}

class _DraggableChatButtonState extends State<DraggableChatButton>
    with SingleTickerProviderStateMixin {
  double _xPos = -1;
  double _yPos = -1;
  bool _initialized = false;
  bool _isDragging = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openChat(BuildContext context) {
    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const AIChatPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Set initial position to bottom-right corner on first build
    if (!_initialized) {
      _xPos = size.width - 75;
      _yPos = size.height - 150;
      _initialized = true;
    }

    return Positioned(
      left: _xPos,
      top: _yPos,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          setState(() {
            _xPos += details.delta.dx;
            _yPos += details.delta.dy;

            // Clamp to screen bounds
            _xPos = _xPos.clamp(0.0, size.width - 60);
            _yPos = _yPos.clamp(0.0, size.height - 60);
          });
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
            // Snap to nearest vertical edge
            if (_xPos > size.width / 2) {
              _xPos = size.width - 68;
            } else {
              _xPos = 8;
            }
          });
        },
        onTap: () => _openChat(context),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isDragging ? 1.15 : _pulseAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0288D1), Color(0xFF0056A2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0288D1).withValues(alpha: 0.5),
                  blurRadius: _isDragging ? 20 : 12,
                  spreadRadius: _isDragging ? 4 : 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Chatbot icon
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/chatbot-icon.webp',
                    fit: BoxFit.contain,
                  ),
                ),
                // Online indicator dot
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
