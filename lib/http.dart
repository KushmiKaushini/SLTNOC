import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

export 'package:http/http.dart';

const String _trustedHost = 'fmt.slt.com.lk';
const String _trustedCaAssetPath = 'assets/certs/slt_ca.crt';
const Duration _requestTimeout = Duration(seconds: 15);

http.Client? _defaultClient;
http.Client? _trustedClient;

http.Client _getDefaultClient() {
  return _defaultClient ??= http.Client();
}

Future<http.Client> _getTrustedClient() async {
  if (_trustedClient != null) {
    return _trustedClient!;
  }

  try {
    final ByteData data = await rootBundle.load(_trustedCaAssetPath);
    final SecurityContext context = SecurityContext(withTrustedRoots: true);
    context.setTrustedCertificatesBytes(data.buffer.asUint8List());

    final HttpClient ioClient = HttpClient(context: context);
    _trustedClient = IOClient(ioClient);
  } catch (error) {
    if (kDebugMode) {
      debugPrint('Failed to load trusted CA: $error');
    }
    _trustedClient = _getDefaultClient();
  }

  return _trustedClient!;
}

Future<http.Client> _clientFor(Uri url) async {
  if (url.host == _trustedHost) {
    return _getTrustedClient();
  }

  return _getDefaultClient();
}

Future<http.Response> get(
  Uri url, {
  Map<String, String>? headers,
}) async {
  final http.Client client = await _clientFor(url);
  return client.get(url, headers: headers).timeout(_requestTimeout);
}

Future<http.Response> post(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final http.Client client = await _clientFor(url);
  return client
      .post(url, headers: headers, body: body, encoding: encoding)
      .timeout(_requestTimeout);
}
