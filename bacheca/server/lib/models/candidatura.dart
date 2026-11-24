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
  final String createdAt; // ISO-8601 UTC

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
    required this.createdAt,
  });

  factory Candidatura.fromJson(Map<String, dynamic> j) => Candidatura(
    id: j['id'] as int,
    annuncioId: j['annuncioId'] as int,
    annuncioTitolo: j['annuncioTitolo'] as String? ?? '',
    nome: j['nome'] as String,
    cognome: j['cognome'] as String,
    email: j['email'] as String,
    messaggio: j['messaggio'] as String? ?? '',
    cvFilename: j['cvFilename'] as String,
    cvOriginalName: j['cvOriginalName'] as String,
    createdAt: j['createdAt'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'annuncioId': annuncioId,
    'annuncioTitolo': annuncioTitolo,
    'nome': nome,
    'cognome': cognome,
    'email': email,
    'messaggio': messaggio,
    'cvFilename': cvFilename,
    'cvOriginalName': cvOriginalName,
    'cvUrl': '/api/uploads/$cvFilename',
    'createdAt': createdAt,
  };
}
