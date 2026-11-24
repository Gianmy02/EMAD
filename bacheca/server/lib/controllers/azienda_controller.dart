import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../dao/annuncio_dao.dart';
import '../dao/candidatura_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/error_middleware.dart';
import '../utils/validators.dart';

class AziendaController {
  final AnnuncioDao annunci;
  final CandidaturaDao candidature;

  AziendaController(this.annunci, this.candidature);

  Router get router {
    final r = Router();
    // Rotte protette da token per l'azienda autenticata [Rif. R3, R4, R7]
    r.get('/api/azienda/annunci', guard(_listMyAnnunci));
    r.post('/api/azienda/annunci', guard(_createAnnuncio));
    r.get(
      '/api/azienda/annunci/<id|[0-9]+>/candidature',
      (Request req, String id) =>
          guard((inner) => _listCandidatureForAnnuncio(inner, id))(req),
    );
    return r;
  }

  Response _listMyAnnunci(Request req) {
    final azienda = currentAzienda(req)!;
    final list = annunci.findByAzienda(azienda.id);
    final jsonList = list.map((a) {
      final count = candidature.countForAnnuncio(a.id);
      return a.toJson(numCandidature: count);
    }).toList();

    return jsonResponse({'annunci': jsonList});
  }

  Future<Response> _createAnnuncio(Request req) async {
    final azienda = currentAzienda(req)!;
    final input = validateAnnuncio(await readJsonObject(req));

    final nuovo = await annunci.create(
      aziendaId: azienda.id,
      aziendaNome: azienda.ragioneSociale,
      titolo: input.titolo,
      descrizione: input.descrizione,
      luogo: input.luogo,
      tipoContratto: input.tipoContratto,
      tags: input.tags,
    );

    return jsonResponse({
      'success': true,
      'message': 'Annuncio pubblicato con successo',
      'annuncio': nuovo.toJson(numCandidature: 0),
    }, status: 201);
  }

  Response _listCandidatureForAnnuncio(Request req, String idStr) {
    final azienda = currentAzienda(req)!;
    final id = int.tryParse(idStr);
    final annuncio = id == null ? null : annunci.findById(id);

    if (annuncio == null) {
      throw const ApiException(404, 'Annuncio non trovato');
    }
    if (annuncio.aziendaId != azienda.id) {
      throw const ApiException(403, 'Non hai i permessi per visualizzare le candidature di questo annuncio');
    }

    final list = candidature.findByAnnuncio(annuncio.id);
    return jsonResponse({'candidature': list.map((c) => c.toJson()).toList()});
  }
}
