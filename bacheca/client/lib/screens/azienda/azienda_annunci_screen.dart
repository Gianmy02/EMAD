import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/annuncio.dart';
import '../../routes.dart';
import '../../services/api_client.dart';
import '../../widgets/error_view.dart';

/// Elenco annunci pubblicati dall'azienda [Rif. R4, R7, S3]
class AziendaAnnunciScreen extends StatefulWidget {
  const AziendaAnnunciScreen({super.key});

  @override
  State<AziendaAnnunciScreen> createState() => _AziendaAnnunciScreenState();
}

class _AziendaAnnunciScreenState extends State<AziendaAnnunciScreen> {
  List<Annuncio> _annunci = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final data = await api.get('/api/azienda/annunci');
      if (!mounted) return;

      final listJson = (data as Map)['annunci'] as List;
      final list = listJson
          .map((e) => Annuncio.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      setState(() {
        _annunci = list;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Errore durante il recupero dei tuoi annunci.';
        _loading = false;
      });
    }
  }

  Future<void> _openForm() async {
    final changed = await Navigator.of(context).pushNamed(Routes.aziendaAnnuncioForm);
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I Miei Annunci'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Annuncio'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _annunci.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _annunci.isEmpty) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_annunci.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                const Icon(Icons.post_add, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Non hai ancora pubblicato nessun annuncio.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _openForm,
                  icon: const Icon(Icons.add),
                  label: const Text('Crea il tuo primo annuncio'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _annunci.length,
      itemBuilder: (context, index) {
        final a = _annunci[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        a.titolo,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: a.numCandidature > 0 ? Colors.green.shade100 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${a.numCandidature} ${a.numCandidature == 1 ? "candidatura" : "candidature"}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: a.numCandidature > 0 ? Colors.green.shade900 : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  a.descrizione,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${a.luogo} • ${a.tipoContratto}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Apertura consultazione candidature ricevute [Rif. R7, S3]
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.people_alt_outlined, size: 18),
                      label: const Text('Candidature'),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          Routes.aziendaCandidature,
                          arguments: a,
                        ).then((_) => _load());
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
