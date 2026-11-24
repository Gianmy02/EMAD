import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  const port = 8085;
  const baseUrl = 'http://127.0.0.1:$port';
  late Process p;

  setUpAll(() async {
    // Pulisce la cartella di test
    final testDir = Directory('test_data');
    if (await testDir.exists()) await testDir.delete(recursive: true);

    p = await Process.start(
      'dart',
      ['run', 'bin/server.dart'],
      environment: {
        'PORT': '$port',
        'DATA_DIR': 'test_data/data',
        'UPLOADS_DIR': 'test_data/uploads',
      },
    );

    // Attende l'avvio del server
    await for (final line in p.stdout.transform(utf8.decoder).transform(const LineSplitter())) {
      if (line.contains('avviato')) break;
    }
  });

  tearDownAll(() async {
    p.kill();
    final testDir = Directory('server/test_data');
    if (await testDir.exists()) await testDir.delete(recursive: true);
  });

  test('Health check', () async {
    final res = await http.get(Uri.parse('$baseUrl/api/health'));
    expect(res.statusCode, 200);
    expect(jsonDecode(res.body)['status'], 'ok');
  });

  test('S1: Registrazione e Login Azienda + Pubblicazione Annuncio', () async {
    // 1. Registrazione
    final regRes = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'ragioneSociale': 'Acme Corp S.r.l.',
        'email': 'contatti@acme.it',
        'password': 'passwordSegreta123',
        'settore': 'Telecomunicazioni',
      }),
    );
    expect(regRes.statusCode, 201);
    final regJson = jsonDecode(regRes.body);
    final token = regJson['token'] as String;
    expect(token, isNotEmpty);

    // 2. Pubblicazione Annuncio
    final pubRes = await http.post(
      Uri.parse('$baseUrl/api/azienda/annunci'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'titolo': 'Ingegnere del Software Mobile',
        'descrizione': 'Sviluppo di applicazioni enterprise in Flutter e Dart.',
        'luogo': 'Napoli / Remoto',
        'tipoContratto': 'Tempo indeterminato',
        'tags': 'Flutter, Dart, Shelf',
      }),
    );
    expect(pubRes.statusCode, 201);
    final pubJson = jsonDecode(pubRes.body);
    final annuncioId = pubJson['annuncio']['id'] as int;

    // S2: Consultazione bacheca e candidatura
    final bachecaRes = await http.get(Uri.parse('$baseUrl/api/annunci'));
    expect(bachecaRes.statusCode, 200);
    final annunciList = jsonDecode(bachecaRes.body)['annunci'] as List;
    expect(annunciList.any((a) => a['id'] == annuncioId), isTrue);

    // Candidatura con CV in Base64
    final cvContent = 'Contenuto del Curriculum di Prova';
    final cvBase64 = base64Encode(utf8.encode(cvContent));
    final candRes = await http.post(
      Uri.parse('$baseUrl/api/annunci/$annuncioId/candidature'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'nome': 'Giovanni',
        'cognome': 'Bianchi',
        'email': 'giovanni.bianchi@email.it',
        'messaggio': 'Candidatura per posizione Flutter',
        'cvOriginalName': 'CV_Giovanni_Bianchi.pdf',
        'cvBase64': cvBase64,
      }),
    );
    expect(candRes.statusCode, 201);
    final candJson = jsonDecode(candRes.body);
    final cvFilename = candJson['candidatura']['cvFilename'] as String;

    // S3: Consultazione candidature da parte dell'azienda e download CV
    final candListRes = await http.get(
      Uri.parse('$baseUrl/api/azienda/annunci/$annuncioId/candidature'),
      headers: {'authorization': 'Bearer $token'},
    );
    expect(candListRes.statusCode, 200);
    final cands = jsonDecode(candListRes.body)['candidature'] as List;
    expect(cands.length, 1);
    expect(cands.first['nome'], 'Giovanni');

    // Verifica download del file CV
    final downloadRes = await http.get(Uri.parse('$baseUrl/api/uploads/$cvFilename'));
    expect(downloadRes.statusCode, 200);
    expect(downloadRes.body, cvContent);
  });
}
