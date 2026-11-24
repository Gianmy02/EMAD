import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/annuncio.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';
import '../services/api_client.dart';
import '../widgets/app_drawer.dart';
import '../widgets/error_view.dart';

/// Consultazione bacheca annunci per il candidato [Rif. R5, S2]
/// Strutturata identicamente al Catalogo del progetto Nytro
class BachecaScreen extends StatefulWidget {
  const BachecaScreen({super.key});

  @override
  State<BachecaScreen> createState() => _BachecaScreenState();
}

class _BachecaScreenState extends State<BachecaScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<Annuncio> _annunci = [];
  String _query = '';
  bool _loading = true;
  String? _error;
  int _reqId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = ++_reqId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      final data = await api.get('/api/annunci', query: {
        if (_query.trim().isNotEmpty) 'q': _query.trim(),
      });
      if (!mounted || id != _reqId) return;

      final listJson = (data as Map)['annunci'] as List;
      final list = listJson
          .map((e) => Annuncio.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      setState(() {
        _annunci = list;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted || id != _reqId) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || id != _reqId) return;
      setState(() {
        _error = 'Risposta non valida dal server.';
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    setState(() => _query = v);
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchCtrl.clear();
    setState(() => _query = '');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      drawer: const AppDrawer(currentRoute: Routes.bacheca),
      appBar: AppBar(
        title: const Text('Bacheca Opportunità'),
        actions: [
          if (auth.isLoggedIn)
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(Routes.aziendaHome),
              icon: const Icon(Icons.business_center, color: Colors.white),
              label: Text(
                auth.azienda?.ragioneSociale ?? 'Azienda',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          else
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(Routes.login),
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                'Accesso Aziende',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra di ricerca con debounce [Rif. Nytro Pattern]
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cerca per titolo, azienda, luogo, tecnologia...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
                    : null,
              ),
            ),
          ),

          // Contenuto con gestione stati loading, error, empty, list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: _buildBody(),
            ),
          ),
        ],
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
        children: const [
          SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.work_off_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Nessun annuncio trovato.', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _annunci.length,
      itemBuilder: (context, index) {
        final annuncio = _annunci[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Apertura dettaglio annuncio [Rif. R5]
              Navigator.of(context).pushNamed(Routes.annuncioDetail, arguments: annuncio);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.work, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              annuncio.titolo,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              annuncio.aziendaNome,
                              style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    annuncio.descrizione,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(annuncio.luogo, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      const SizedBox(width: 16),
                      Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(annuncio.tipoContratto, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                  if (annuncio.tagList.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: annuncio.tagList.map((tag) {
                        return Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 11)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.teal.shade50,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
