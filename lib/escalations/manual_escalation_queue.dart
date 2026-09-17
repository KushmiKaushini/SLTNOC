import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sltnoc/secure_storage_service.dart';
import 'manual_escalation_service.dart';

class ManualEscalationQueue {
  static const String _queueKey = 'pending_manual_escalations';
  static final ManualEscalationQueue _instance =
      ManualEscalationQueue._internal();
  factory ManualEscalationQueue() => _instance;
  ManualEscalationQueue._internal();

  /// Load the queue from secure storage.
  Future<List<ManualEscalation>> loadQueue() async {
    final storage = SecureStorageService();
    final jsonString = await storage.read(_queueKey);
    if (jsonString == null) {
      return [];
    }
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded
        .map((e) => ManualEscalation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Save the queue to secure storage.
  Future<void> saveQueue(List<ManualEscalation> queue) async {
    final storage = SecureStorageService();
    final List<Map<String, dynamic>> jsonObjects =
        queue.map((esc) => esc.toJson()).toList();
    final jsonString = jsonEncode(jsonObjects);
    await storage.write(_queueKey, jsonString);
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
          debugPrint('Failed to send queued escalation: $e');
        }
      }
    }

    // Save back the remaining (failed) escalations
    await saveQueue(remaining);
    return sentCount;
  }
}