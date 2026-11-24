import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'package:bacheca_server/controllers/annuncio_controller.dart';
import 'package:bacheca_server/controllers/auth_controller.dart';
import 'package:bacheca_server/controllers/azienda_controller.dart';
import 'package:bacheca_server/controllers/candidatura_controller.dart';
import 'package:bacheca_server/dao/annuncio_dao.dart';
import 'package:bacheca_server/dao/azienda_dao.dart';
import 'package:bacheca_server/dao/candidatura_dao.dart';
import 'package:bacheca_server/dao/json_store.dart';
import 'package:bacheca_server/middleware/auth_middleware.dart';
import 'package:bacheca_server/middleware/cors_middleware.dart';
import 'package:bacheca_server/middleware/error_middleware.dart';
import 'package:bacheca_server/services/seeder.dart';
import 'package:bacheca_server/services/token_service.dart';

Future<void> main() async {
  final dataDir = Platform.environment['DATA_DIR'] ?? 'data';
  final uploadsDir = Platform.environment['UPLOADS_DIR'] ?? 'uploads';
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;

  await Directory(dataDir).create(recursive: true);
  await Directory(uploadsDir).create(recursive: true);

  // DAO con persistenza su file JSON (identico all'esempio didattico)
  final aziendaDao = AziendaDao(JsonCollection('$dataDir/aziende.json'));
  final annuncioDao = AnnuncioDao(JsonCollection('$dataDir/annunci.json'));
  final candidaturaDao = CandidaturaDao(JsonCollection('$dataDir/candidature.json'));

  await aziendaDao.load();
  await annuncioDao.load();
  await candidaturaDao.load();

  await Seeder.run(
    aziende: aziendaDao,
    annunci: annuncioDao,
    candidature: candidaturaDao,
  );

  final tokens = TokenService();

  final health = Router()
    ..get('/api/health', (Request req) => jsonResponse({'status': 'ok'}));

  final api = Cascade()
      .add(health.call)
      .add(AuthController(aziendaDao, tokens).router.call)
      .add(AnnuncioController(annuncioDao, candidaturaDao).router.call)
      .add(CandidaturaController(candidaturaDao, annuncioDao, uploadsDir).router.call)
      .add(AziendaController(annuncioDao, candidaturaDao).router.call)
      .add((Request req) => jsonError(404, 'Risorsa non trovata'))
      .handler;

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addMiddleware(errorMiddleware())
      .addMiddleware(authMiddleware(tokens, aziendaDao))
      .addHandler(api);

  final server = await io.serve(handler, InternetAddress.anyIPv4, port);
  stdout.writeln('====================================================');
  stdout.writeln('Bacheca Annunci Backend (Dart/Shelf) avviato!');
  stdout.writeln('In ascolto su: http://127.0.0.1:${server.port}');
  stdout.writeln('====================================================');
}
