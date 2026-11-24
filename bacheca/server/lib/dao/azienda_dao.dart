import '../errors/api_exception.dart';
import '../models/azienda.dart';
import '../utils/validators.dart';
import 'json_store.dart';

class AziendaDao {
  final JsonCollection _col;

  AziendaDao(this._col);

  Future<void> load() => _col.load();

  bool get needsSeed => !_col.existedOnDisk;

  List<Azienda> all() => _col.all().map(Azienda.fromJson).toList();

  Azienda? findById(int id) {
    for (final m in _col.all()) {
      if (m['id'] == id) return Azienda.fromJson(m);
    }
    return null;
  }

  Azienda? findByEmail(String email) {
    final lower = email.toLowerCase().trim();
    for (final m in _col.all()) {
      if ((m['email'] as String).toLowerCase() == lower) {
        return Azienda.fromJson(m);
      }
    }
    return null;
  }

  bool emailExists(String email) => findByEmail(email) != null;

  Future<Azienda> create({
    required String ragioneSociale,
    required String email,
    required String passwordHash,
    required String salt,
    String settore = '',
    String? createdAt,
  }) async {
    if (emailExists(email)) {
      throw const ApiException(409, 'Un\'azienda con questa email è già registrata');
    }
    final azienda = Azienda(
      id: _col.nextId(),
      ragioneSociale: ragioneSociale,
      email: email,
      settore: settore,
      passwordHash: passwordHash,
      salt: salt,
      createdAt: createdAt ?? formatIsoUtc(DateTime.now()),
    );
    _col.add(azienda.toJson());
    await _col.save();
    return azienda;
  }
}
