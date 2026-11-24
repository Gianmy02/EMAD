class Annuncio {
  final int id;
  final int aziendaId;
  final String aziendaNome;
  final String titolo;
  final String descrizione;
  final String luogo;
  final String tipoContratto;
  final String tags;
  final String createdAt; // ISO-8601 UTC

  const Annuncio({
    required this.id,
    required this.aziendaId,
    required this.aziendaNome,
    required this.titolo,
    required this.descrizione,
    required this.luogo,
    required this.tipoContratto,
    required this.tags,
    required this.createdAt,
  });

  factory Annuncio.fromJson(Map<String, dynamic> j) => Annuncio(
    id: j['id'] as int,
    aziendaId: j['aziendaId'] as int,
    aziendaNome: j['aziendaNome'] as String,
    titolo: j['titolo'] as String,
    descrizione: j['descrizione'] as String,
    luogo: j['luogo'] as String? ?? '',
    tipoContratto: j['tipoContratto'] as String? ?? 'Tempo indeterminato',
    tags: j['tags'] as String? ?? '',
    createdAt: j['createdAt'] as String,
  );

  Map<String, dynamic> toJson({int numCandidature = 0}) => {
    'id': id,
    'aziendaId': aziendaId,
    'aziendaNome': aziendaNome,
    'titolo': titolo,
    'descrizione': descrizione,
    'luogo': luogo,
    'tipoContratto': tipoContratto,
    'tags': tags,
    'createdAt': createdAt,
    'numCandidature': numCandidature,
  };
}
