import 'package:flutter/material.dart';

class CriticalAlertBanner extends StatelessWidget {
  final Map<String, dynamic>? alertData;
  final bool isDismissed;
  final void Function(String prompt) onInspect;
  final VoidCallback onDismiss;

  const CriticalAlertBanner({
    Key? key,
    required this.alertData,
    required this.isDismissed,
    required this.onInspect,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isDismissed ||
        alertData == null ||
        alertData!['hasCriticalAlert'] != true) {
      return const SizedBox.shrink();
    }
    final alarmsCount = alertData!['totalOpenAlarms'] ?? 0;
    final topProvince = alertData!['topProvince'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x33EF4444), Color(0x22F97316)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🚨 Critical Outage Alert',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '$alarmsCount active faults detected ($topProvince Province peak)',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                onInspect('Show open alarms in $topProvince province'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Inspect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded,
                color: Colors.white38, size: 18),
          ),
        ],
      ),
    );
  }
}
