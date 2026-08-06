import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sltnoc/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String manualEscalationApiBaseUrl = String.fromEnvironment(
  'MANUAL_ESCALATION_API_BASE_URL',
  defaultValue: 'http://192.168.1.8:3000',
);

const List<String> _fallbackApiBaseUrls = [
  'http://192.168.1.8:3000',
  'http://172.20.10.6:3000',
  'http://192.168.1.7:3000',
  'http://10.16.188.228:3000',
  'http://192.168.1.10:3000',
  manualEscalationApiBaseUrl,
  'http://10.0.2.2:3000',
  'http://127.0.0.1:3000',
];
const Duration _connectionAttemptTimeout = Duration(seconds: 5);

class ManualEscalation {
  final String id;
  final String escalationType;
  final String node;
  final String platform;
  final String severity;
  final String tag;
  final String description;
  final DateTime startAt;
  final String reportingBy;
  final String responsibleOfficer;
  final String status;

  const ManualEscalation({
    required this.id,
    required this.escalationType,
    required this.node,
    required this.platform,
    required this.severity,
    required this.tag,
    required this.description,
    required this.startAt,
    required this.reportingBy,
    required this.responsibleOfficer,
    required this.status,
  });

  factory ManualEscalation.fromJson(Map<String, dynamic> json) {
    return ManualEscalation(
      id: _stringValue(json, const [
        'id',
        '_id',
        'Id',
        'ID',
        'manualEscalationId',
        'manual_escalation_id',
      ]),
      escalationType: (json['escalationType'] ?? '').toString(),
      node: (json['node'] ?? '').toString(),
      platform: (json['platform'] ?? '').toString(),
      severity: (json['severity'] ?? '').toString(),
      tag: (json['tag'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      startAt: DateTime.tryParse((json['startAt'] ?? '').toString()) ??
          DateTime.now(),
      reportingBy: (json['reportingBy'] ?? '').toString(),
      responsibleOfficer: (json['responsibleOfficer'] ?? '').toString(),
      status: (json['status'] ?? 'OPEN').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'escalationType': escalationType,
      'node': node,
      'platform': platform,
      'severity': severity,
      'tag': tag,
      'description': description,
      'startAt': startAt.toIso8601String(),
      'reportingBy': reportingBy,
      'responsibleOfficer': responsibleOfficer,
    };
  }

  int get durationHours {
    final hours = DateTime.now().difference(startAt).inHours;
    return hours < 0 ? 0 : hours;
  }

  static String _stringValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      if (value is Map && value[r'$oid'] != null) {
        final oid = value[r'$oid'].toString().trim();
        if (oid.isNotEmpty) return oid;
        continue;
      }
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}

class ManualEscalationService {
  const ManualEscalationService();

  Future<List<Uri>> _uris(String path) async {
    final seen = <String>{};
    final List<Uri> list = [];

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('serverUrl');
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        final trimmed = savedUrl.trim();
        if (seen.add(trimmed)) {
          list.add(Uri.parse('$trimmed$path'));
        }
      }
    } catch (_) {}

    for (final baseUrl in _fallbackApiBaseUrls) {
      final trimmed = baseUrl.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) continue;
      list.add(Uri.parse('$trimmed$path'));
    }
    return list;
  }

  Future<List<ManualEscalation>> fetchActive() async {
    final response = await _get('/api/manual-escalations');
    if (response.statusCode != 200) {
      throw Exception('Failed to load manual escalations');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => ManualEscalation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> hasActive() async {
    try {
      final response = await _get('/api/manual-escalations/summary');
      if (response.statusCode != 200) {
        return false;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded['hasActive'] == true;
    } on TimeoutException catch (error) {
      if (kDebugMode) {
        debugPrint(
            'Manual escalation badge check failed: Request timeout (${error.duration})');
      }
      return false;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Manual escalation badge check failed: $error');
      }
      return false;
    }
  }

  Future<void> create(ManualEscalation escalation) async {
    final response = await _post(
      '/api/manual-escalations',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(escalation.toJson()),
    );

    if (response.statusCode != 201) {
      String message = 'Failed to create manual escalation';
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        message = (decoded['error'] ?? message).toString();
      } catch (_) {}
      throw Exception(message);
    }
  }

  Future<void> delete(String id) async {
    final encodedId = Uri.encodeComponent(id);
    final response = await _delete('/api/manual-escalations/$encodedId');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = _errorMessage(
        response,
        fallback: 'Failed to delete manual escalation',
      );
      throw Exception(message);
    }
  }

  String _errorMessage(
    http.Response response, {
    required String fallback,
  }) {
    if (response.body.trim().isEmpty) {
      return '$fallback (${response.statusCode})';
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return (decoded['error'] ?? decoded['message'] ?? fallback).toString();
      }
    } catch (_) {}

    return '$fallback (${response.statusCode})';
  }

  Future<http.Response> _get(String path) async {
    Object? lastError;
    final uris = await _uris(path);
    for (final uri in uris) {
      try {
        return await http.get(uri).timeout(_connectionAttemptTimeout);
      } catch (error) {
        lastError = error;
        if (kDebugMode) {
          debugPrint('Manual escalation GET failed for $uri: $error');
        }
      }
    }
    throw ManualEscalationConnectionException(lastError);
  }

  Future<http.Response> _post(
    String path, {
    required Map<String, String> headers,
    required Object body,
  }) async {
    Object? lastError;
    final uris = await _uris(path);
    for (final uri in uris) {
      try {
        return await http
            .post(uri, headers: headers, body: body)
            .timeout(_connectionAttemptTimeout);
      } catch (error) {
        lastError = error;
        if (kDebugMode) {
          debugPrint('Manual escalation POST failed for $uri: $error');
        }
      }
    }
    throw ManualEscalationConnectionException(lastError);
  }

  Future<http.Response> _delete(String path) async {
    Object? lastError;
    http.Response? lastResponse;
    final uris = await _uris(path);
    for (final uri in uris) {
      try {
        final response =
            await http.delete(uri).timeout(_connectionAttemptTimeout);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }
        lastResponse = response;
        if (kDebugMode) {
          debugPrint(
            'Manual escalation DELETE returned ${response.statusCode} for $uri: ${response.body}',
          );
        }
      } catch (error) {
        lastError = error;
        if (kDebugMode) {
          debugPrint('Manual escalation DELETE failed for $uri: $error');
        }
      }
    }
    if (lastResponse != null) {
      return lastResponse;
    }
    throw ManualEscalationConnectionException(lastError);
  }
}

class ManualEscalationConnectionException implements Exception {
  final Object? cause;

  const ManualEscalationConnectionException(this.cause);

  @override
  String toString() {
    return 'Manual escalation server connect wenne naha. '
        'Backend eka run karala phone ekai server ekai same Wi-Fi/network eke '
        'innawada balanna. Current URL: $manualEscalationApiBaseUrl';
  }
}
