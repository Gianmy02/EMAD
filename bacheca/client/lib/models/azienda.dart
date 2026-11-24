class Azienda {
  final int id;
  final String ragioneSociale;
  final String email;
  final String settore;
  final String createdAt;

  const Azienda({
    required this.id,
    required this.ragioneSociale,
    required this.email,
    required this.settore,
    required this.createdAt,
  });

  factory Azienda.fromJson(Map<String, dynamic> j) => Azienda(
    id: (j['id'] as num?)?.toInt() ?? 0,
    ragioneSociale: j['ragioneSociale'] ?? j['ragione_sociale'] ?? '',
    email: j['email'] ?? '',
    settore: j['settore'] ?? '',
    createdAt: j['createdAt'] ?? j['created_at'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'ragioneSociale': ragioneSociale,
    'email': email,
    'settore': settore,
    'createdAt': createdAt,
  };
}
