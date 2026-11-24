import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../dao/annuncio_dao.dart';
import '../dao/candidatura_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/error_middleware.dart';
import '../utils/validators.dart';

class CandidaturaController {
  final CandidaturaDao candidature;
  final AnnuncioDao annunci;
  final String uploadDir;

  CandidaturaController(this.candidature, this.annunci, this.uploadDir);

  Router get router {
    final r = Router();
    r.post('/api/annunci/<id|[0-9]+>/candidature', _submit);
    r.get('/api/uploads/<filename>', _serveUpload);
    return r;
  }

  Future<Response> _submit(Request req, String idStr) async {
    final annuncioId = int.tryParse(idStr);
    final annuncio = annuncioId == null ? null : annunci.findById(annuncioId);
    if (annuncio == null) {
      throw const ApiException(404, 'Annuncio specificato non trovato');
    }

    final body = await readJsonObject(req);
    final nome = (body['nome'] as String?)?.trim() ?? '';
    final cognome = (body['cognome'] as String?)?.trim() ?? '';
    final email = (body['email'] as String?)?.trim() ?? '';
    final messaggio = (body['messaggio'] as String?)?.trim() ?? '';
    final cvOriginalName = (body['cvOriginalName'] ?? body['cv_original_name'] as String?)?.trim() ?? 'curriculum.pdf';
    final cvBase64 = (body['cvBase64'] ?? body['cv_base64'] as String?)?.trim();

    if (nome.isEmpty) throw const ApiException(422, 'Nome obbligatorio');
    if (cognome.isEmpty) throw const ApiException(422, 'Cognome obbligatorio');
    if (email.isEmpty || !emailRe.hasMatch(email)) {
      throw const ApiException(422, 'Email non valida');
    }
    if (cvBase64 == null || cvBase64.isEmpty) {
      throw const ApiException(422, 'Curriculum Vitae obbligatorio (file mancante)');
    }

    // Salva il file su disco in uploads/
    final ext = cvOriginalName.contains('.') ? cvOriginalName.substring(cvOriginalName.lastIndexOf('.')) : '.pdf';
    final randomSuffix = Random().nextInt(999999).toString().padLeft(6, '0');
    final savedFilename = 'cv_${DateTime.now().millisecondsSinceEpoch}_$randomSuffix$ext';
    final destFile = File('$uploadDir/$savedFilename');
    await destFile.parent.create(recursive: true);

    try {
      final bytes = base64Decode(cvBase64);
      await destFile.writeAsBytes(bytes, flush: true);
    } catch (_) {
      throw const ApiException(400, 'Codifica del file curriculum non valida');
    }

    final cand = await candidature.create(
      annuncioId: annuncio.id,
      annuncioTitolo: annuncio.titolo,
      nome: nome,
      cognome: cognome,
      email: email,
      messaggio: messaggio,
      cvFilename: savedFilename,
      cvOriginalName: cvOriginalName,
    );

    return jsonResponse({
      'success': true,
      'message': 'Candidatura inviata con successo!',
      'candidatura': cand.toJson(),
    }, status: 201);
  }

  Future<Response> _serveUpload(Request req, String filename) async {
    final sanitized = filename.replaceAll('..', '').replaceAll('/', '').replaceAll('\\', '');
    final file = File('$uploadDir/$sanitized');
    if (!await file.exists()) {
      return jsonError(404, 'File non trovato');
    }
    final bytes = await file.readAsBytes();
    String contentType = 'application/octet-stream';
    if (sanitized.endsWith('.pdf')) {
      contentType = 'application/pdf';
    } else if (sanitized.endsWith('.txt')) {
      contentType = 'text/plain; charset=utf-8';
    }

    return Response.ok(bytes, headers: {
      'content-type': contentType,
      'content-disposition': 'inline; filename="$sanitized"',
      'Access-Control-Allow-Origin': '*',
    });
  }
}
