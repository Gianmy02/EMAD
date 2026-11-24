import '../dao/annuncio_dao.dart';
import '../dao/azienda_dao.dart';
import '../dao/candidatura_dao.dart';
import 'password_service.dart';

class Seeder {
  static Future<void> run({
    required AziendaDao aziende,
    required AnnuncioDao annunci,
    required CandidaturaDao candidature,
  }) async {
    if (aziende.needsSeed) await _seed(aziende, annunci, candidature);
  }

  static Future<void> _seed(
    AziendaDao aziende,
    AnnuncioDao annunci,
    CandidaturaDao candidature,
  ) async {
    final salt = PasswordService.generateSalt();
    final az = await aziende.create(
      ragioneSociale: 'TechCorp Solutions',
      email: 'info@techcorp.it',
      passwordHash: PasswordService.hash('password123', salt),
      salt: salt,
      settore: 'Informatica & Cloud',
      createdAt: '2026-11-01T08:00:00Z',
    );

    await annunci.create(
      aziendaId: az.id,
      aziendaNome: az.ragioneSociale,
      titolo: 'Flutter Mobile Developer (Junior/Mid)',
      descrizione:
          'Cerchiamo sviluppatore Flutter appassionato per sviluppo app multipiattaforma iOS/Android. Richiesta conoscenza dei widget Material, gestione dello stato (setState, ValueNotifier, Provider) e consumo API REST.',
      luogo: 'Milano / Ibrido',
      tipoContratto: 'Tempo indeterminato',
      tags: 'Flutter, Dart, Provider, REST API',
      createdAt: '2026-11-05T09:00:00Z',
    );

    await annunci.create(
      aziendaId: az.id,
      aziendaNome: az.ragioneSociale,
      titolo: 'Backend Engineer (Dart / Shelf / REST)',
      descrizione:
          'Ricerchiamo figura backend per la progettazione e manutenzione di microservizi RESTful, archiviazione dati JSON/database e integrazione con client mobile.',
      luogo: 'Roma / Full Remote',
      tipoContratto: 'Tempo determinato',
      tags: 'Dart, Shelf, REST, JSON',
      createdAt: '2026-11-10T14:30:00Z',
    );
  }
}
