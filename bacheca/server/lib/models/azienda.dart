class Azienda {
  final int id;
  final String ragioneSociale;
  final String email;
  final String settore;
  final String passwordHash;
  final String salt;
  final String createdAt; // ISO-8601 UTC

  const Azienda({
    required this.id,
    required this.ragioneSociale,
    required this.email,
    required this.settore,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
  });

  factory Azienda.fromJson(Map<String, dynamic> j) => Azienda(
    id: j['id'] as int,
    ragioneSociale: j['ragioneSociale'] as String,
    email: j['email'] as String,
    settore: j['settore'] as String? ?? '',
    passwordHash: j['passwordHash'] as String,
    salt: j['salt'] as String,
    createdAt: j['createdAt'] as String,
  );

  /// Serializzazione completa per persistenza su file JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'ragioneSociale': ragioneSociale,
    'email': email,
    'settore': settore,
    'passwordHash': passwordHash,
    'salt': salt,
    'createdAt': createdAt,
  };

  /// Serializzazione pubblica (senza hash e salt).
  Map<String, dynamic> toPublicJson() => {
    'id': id,
    'ragioneSociale': ragioneSociale,
    'email': email,
    'settore': settore,
    'createdAt': createdAt,
  };
}
