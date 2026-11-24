import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes.dart';
import '../../widgets/app_drawer.dart';

/// Dashboard Area Riservata Azienda [Rif. S1, S3]
/// Strutturata identicamente all'AdminHomeScreen del progetto Nytro
class AziendaHomeScreen extends StatelessWidget {
  const AziendaHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final nav = Navigator.of(context);
    await context.read<AuthProvider>().logout();
    nav.pushNamedAndRemoveUntil(Routes.bacheca, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final azienda = context.watch<AuthProvider>().azienda;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: Routes.aziendaHome),
      appBar: AppBar(
        title: const Text('Area Riservata Azienda'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer.withAlpha(90),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.business, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          azienda?.ragioneSociale ?? 'Azienda',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          azienda?.email ?? '',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                        if (azienda != null && azienda.settore.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Settore: ${azienda.settore}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sezione 1: I Miei Annunci
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(Icons.list_alt, size: 36, color: Theme.of(context).colorScheme.primary),
              title: const Text('I Miei Annunci di Lavoro', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Visualizza le tue offerte pubblicate e le relative candidature ricevute'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(Routes.aziendaAnnunci),
            ),
          ),
          const SizedBox(height: 12),

          // Sezione 2: Pubblica Nuovo Annuncio
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(Icons.post_add, size: 36, color: Theme.of(context).colorScheme.primary),
              title: const Text('Pubblica Nuovo Annuncio', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Crea e pubblica una nuova offerta di lavoro visibile a tutti i candidati'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(Routes.aziendaAnnuncioForm),
            ),
          ),
          const SizedBox(height: 12),

          // Sezione 3: Bacheca Pubblica
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.storefront, size: 36),
              title: const Text('Torna alla Bacheca Pubblica', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Esplora la bacheca come appare ai candidati esterni'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(Routes.bacheca, (r) => false),
            ),
          ),
        ],
      ),
    );
  }
}
