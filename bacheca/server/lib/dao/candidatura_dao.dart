import '../models/candidatura.dart';
import '../utils/validators.dart';
import 'json_store.dart';

class CandidaturaDao {
  final JsonCollection _col;

  CandidaturaDao(this._col);

  Future<void> load() => _col.load();

  bool get needsSeed => !_col.existedOnDisk;

  List<Candidatura> all() => _col.all().map(Candidatura.fromJson).toList();

  Candidatura? findById(int id) {
    for (final m in _col.all()) {
      if (m['id'] == id) return Candidatura.fromJson(m);
    }
    return null;
  }

  List<Candidatura> findByAnnuncio(int annuncioId) {
    final list = <Candidatura>[];
    for (final m in _col.all()) {
      if (m['annuncioId'] == annuncioId) {
        list.add(Candidatura.fromJson(m));
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int countForAnnuncio(int annuncioId) {
    var count = 0;
    for (final m in _col.all()) {
      if (m['annuncioId'] == annuncioId) count++;
    }
    return count;
  }

  Future<Candidatura> create({
    required int annuncioId,
    required String annuncioTitolo,
    required String nome,
    required String cognome,
    required String email,
    String messaggio = '',
    required String cvFilename,
    required String cvOriginalName,
    String? createdAt,
  }) async {
    final cand = Candidatura(
      id: _col.nextId(),
      annuncioId: annuncioId,
      annuncioTitolo: annuncioTitolo,
      nome: nome,
      cognome: cognome,
      email: email,
      messaggio: messaggio,
      cvFilename: cvFilename,
      cvOriginalName: cvOriginalName,
      createdAt: createdAt ?? formatIsoUtc(DateTime.now()),
    );
    _col.add(cand.toJson());
    await _col.save();
    return cand;
  }
}
