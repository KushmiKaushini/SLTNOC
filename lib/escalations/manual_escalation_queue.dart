import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manual_escalation_service.dart';

class ManualEscalationQueue {
  static const String _queueKey = 'pending_manual_escalations';
  static final ManualEscalationQueue _instance =
      ManualEscalationQueue._internal();
  factory ManualEscalationQueue() => _instance;
  ManualEscalationQueue._internal();

  /// Load the queue from SharedPreferences.
  Future<List<ManualEscalation>> loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonStrings = prefs.getStringList(_queueKey);
    if (jsonStrings == null || jsonStrings.isEmpty) {
      return [];
    }
    return jsonStrings
        .map((jsonString) => ManualEscalation.fromJson(
            jsonDecode(jsonString) as Map<String, dynamic>))
        .toList();
  }

  /// Save the queue to SharedPreferences.
  Future<void> saveQueue(List<ManualEscalation> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonStrings = queue
        .map((esc) => jsonEncode(esc.toJson()))
        .toList();
    await prefs.setStringList(_queueKey, jsonStrings);
  }

  /// Add an escalation to the queue.
  Future<void> addToQueue(ManualEscalation escalation) async {
    final List<ManualEscalation> current = await loadQueue();
    current.add(escalation);
    await saveQueue(current);
  }

  /// Process the queue: attempt to send each pending escalation.
  /// Returns the number of successfully sent escalations.
  Future<int> processQueue() async {
    final List<ManualEscalation> queue = await loadQueue();
    if (queue.isEmpty) return 0;

    final List<ManualEscalation> remaining = [];
    int sentCount = 0;

    for (final escalation in queue) {
      try {
        await ManualEscalationService().create(escalation);
        sentCount++;
      } catch (e) {
        // Keep in queue for later retry
        remaining.add(escalation);
        // Optionally log the error
        if (kDebugMode) {
          print('Failed to send queued escalation: $e');
        }
      }
    }

    // Save back the remaining (failed) escalations
    await saveQueue(remaining);
    return sentCount;
  }
}