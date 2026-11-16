import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_do_list/main.dart';

void main() {
  testWidgets('S2 - Mostra stato iniziale vuoto e contatore', (WidgetTester tester) async {
    await tester.pumpWidget(const GestioneAttivitaApp());

    // Verifica che mostri l'indicazione su come aggiungere un'attività
    expect(find.text('Nessuna attività presente'), findsOneWidget);
    expect(find.text('Attività completate: 0 su 0'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('S1 - Aggiungi attività con validazione ed errore', (WidgetTester tester) async {
    await tester.pumpWidget(const GestioneAttivitaApp());

    // 1. Avvia creazione
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verifica apertura schermata
    expect(find.text('Nuova Attività'), findsOneWidget);

    // 3. Tenta di confermare senza inserire il titolo (Variante titolo mancante)
    await tester.tap(find.text('Conferma e Salva'));
    await tester.pumpAndSettle();

    // Verifica errore
    expect(find.text('Il titolo è obbligatorio'), findsOneWidget);

    // Inserisce titolo e l'errore scompare
    await tester.enterText(find.byType(TextField), 'Studiare Flutter');
    await tester.pumpAndSettle();
    expect(find.text('Il titolo è obbligatorio'), findsNothing);

    // Seleziona importanza
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Conferma
    await tester.tap(find.text('Conferma e Salva'));
    await tester.pumpAndSettle();

    // Torna all'elenco e mostra messaggio di conferma
    expect(find.text('Attività "Studiare Flutter" aggiunta con successo!'), findsOneWidget);
    expect(find.text('Studiare Flutter'), findsOneWidget);
    expect(find.text('Importante'), findsOneWidget);
    expect(find.text('Da fare'), findsOneWidget);
    expect(find.text('Attività completate: 0 su 1'), findsOneWidget);
  });

  testWidgets('S3 - Aggiorna lo stato di un\'attività', (WidgetTester tester) async {
    await tester.pumpWidget(const GestioneAttivitaApp());

    // Aggiungi un'attività
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Fare la spesa');
    await tester.tap(find.text('Conferma e Salva'));
    await tester.pumpAndSettle();

    expect(find.text('Attività completate: 0 su 1'), findsOneWidget);

    // Segna come completata toccando la riga
    await tester.tap(find.text('Fare la spesa'));
    await tester.pumpAndSettle();

    expect(find.text('Completata'), findsOneWidget);
    expect(find.text('Attività completate: 1 su 1'), findsOneWidget);

    // Riporta a "da fare"
    await tester.tap(find.text('Fare la spesa'));
    await tester.pumpAndSettle();

    expect(find.text('Da fare'), findsOneWidget);
    expect(find.text('Attività completate: 0 su 1'), findsOneWidget);
  });

  testWidgets('S4 - Eliminazione attività con dialogo e rinuncia', (WidgetTester tester) async {
    await tester.pumpWidget(const GestioneAttivitaApp());

    // Aggiungi un'attività
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Attività da cancellare');
    await tester.tap(find.text('Conferma e Salva'));
    await tester.pumpAndSettle();

    // Premi elimina
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    // Dialogo visibile
    expect(find.text('Conferma eliminazione'), findsOneWidget);

    // Variante rinuncia: premi Annulla
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(find.text('Attività da cancellare'), findsOneWidget);
    expect(find.text('Attività completate: 0 su 1'), findsOneWidget);

    // Premi di nuovo elimina e conferma
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();

    // L'attività è rimossa e torniamo allo stato vuoto
    expect(find.text('Attività da cancellare'), findsNothing);
    expect(find.text('Nessuna attività presente'), findsOneWidget);
    expect(find.text('Attività completate: 0 su 0'), findsOneWidget);
  });
}
