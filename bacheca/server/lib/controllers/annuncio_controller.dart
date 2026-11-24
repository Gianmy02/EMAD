import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../dao/annuncio_dao.dart';
import '../dao/candidatura_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/error_middleware.dart';

class AnnuncioController {
  final AnnuncioDao annunci;
  final CandidaturaDao candidature;

  AnnuncioController(this.annunci, this.candidature);

  Router get router {
    final r = Router();
    r.get('/api/annunci', _list);
    r.get('/api/annunci/<id|[0-9]+>', _get);
    return r;
  }

  Response _list(Request req) {
    final qp = req.url.queryParameters;
    final aziendaId = int.tryParse(qp['azienda_id'] ?? qp['aziendaId'] ?? '');
    final result = annunci.search(q: qp['q'], aziendaId: aziendaId);

    final listJson = result.map((a) {
      final count = candidature.countForAnnuncio(a.id);
      return a.toJson(numCandidature: count);
    }).toList();

    return jsonResponse({'annunci': listJson});
  }

  Response _get(Request req, String idStr) {
    final id = int.tryParse(idStr);
    final a = id == null ? null : annunci.findById(id);
    if (a == null) {
      throw const ApiException(404, 'Annuncio non trovato');
    }
    final count = candidature.countForAnnuncio(a.id);
    return jsonResponse({'annuncio': a.toJson(numCandidature: count)});
  }
}
