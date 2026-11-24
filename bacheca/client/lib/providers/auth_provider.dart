import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/azienda.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  static const _tokenKey = 'auth_token';

  final ApiClient _api;
  Azienda? _azienda;
  bool _initializing = true;
  bool _manualLogout = false;

  /// true quando il logout è forzato da un 401 (letto da main.dart).
  bool sessionExpired = false;

  AuthProvider(this._api) {
    _api.onUnauthorized = _handleUnauthorized;
  }

  Azienda? get azienda => _azienda;
  bool get isLoggedIn => _azienda != null;
  bool get initializing => _initializing;

  /// Ripristina la sessione salvata chiamando /api/auth/me [Rif. R2]
  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null) {
        _api.token = token;
        try {
          final json = await _api.get('/api/auth/me');
          _azienda = Azienda.fromJson((json as Map).cast<String, dynamic>());
        } catch (_) {
          await _clearLocal();
        }
      }
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  /// Login Azienda [Rif. R2, S1]
  Future<void> login(String email, String password) async {
    final json = await _api.post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    await _setSession((json as Map).cast<String, dynamic>());
  }

  /// Registrazione nuova Azienda [Rif. R1, S1]
  Future<void> register(
    String ragioneSociale,
    String email,
    String password,
    String settore,
  ) async {
    final json = await _api.post(
      '/api/auth/register',
      body: {
        'ragioneSociale': ragioneSociale,
        'email': email,
        'password': password,
        'settore': settore,
      },
    );
    await _setSession((json as Map).cast<String, dynamic>());
  }

  /// Logout Azienda [Rif. R3, S3]
  Future<void> logout() async {
    _manualLogout = true;
    try {
      await _api.post('/api/auth/logout');
    } catch (_) {
      // anche se il server non risponde si esce in locale
    }
    await _clearLocal();
    _manualLogout = false;
  }

  Future<void> _setSession(Map<String, dynamic> json) async {
    final token = json['token'] as String;
    _api.token = token;
    _azienda = Azienda.fromJson((json['azienda'] as Map).cast<String, dynamic>());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    notifyListeners();
  }

  void _handleUnauthorized() {
    if (_azienda == null || _initializing || _manualLogout) return;
    sessionExpired = true;
    _clearLocal();
  }

  Future<void> _clearLocal() async {
    _api.token = null;
    _azienda = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
