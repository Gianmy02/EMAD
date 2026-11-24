import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final int statusCode; // 0 = errore di rete
  final String message;
  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

const String _networkMessage =
    'Impossibile contattare il server. Controlla che sia avviato e che l\'indirizzo sia corretto.';

class ApiClient {
  final http.Client _client = http.Client();

  /// Token Bearer corrente (null = ospite / candidato).
  String? token;

  /// Chiamato su 401 quando c'è una sessione attiva (logout locale).
  void Function()? onUnauthorized;

  Future<dynamic> get(String path, {Map<String, String?>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, {Object? body}) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String?>? query,
    Object? body,
  }) async {
    var uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (query != null) {
      final q = <String, String>{};
      query.forEach((k, v) {
        if (v != null && v.isNotEmpty) q[k] = v;
      });
      if (q.isNotEmpty) uri = uri.replace(queryParameters: q);
    }

    final req = http.Request(method, uri);
    req.headers['Accept'] = 'application/json';
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      req.headers['Content-Type'] = 'application/json; charset=utf-8';
      req.body = jsonEncode(body);
    }

    http.Response res;
    try {
      final streamed = await _client.send(req).timeout(ApiConfig.timeout);
      res = await http.Response.fromStream(streamed).timeout(ApiConfig.timeout);
    } on TimeoutException {
      throw const ApiException(0, _networkMessage);
    } on SocketException {
      throw const ApiException(0, _networkMessage);
    } on http.ClientException {
      throw const ApiException(0, _networkMessage);
    }

    dynamic data;
    final text = utf8.decode(res.bodyBytes, allowMalformed: true);
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } catch (_) {
        data = null;
      }
    }

    if (res.statusCode >= 400) {
      var msg = 'Errore del server (${res.statusCode})';
      if (data is Map && data['error'] is String) {
        msg = data['error'] as String;
      }
      if (res.statusCode == 401 && token != null) onUnauthorized?.call();
      throw ApiException(res.statusCode, msg);
    }
    return data;
  }
}
