import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop(); // chiude il drawer
    if (route == currentRoute) return;
    if (route == Routes.bacheca) {
      Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final nav = Navigator.of(context);
    final auth = context.read<AuthProvider>();
    nav.pop();
    await auth.logout();
    nav.pushNamedAndRemoveUntil(Routes.bacheca, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final azienda = auth.azienda;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            accountName: Text(
              azienda?.ragioneSociale ?? 'Ospite / Candidato',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              azienda == null
                  ? 'Accesso libero • Nessun login richiesto per candidarsi'
                  : '${azienda.email} • Azienda verificata',
              style: const TextStyle(fontSize: 12),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                azienda != null ? Icons.business : Icons.person_outline,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Bacheca Annunci'),
            selected: currentRoute == Routes.bacheca,
            onTap: () => _go(context, Routes.bacheca),
          ),
          if (auth.isLoggedIn) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Area Riservata Azienda'),
              selected: currentRoute == Routes.aziendaHome,
              onTap: () => _go(context, Routes.aziendaHome),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('I Miei Annunci Pubblicati'),
              selected: currentRoute == Routes.aziendaAnnunci,
              onTap: () => _go(context, Routes.aziendaAnnunci),
            ),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Pubblica Nuovo Annuncio'),
              selected: currentRoute == Routes.aziendaAnnuncioForm,
              onTap: () => _go(context, Routes.aziendaAnnuncioForm),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Disconnetti (Logout)', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ] else ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Accedi come Azienda'),
              selected: currentRoute == Routes.login,
              onTap: () => _go(context, Routes.login),
            ),
            ListTile(
              leading: const Icon(Icons.domain_add),
              title: const Text('Registra Nuova Azienda'),
              selected: currentRoute == Routes.register,
              onTap: () => _go(context, Routes.register),
            ),
          ],
        ],
      ),
    );
  }
}
