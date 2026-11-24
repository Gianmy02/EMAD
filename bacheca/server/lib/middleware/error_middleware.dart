import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import '../errors/api_exception.dart';

const Map<String, String> _jsonHeaders = {
  'content-type': 'application/json; charset=utf-8',
};

Response jsonResponse(Object? body, {int status = 200}) =>
    Response(status, body: jsonEncode(body), headers: _jsonHeaders);

Response jsonError(int status, String message) =>
    jsonResponse({'error': message, 'success': false}, status: status);

Middleware errorMiddleware() {
  return (Handler inner) {
    return (Request request) async {
      try {
        return await inner(request);
      } on ApiException catch (e) {
        return jsonError(e.status, e.message);
      } on FormatException catch (e) {
        return jsonError(400, 'JSON non valido: ${e.message}');
      } catch (e, st) {
        stderr.writeln('Errore interno (${e.runtimeType}): $st');
        return jsonError(500, 'Errore interno del server');
      }
    };
  };
}
