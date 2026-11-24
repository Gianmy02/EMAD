# Bacheca Annunci di Lavoro (EMAD MVP)

Applicazione completa composta da **Client Flutter** e **Server Dart Shelf**, sviluppata per il corso di *Enterprise Mobile Application Development*.

## Struttura del Progetto

```
bacheca/
├── client/          # Applicazione Frontend Flutter (Candidati + Area Azienda)
└── server/          # Backend Server Dart Shelf (API REST, persistenza JSON, Upload CV)
```

---

## 1. Avvio Rapido

### Avviare il Server Backend
Apri un terminale e posizionati nella cartella `server`:
```bash
cd server
dart pub get
dart run bin/server.dart
```
> Il server si avvia all'indirizzo `http://localhost:8080`.
> I dati persistenti vengono salvati nei file JSON (`data/`) e i CV caricati nella cartella `uploads/`.

### Avviare il Client Flutter
Apri un secondo terminale e posizionati nella cartella `client`:
```bash
cd client
flutter pub get
flutter run -d chrome
# oppure flutter run -d windows / emulatore Android
```

---

## 2. Requisiti e Scenari supportati

- **R1 - Registrazione Azienda**: Creazione di un account con credenziali sicure (SHA-256 + salt).
- **R2 - Login Azienda**: Autenticazione e ricezione del token Bearer salvato in persistenza locale.
- **R3 - Logout Azienda**: Invalidazione sessione e ritorno alla bacheca pubblica.
- **R4 - Pubblicazione Annuncio**: Form dedicato con titolo, descrizione, tipo di contratto, RAL e sede.
- **R5 - Consultazione Bacheca**: Elenco annunci e dettaglio completo accessibili senza autenticazione.
- **R6 - Candidatura con CV**: Invio candidatura con nome, cognome, email e caricamento file CV (PDF/DOC) serializzato su server.
- **R7 - Consultazione Candidature**: L'azienda autenticata visualizza le candidature per i propri annunci e scarica/apre i CV inviati.

### Scenari
- **S1**: Pubblicazione nuovo annuncio da parte di un'azienda registrata.
- **S2**: Candidatura da parte di un candidato senza login con allegato curriculum.
- **S3**: Consultazione candidature ricevute e logout aziendale.
