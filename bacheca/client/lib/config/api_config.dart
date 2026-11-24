/// Configurazione di rete.
/// Default: server locale su http://127.0.0.1:8080
/// Per smartphone fisico o emulatore Android:
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.14:8080',
  );
  static const Duration timeout = Duration(seconds: 10);
}
