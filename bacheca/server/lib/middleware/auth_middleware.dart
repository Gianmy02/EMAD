import 'package:shelf/shelf.dart';
import '../dao/azienda_dao.dart';
import '../models/azienda.dart';
import '../services/token_service.dart';
import 'error_middleware.dart';

const String _aziendaKey = 'bacheca.azienda';
const String _tokenKey = 'bacheca.token';

Azienda? currentAzienda(Request request) => request.context[_aziendaKey] as Azienda?;
String? currentToken(Request request) => request.context[_tokenKey] as String?;

Middleware authMiddleware(TokenService tokens, AziendaDao aziende) {
  return (Handler inner) {
    return (Request request) {
      var req = request;
      final header = request.headers['authorization'];
      if (header != null && header.toLowerCase().startsWith('bearer ')) {
        final token = header.substring(7).trim();
        final aziendaId = tokens.aziendaIdFor(token);
        if (aziendaId != null) {
          final az = aziende.findById(aziendaId);
          if (az != null) {
            req = request.change(context: {_aziendaKey: az, _tokenKey: token});
          }
        }
      }
      return inner(req);
    };
  };
}

Handler guard(Handler handler) {
  return (Request request) {
    final azienda = currentAzienda(request);
    if (azienda == null) {
      return jsonError(401, 'Autenticazione richiesta (token non valido o scaduto)');
    }
    return handler(request);
  };
}
