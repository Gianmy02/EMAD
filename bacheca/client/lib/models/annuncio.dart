class Annuncio {
  final int id;
  final int aziendaId;
  final String aziendaNome;
  final String titolo;
  final String descrizione;
  final String luogo;
  final String tipoContratto;
  final String tags;
  final String createdAt;
  final int numCandidature;

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
    this.numCandidature = 0,
  });

  factory Annuncio.fromJson(Map<String, dynamic> j) => Annuncio(
    id: (j['id'] as num?)?.toInt() ?? 0,
    aziendaId: (j['aziendaId'] ?? j['azienda_id'] as num?)?.toInt() ?? 0,
    aziendaNome: j['aziendaNome'] ?? j['azienda_nome'] ?? '',
    titolo: j['titolo'] ?? '',
    descrizione: j['descrizione'] ?? '',
    luogo: j['luogo'] ?? '',
    tipoContratto: j['tipoContratto'] ?? j['tipo_contratto'] ?? 'Tempo indeterminato',
    tags: j['tags'] ?? '',
    createdAt: j['createdAt'] ?? j['created_at'] ?? '',
    numCandidature: (j['numCandidature'] ?? j['num_candidature'] as num?)?.toInt() ?? 0,
  );

  List<String> get tagList {
    if (tags.trim().isEmpty) return [];
    return tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }
}
