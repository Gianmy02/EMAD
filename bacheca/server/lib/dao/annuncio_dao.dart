import '../models/annuncio.dart';
import '../utils/validators.dart';
import 'json_store.dart';

class AnnuncioDao {
  final JsonCollection _col;

  AnnuncioDao(this._col);

  Future<void> load() => _col.load();

  bool get needsSeed => !_col.existedOnDisk;

  List<Annuncio> all() => _col.all().map(Annuncio.fromJson).toList();

  Annuncio? findById(int id) {
    for (final m in _col.all()) {
      if (m['id'] == id) return Annuncio.fromJson(m);
    }
    return null;
  }

  List<Annuncio> findByAzienda(int aziendaId) {
    final res = <Annuncio>[];
    for (final m in _col.all()) {
      if (m['aziendaId'] == aziendaId) {
        res.add(Annuncio.fromJson(m));
      }
    }
    res.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return res;
  }

  List<Annuncio> search({String? q, int? aziendaId}) {
    var items = all();
    if (aziendaId != null) {
      items = items.where((a) => a.aziendaId == aziendaId).toList();
    }
    if (q != null && q.trim().isNotEmpty) {
      final needle = q.toLowerCase().trim();
      items = items.where((a) =>
        a.titolo.toLowerCase().contains(needle) ||
        a.descrizione.toLowerCase().contains(needle) ||
        a.luogo.toLowerCase().contains(needle) ||
        a.tags.toLowerCase().contains(needle) ||
        a.aziendaNome.toLowerCase().contains(needle)
      ).toList();
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<Annuncio> create({
    required int aziendaId,
    required String aziendaNome,
    required String titolo,
    required String descrizione,
    required String luogo,
    required String tipoContratto,
    required String tags,
    String? createdAt,
  }) async {
    final annuncio = Annuncio(
      id: _col.nextId(),
      aziendaId: aziendaId,
      aziendaNome: aziendaNome,
      titolo: titolo,
      descrizione: descrizione,
      luogo: luogo,
      tipoContratto: tipoContratto,
      tags: tags,
      createdAt: createdAt ?? formatIsoUtc(DateTime.now()),
    );
    _col.add(annuncio.toJson());
    await _col.save();
    return annuncio;
  }

  Future<bool> delete(int id) async {
    final ok = _col.remove(id);
    if (ok) await _col.save();
    return ok;
  }
}
