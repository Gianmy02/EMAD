import 'package:flutter/material.dart';

void main() {
  runApp(const GestioneAttivitaApp());
}

/// Modello che rappresenta una singola attività secondo le specifiche di dominio:
/// - titolo: testo obbligatorio che la descrive;
/// - stato: da fare o completata (default: da fare / completata = false);
/// - importanza: se l'attività è importante o no (default: false).
class Attivita {
  String titolo;
  bool completata;
  bool importante;

  Attivita({
    required this.titolo,
    this.completata = false,
    this.importante = false,
  });
}

/// Applicazione principale configurata con MaterialApp e tema Material 3.
class GestioneAttivitaApp extends StatelessWidget {
  const GestioneAttivitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestione Attività',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      home: const ElencoAttivitaScreen(),
    );
  }
}

/// Schermata principale: Elenco delle attività (R2, R3, R4)
class ElencoAttivitaScreen extends StatefulWidget {
  const ElencoAttivitaScreen({super.key});

  @override
  State<ElencoAttivitaScreen> createState() => _ElencoAttivitaScreenState();
}

class _ElencoAttivitaScreenState extends State<ElencoAttivitaScreen> {
  // Elenco in memoria delle attività
  final List<Attivita> _attivitaList = [];

  // Calcolo del numero di attività completate
  int get _completateCount =>
      _attivitaList.where((attivita) => attivita.completata).length;

  /// S1 - Avvia la schermata per aggiungere una nuova attività
  Future<void> _aggiungiAttivita() async {
    final nuovaAttivita = await Navigator.push<Attivita>(
      context,
      MaterialPageRoute(
        builder: (context) => const NuovaAttivitaScreen(),
      ),
    );

    // Se l'utente è tornato indietro senza confermare (Variante - rinuncia),
    // nuovaAttivita sarà null: non aggiungiamo nulla e non mostriamo messaggi.
    if (!mounted) return;

    if (nuovaAttivita != null) {
      setState(() {
        _attivitaList.add(nuovaAttivita);
      });

      // Messaggio temporaneo di conferma (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attività "${nuovaAttivita.titolo}" aggiunta con successo!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// S3 - Inverte lo stato di completamento dell'attività
  void _toggleStatoAttivita(Attivita item) {
    setState(() {
      item.completata = !item.completata;
    });
  }

  /// S4 - Chiede conferma ed elimina l'attività
  Future<void> _eliminaAttivita(int index) async {
    final item = _attivitaList[index];

    // Mostra la finestra di dialogo di conferma
    final bool? confermato = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text('Sei sicuro di voler eliminare "${item.titolo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    // Se l'utente ha confermato, rimuove l'attività
    // Se ha rifiutato o annullato (Variante - rinuncia), rimane invariata
    if (confermato == true) {
      setState(() {
        _attivitaList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totale = _attivitaList.length;
    final int completate = _completateCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elenco Attività'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Attività completate: $completate su $totale',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
      // S2 - Se non ci sono attività, mostra un messaggio di istruzione
      body: _attivitaList.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.playlist_add_check_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nessuna attività presente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tocca il pulsante "+" in basso a destra per aggiungerne una.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // S2 - Elenco di tutte le attività
          : ListView.builder(
              itemCount: _attivitaList.length,
              itemBuilder: (context, index) {
                final item = _attivitaList[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: item.importante ? 3 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: item.importante
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          )
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    // Stato evidenziato tramite Checkbox
                    leading: Checkbox(
                      value: item.completata,
                      onChanged: (_) => _toggleStatoAttivita(item),
                    ),
                    // Titolo dell'attività (sbarrato se completata)
                    title: Text(
                      item.titolo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: item.importante
                            ? FontWeight.bold
                            : FontWeight.w500,
                        decoration: item.completata
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: item.completata
                            ? Colors.grey
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    // Sotto-etichette per distinguere stato e importanza
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          // Stato
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.completata
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: item.completata
                                    ? Colors.green.shade300
                                    : Colors.orange.shade300,
                              ),
                            ),
                            child: Text(
                              item.completata ? 'Completata' : 'Da fare',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: item.completata
                                    ? Colors.green.shade800
                                    : Colors.orange.shade900,
                              ),
                            ),
                          ),
                          // Importanza
                          if (item.importante) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.amber.shade400),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 12, color: Colors.amber),
                                  SizedBox(width: 3),
                                  Text(
                                    'Importante',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // S4 - Pulsante per eliminare
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      tooltip: 'Elimina attività',
                      onPressed: () => _eliminaAttivita(index),
                    ),
                    // S3 - Il tocco sulla riga aggiorna lo stato dell'attività
                    onTap: () => _toggleStatoAttivita(item),
                  ),
                );
              },
            ),
      // S1 - Pulsante fluttuante per avviare la creazione
      floatingActionButton: FloatingActionButton(
        onPressed: _aggiungiAttivita,
        tooltip: 'Aggiungi attività',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Schermata di creazione: Aggiungi Attività (R1 / S1)
class NuovaAttivitaScreen extends StatefulWidget {
  const NuovaAttivitaScreen({super.key});

  @override
  State<NuovaAttivitaScreen> createState() => _NuovaAttivitaScreenState();
}

class _NuovaAttivitaScreenState extends State<NuovaAttivitaScreen> {
  final TextEditingController _titoloController = TextEditingController();
  bool _isImportante = false;
  String? _erroreTitolo;

  @override
  void dispose() {
    _titoloController.dispose();
    super.dispose();
  }

  /// Conferma della creazione:
  /// - Controlla la validità del titolo (obbligatorio).
  /// - Se non valido, segnala l'errore senza creare l'attività.
  /// - Se valido, restituisce l'oggetto Attivita alla schermata precedente.
  void _conferma() {
    final testo = _titoloController.text.trim();
    if (testo.isEmpty) {
      setState(() {
        _erroreTitolo = 'Il titolo è obbligatorio';
      });
      return;
    }

    Navigator.pop(
      context,
      Attivita(
        titolo: testo,
        completata: false,
        importante: _isImportante,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuova Attività'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo di inserimento titolo con validazione
            TextField(
              controller: _titoloController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Titolo dell\'attività *',
                hintText: 'Inserisci il titolo...',
                errorText: _erroreTitolo,
                border: const OutlineInputBorder(),
              ),
              // L'errore scompare appena l'utente inizia a correggere il titolo
              onChanged: (testo) {
                if (_erroreTitolo != null && testo.trim().isNotEmpty) {
                  setState(() {
                    _erroreTitolo = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Selezione dell'importanza (default: no / false)
            SwitchListTile(
              title: const Text('Attività importante'),
              subtitle: const Text('Seleziona se questa attività ha priorità'),
              secondary: Icon(
                _isImportante ? Icons.star : Icons.star_border,
                color: _isImportante ? Colors.amber : Colors.grey,
              ),
              value: _isImportante,
              onChanged: (valore) {
                setState(() {
                  _isImportante = valore;
                });
              },
            ),
            const SizedBox(height: 24),

            // Pulsante di conferma
            ElevatedButton.icon(
              onPressed: _conferma,
              icon: const Icon(Icons.check),
              label: const Text('Conferma e Salva'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
