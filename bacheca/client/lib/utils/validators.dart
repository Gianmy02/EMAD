class Validators {
  static final RegExp _emailRe = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? required(String? value, String fieldName, [int max = 255]) {
    if (value == null || value.trim().isEmpty) {
      return 'Inserisci $fieldName';
    }
    if (value.trim().length > max) {
      return '$fieldName non può superare i $max caratteri';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Inserisci l\'email';
    }
    if (!_emailRe.hasMatch(value.trim())) {
      return 'Formato email non valido (es. info@azienda.it)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci la password';
    }
    if (value.length < 6) {
      return 'La password deve contenere almeno 6 caratteri';
    }
    return null;
  }
}
