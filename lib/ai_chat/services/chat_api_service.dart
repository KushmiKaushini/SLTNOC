import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sltnoc/app_config.dart';
import 'package:sltnoc/secure_storage_service.dart';
import '../constants/chat_constants.dart';

class ChatApiService {
  static final ChatApiService _instance = ChatApiService._internal();
  factory ChatApiService() => _instance;
  ChatApiService._internal();

  Map<String, dynamic>? _cachedCriticalAlert;
  DateTime? _criticalAlertLastFetched;

  /// Retrieves list of target API URIs trying the user-configured server first,
  /// then the production Azure fallback.
  Future<List<Uri>> _buildUris(String endpointPath) async {
    final seen = <String>{};
    final List<Uri> uris = [];

    try {
      final storage = SecureStorageService();
      final savedUrl = await storage.getServerUrl();
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        final trimmed = savedUrl.trim();
        if (seen.add(trimmed)) {
          uris.add(Uri.parse('$trimmed$endpointPath'));
        }
      }
    } catch (_) {}

    final fallback = kChatFallbackUrl.trim();
    if (fallback.isNotEmpty && seen.add(fallback)) {
      uris.add(Uri.parse('$fallback$endpointPath'));
    }

    return uris;
  }

  /// Streams token-by-token response for an AI prompt using Server-Sent Events (SSE).
  Future<void> streamChatMessage({
    required String text,
    required List<Map<String, String>> conversationHistory,
    required void Function(String token) onToken,
    required void Function() onComplete,
    required void Function(Object error) onError,
  }) async {
    final uris = await _buildUris('/api/chat-stream');
    Object? lastError;

    for (final uri in uris) {
      http.Client? client;
      try {
        client = http.Client();
        final request = http.Request('POST', uri)
          ..headers['Content-Type'] = 'application/json'
          ..headers['X-API-Key'] = AppConfig.apiKey
          ..body = jsonEncode({
            'message': text,
            'conversationHistory': conversationHistory,
          });

        final response =
            await client.send(request).timeout(kConnectionAttemptTimeout);

        if (response.statusCode == 200) {
          await for (final bytes in response.stream) {
            final chunk = utf8.decode(bytes);
            for (final line in chunk.split('\n')) {
              final trimmed = line.trim();
              if (trimmed.startsWith('data: ')) {
                final data = trimmed.substring(6);
                if (data == '[DONE]') break;
                try {
                  final json = jsonDecode(data) as Map<String, dynamic>;
                  if (json.containsKey('token')) {
                    onToken(json['token'] as String);
                  } else if (json.containsKey('error')) {
                    throw Exception(json['error']);
                  }
                } catch (_) {}
              }
            }
          }
          client.close();
          onComplete();
          return; // Success
        } else {
          client.close();
          throw Exception('HTTP ${response.statusCode}');
        }
      } catch (e) {
        client?.close();
        lastError = e;
        if (kDebugMode) {
          debugPrint('Chat API stream failed for $uri: $e');
        }
      }
    }

    onError(lastError ?? 'All server connections failed.');
  }

  /// Fetches critical network alerts with local in-memory TTL caching.
  Future<Map<String, dynamic>?> fetchCriticalAlerts() async {
    final now = DateTime.now();
    if (_cachedCriticalAlert != null &&
        _criticalAlertLastFetched != null &&
        now.difference(_criticalAlertLastFetched!) < kCriticalAlertCacheTTL) {
      return _cachedCriticalAlert;
    }

    final uris = await _buildUris('/api/critical-alerts');

    for (final uri in uris) {
      try {
        final response = await http.get(
          uri,
          headers: {'X-API-Key': AppConfig.apiKey},
        ).timeout(kConnectionAttemptTimeout);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['alert'] != null) {
            _cachedCriticalAlert = data['alert'] as Map<String, dynamic>;
            _criticalAlertLastFetched = DateTime.now();
            return _cachedCriticalAlert;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Critical alerts fetch failed for $uri: $e');
        }
      }
    }
    return null;
  }
}
