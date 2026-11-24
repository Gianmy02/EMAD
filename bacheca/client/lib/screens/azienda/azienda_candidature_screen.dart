import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/api_config.dart';
import '../../models/annuncio.dart';
import '../../models/candidatura.dart';
import '../../services/api_client.dart';
import '../../widgets/error_view.dart';

/// Consultazione candidature per un annuncio dell'azienda [Rif. R7, S3]
class AziendaCandidatureScreen extends StatefulWidget {
  final Annuncio annuncio;

  const AziendaCandidatureScreen({super.key, required this.annuncio});

  @override
  State<AziendaCandidatureScreen> createState() => _AziendaCandidatureScreenState();
}

class _AziendaCandidatureScreenState extends State<AziendaCandidatureScreen> {
  List<Candidatura> _candidature = [];
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
      final data = await api.get('/api/azienda/annunci/${widget.annuncio.id}/candidature');
      if (!mounted) return;

      final listJson = (data as Map)['candidature'] as List;
      final list = listJson
          .map((e) => Candidatura.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      setState(() {
        _candidature = list;
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
        _error = 'Errore durante il recupero delle candidature.';
        _loading = false;
      });
    }
  }

  Future<void> _apriCv(String cvFilename) async {
    final url = '${ApiConfig.baseUrl}/api/uploads/$cvFilename';
    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossibile aprire il file all\'indirizzo: $url')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante l\'apertura del curriculum: $e')),
      );
    }
  }

  void _mostraDettagliCandidato(Candidatura c) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(c.nomeCompleto),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.email, size: 18, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(child: SelectableText(c.email)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.teal),
                const SizedBox(width: 8),
                Text('Ricevuta il: ${c.createdAt.split("T").first}'),
              ],
            ),
            const SizedBox(height: 16),
            if (c.messaggio.isNotEmpty) ...[
              const Text('Lettera di presentazione / Note:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(c.messaggio, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Curriculum Vitae:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: Text(c.cvOriginalName, overflow: TextOverflow.ellipsis),
              trailing: FilledButton.tonalIcon(
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Apri'),
                onPressed: () => _apriCv(c.cvFilename),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Candidature: ${widget.annuncio.titolo}'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _candidature.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _candidature.isEmpty) {
      return ErrorView(message: _error!, onRetry: _load);
    }
    if (_candidature.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nessuna candidatura ricevuta finora.', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _candidature.length,
      itemBuilder: (context, index) {
        final c = _candidature[index];
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
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        c.nome.isNotEmpty ? c.nome[0].toUpperCase() : '?',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.nomeCompleto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(c.email, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        ],
                      ),
                    ),
                    Text(c.createdAt.split('T').first, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                if (c.messaggio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    c.messaggio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade800),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.attach_file, size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              c.cvOriginalName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => _mostraDettagliCandidato(c),
                      child: const Text('Dettagli'),
                    ),
                    const SizedBox(width: 4),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text('Apri CV'),
                      onPressed: () => _apriCv(c.cvFilename),
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
