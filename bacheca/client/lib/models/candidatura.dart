class Candidatura {
  final int id;
  final int annuncioId;
  final String annuncioTitolo;
  final String nome;
  final String cognome;
  final String email;
  final String messaggio;
  final String cvFilename;
  final String cvOriginalName;
  final String cvUrl;
  final String createdAt;

  const Candidatura({
    required this.id,
    required this.annuncioId,
    required this.annuncioTitolo,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.messaggio,
    required this.cvFilename,
    required this.cvOriginalName,
    required this.cvUrl,
    required this.createdAt,
  });

  factory Candidatura.fromJson(Map<String, dynamic> j) => Candidatura(
    id: (j['id'] as num?)?.toInt() ?? 0,
    annuncioId: (j['annuncioId'] ?? j['annuncio_id'] as num?)?.toInt() ?? 0,
    annuncioTitolo: j['annuncioTitolo'] ?? j['annuncio_titolo'] ?? '',
    nome: j['nome'] ?? '',
    cognome: j['cognome'] ?? '',
    email: j['email'] ?? '',
    messaggio: j['messaggio'] ?? '',
    cvFilename: j['cvFilename'] ?? j['cv_filename'] ?? '',
    cvOriginalName: j['cvOriginalName'] ?? j['cv_original_name'] ?? 'Curriculum.pdf',
    cvUrl: j['cvUrl'] ?? j['cv_url'] ?? '',
    createdAt: j['createdAt'] ?? j['created_at'] ?? '',
  );

  String get nomeCompleto => '$nome $cognome';
}
