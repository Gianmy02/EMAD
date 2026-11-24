import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../routes.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';
import '../widgets/error_view.dart';

/// Registrazione Azienda [Rif. R1, S1]
class RegisterScreen extends StatefulWidget {
  final String? returnTo;

  const RegisterScreen({super.key, this.returnTo});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ragioneSociale = TextEditingController();
  final _email = TextEditingController();
  final _settore = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _ragioneSociale.dispose();
    _email.dispose();
    _settore.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await auth.register(
        _ragioneSociale.text.trim(),
        _email.text.trim(),
        _password.text,
        _settore.text.trim(),
      );
      if (!mounted) return;
      Routes.afterLogin(context, auth, widget.returnTo);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Risposta non valida dal server.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrazione Azienda')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.domain_add, size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Crea Account Azienda',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (_error != null) InlineErrorBanner(message: _error!),

                  TextFormField(
                    controller: _ragioneSociale,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (v) => Validators.required(v, 'la ragione sociale', 100),
                    decoration: const InputDecoration(
                      labelText: 'Ragione Sociale / Nome Azienda *',
                      prefixIcon: Icon(Icons.domain),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _settore,
                    decoration: const InputDecoration(
                      labelText: 'Settore (es. IT, Consulenza, Finanza)',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      labelText: 'Email aziendale *',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.password,
                    decoration: InputDecoration(
                      labelText: 'Password (min. 6 caratteri) *',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Registrati e Inizia', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Hai già un account?'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                            Routes.login,
                            arguments: widget.returnTo,
                          );
                        },
                        child: const Text('Accedi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
