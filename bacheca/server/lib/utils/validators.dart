import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../errors/api_exception.dart';

final RegExp emailRe = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

/// Data ISO-8601 UTC: 2026-11-01T10:00:00Z.
String formatIsoUtc(DateTime d) {
  final u = d.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)}'
      'T${two(u.hour)}:${two(u.minute)}:${two(u.second)}Z';
}

/// Legge il body come oggetto JSON; JSON non valido o non-oggetto -> FormatException (400).
Future<Map<String, dynamic>> readJsonObject(Request request) async {
  final text = await request.readAsString();
  if (text.trim().isEmpty) return <String, dynamic>{};
  final decoded = jsonDecode(text);
  if (decoded is! Map) {
    throw const FormatException('Il corpo deve essere un oggetto JSON');
  }
  return Map<String, dynamic>.from(decoded);
}

({String ragioneSociale, String email, String password, String settore}) validateRegister(
    Map<String, dynamic> b) {
  final ragioneSociale = b['ragioneSociale'] ?? b['ragione_sociale'];
  final email = b['email'];
  final password = b['password'];
  final settore = b['settore'] as String? ?? '';

  if (ragioneSociale is! String || ragioneSociale.trim().isEmpty) {
    throw const ApiException(422, 'Ragione Sociale obbligatoria');
  }
  if (email is! String || !emailRe.hasMatch(email.trim())) {
    throw const ApiException(422, 'Email aziendale non valida');
  }
  if (password is! String || password.length < 6) {
    throw const ApiException(422, 'Password obbligatoria (almeno 6 caratteri)');
  }

  return (
    ragioneSociale: ragioneSociale.trim(),
    email: email.trim().toLowerCase(),
    password: password,
    settore: settore.trim(),
  );
}

({String titolo, String descrizione, String luogo, String tipoContratto, String tags}) validateAnnuncio(
    Map<String, dynamic> b) {
  final titolo = b['titolo'];
  final descrizione = b['descrizione'];
  final luogo = b['luogo'] as String? ?? 'Ibrido / Da definire';
  final tipoContratto = b['tipoContratto'] ?? b['tipo_contratto'] ?? 'Tempo indeterminato';
  final tags = b['tags'] as String? ?? '';

  if (titolo is! String || titolo.trim().isEmpty) {
    throw const ApiException(422, 'Titolo annuncio obbligatorio');
  }
  if (descrizione is! String || descrizione.trim().isEmpty) {
    throw const ApiException(422, 'Descrizione annuncio obbligatoria');
  }

  return (
    titolo: titolo.trim(),
    descrizione: descrizione.trim(),
    luogo: luogo.toString().trim(),
    tipoContratto: tipoContratto.toString().trim(),
    tags: tags.trim(),
  );
}
