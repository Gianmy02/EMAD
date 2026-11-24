import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../dao/azienda_dao.dart';
import '../errors/api_exception.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/error_middleware.dart';
import '../services/password_service.dart';
import '../services/token_service.dart';
import '../utils/validators.dart';

class AuthController {
  final AziendaDao aziende;
  final TokenService tokens;

  AuthController(this.aziende, this.tokens);

  Router get router {
    final r = Router();
    r.post('/api/auth/register', _register);
    r.post('/api/auth/login', _login);
    r.post('/api/auth/logout', guard(_logout));
    r.get('/api/auth/me', guard(_me));
    return r;
  }

  Future<Response> _register(Request req) async {
    final input = validateRegister(await readJsonObject(req));
    final salt = PasswordService.generateSalt();
    final azienda = await aziende.create(
      ragioneSociale: input.ragioneSociale,
      email: input.email,
      passwordHash: PasswordService.hash(input.password, salt),
      salt: salt,
      settore: input.settore,
    );
    final token = tokens.issue(azienda.id);
    return jsonResponse({'token': token, 'azienda': azienda.toPublicJson()}, status: 201);
  }

  Future<Response> _login(Request req) async {
    final body = await readJsonObject(req);
    final email = body['email'];
    final password = body['password'];
    if (email is! String || password is! String) {
      throw const ApiException(422, 'Email e password obbligatori');
    }
    final azienda = aziende.findByEmail(email);
    final ok = azienda != null &&
        PasswordService.verify(password, azienda.salt, azienda.passwordHash);
    if (!ok) throw const ApiException(401, 'Credenziali non valide');

    final token = tokens.issue(azienda.id);
    return jsonResponse({'token': token, 'azienda': azienda.toPublicJson()});
  }

  Response _logout(Request req) {
    final token = currentToken(req);
    if (token != null) tokens.revoke(token);
    return Response(204);
  }

  Response _me(Request req) => jsonResponse(currentAzienda(req)!.toPublicJson());
}
