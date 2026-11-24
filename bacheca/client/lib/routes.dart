import 'package:flutter/material.dart';

import 'models/annuncio.dart';
import 'providers/auth_provider.dart';
import 'screens/annuncio_detail_screen.dart';
import 'screens/azienda/azienda_annunci_screen.dart';
import 'screens/azienda/azienda_annuncio_form_screen.dart';
import 'screens/azienda/azienda_candidature_screen.dart';
import 'screens/azienda/azienda_home_screen.dart';
import 'screens/bacheca_screen.dart';
import 'screens/candidatura_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

class Routes {
  static const bacheca = '/';
  static const annuncioDetail = '/annuncio';
  static const candidatura = '/candidatura';
  static const login = '/login';
  static const register = '/register';
  static const aziendaHome = '/azienda';
  static const aziendaAnnunci = '/azienda/annunci';
  static const aziendaAnnuncioForm = '/azienda/annunci/form';
  static const aziendaCandidature = '/azienda/candidature';

  // Rotte protette per sola Azienda autenticata
  static const _aziendaOnly = {
    aziendaHome,
    aziendaAnnunci,
    aziendaAnnuncioForm,
    aziendaCandidature,
  };

  static MaterialPageRoute<dynamic> _page(RouteSettings s, Widget w) =>
      MaterialPageRoute(settings: s, builder: (_) => w);

  static Route<dynamic> generate(RouteSettings s, AuthProvider auth) {
    final name = s.name ?? bacheca;
    final protected = _aziendaOnly.contains(name);

    // Non loggato tenta accesso ad area riservata -> reindirizza a login [Rif. R2]
    if (protected && !auth.isLoggedIn) {
      return _page(RouteSettings(name: login, arguments: name),
          LoginScreen(returnTo: name));
    }

    switch (name) {
      case annuncioDetail:
        final a = s.arguments;
        if (a is Annuncio) return _page(s, AnnuncioDetailScreen(annuncio: a));
        return _page(const RouteSettings(name: bacheca), const BachecaScreen());
      case candidatura:
        final a = s.arguments;
        if (a is Annuncio) return _page(s, CandidaturaScreen(annuncio: a));
        return _page(const RouteSettings(name: bacheca), const BachecaScreen());
      case login:
        return _page(s, LoginScreen(returnTo: s.arguments as String?));
      case register:
        return _page(s, RegisterScreen(returnTo: s.arguments as String?));
      case aziendaHome:
        return _page(s, const AziendaHomeScreen());
      case aziendaAnnunci:
        return _page(s, const AziendaAnnunciScreen());
      case aziendaAnnuncioForm:
        return _page(s, const AziendaAnnuncioFormScreen());
      case aziendaCandidature:
        final a = s.arguments;
        if (a is Annuncio) return _page(s, AziendaCandidatureScreen(annuncio: a));
        return _page(const RouteSettings(name: aziendaAnnunci), const AziendaAnnunciScreen());
      case bacheca:
      default:
        return _page(const RouteSettings(name: bacheca), const BachecaScreen());
    }
  }

  /// Dopo login/registrazione dell'azienda [Rif. S1]
  static void afterLogin(BuildContext context, AuthProvider auth, String? returnTo) {
    final dest = returnTo ?? aziendaHome;
    final RoutePredicate keep =
        dest == bacheca ? (Route<dynamic> r) => false : (Route<dynamic> r) => r.isFirst;
    Navigator.of(context).pushNamedAndRemoveUntil(dest, keep);
  }
}
