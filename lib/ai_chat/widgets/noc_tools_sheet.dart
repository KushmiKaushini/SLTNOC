import 'package:flutter/material.dart';
import '../constants/chat_constants.dart';

class NocToolsSheet {
  static void show({
    required BuildContext context,
    required void Function(String prompt) onSelectPrompt,
    required void Function(String snippet) onInsertLogSnippet,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kChatSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '🛠️ NOC AI Assistant Tools',
                  style: TextStyle(
                    color: kChatText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select a tool preset or attach data to analyze.',
                  style: TextStyle(color: kChatTextSec, fontSize: 12),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.2,
                  children: [
                    _toolCard(
                      icon: Icons.auto_graph_rounded,
                      color: Colors.amber.shade700,
                      title: 'Predict Faults',
                      subtitle: 'Recurring node report',
                      onTap: () {
                        Navigator.pop(ctx);
                        onSelectPrompt(
                            'Show recurring and high-risk fault nodes');
                      },
                    ),
                    _toolCard(
                      icon: Icons.assignment_late_rounded,
                      color: kChatError,
                      title: 'Escalations',
                      subtitle: 'Active escalation list',
                      onTap: () {
                        Navigator.pop(ctx);
                        onSelectPrompt('Show active manual escalations');
                      },
                    ),
                    _toolCard(
                      icon: Icons.pie_chart_rounded,
                      color: kChatAccent2,
                      title: 'Alarm Matrix',
                      subtitle: 'Provinces summary',
                      onTap: () {
                        Navigator.pop(ctx);
                        onSelectPrompt('Show general alarms summary');
                      },
                    ),
                    _toolCard(
                      icon: Icons.receipt_long_rounded,
                      color: kChatGreen,
                      title: 'Log Analysis',
                      subtitle: 'Insert syslog sample',
                      onTap: () {
                        Navigator.pop(ctx);
                        onInsertLogSnippet(
                          'SYS_LOG: Colombo_MSAN_02 Port Ethernet 0/1 Link Down. Duration 4.5h. Analyze root cause.',
                        );
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

  static Widget _toolCard({
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
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kChatTextSec, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
