import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/annuncio.dart';
import '../services/api_client.dart';
import '../utils/validators.dart';
import '../widgets/error_view.dart';

/// Form di candidatura per il candidato con allegato CV [Rif. R6, S2]
/// Non richiede registrazione né login
class CandidaturaScreen extends StatefulWidget {
  final Annuncio annuncio;

  const CandidaturaScreen({super.key, required this.annuncio});

  @override
  State<CandidaturaScreen> createState() => _CandidaturaScreenState();
}

class _CandidaturaScreenState extends State<CandidaturaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cognomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messaggioCtrl = TextEditingController();

  Uint8List? _cvBytes;
  String? _cvFileName;
  int? _cvSize;

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cognomeCtrl.dispose();
    _emailCtrl.dispose();
    _messaggioCtrl.dispose();
    super.dispose();
  }

  Future<void> _selezionaCurriculum() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (files.isNotEmpty) {
        final f = files.first;
        final bytes = await f.readAsBytes();
        final size = await f.length();
        setState(() {
          _cvFileName = f.name;
          _cvBytes = bytes;
          _cvSize = size ?? bytes.length;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore selezione file: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_cvBytes == null || _cvFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attenzione: è obbligatorio allegare il file del curriculum (PDF/DOC)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final api = context.read<ApiClient>();
      final cvBase64 = base64Encode(_cvBytes!);

      await api.post(
        '/api/annunci/${widget.annuncio.id}/candidature',
        body: {
          'nome': _nomeCtrl.text.trim(),
          'cognome': _cognomeCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'messaggio': _messaggioCtrl.text.trim(),
          'cvOriginalName': _cvFileName!,
          'cvBase64': cvBase64,
        },
      );

      if (!mounted) return;

      // Mostra modale di conferma [Rif. S2, Dispensa: Pag. 28, Slide 56]
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Candidatura Inviata!'),
            ],
          ),
          content: Text(
            'Grazie ${_nomeCtrl.text.trim()}! La tua candidatura per "${widget.annuncio.titolo}" è stata recapitata con successo all\'azienda ${widget.annuncio.aziendaNome}.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Torna all'annuncio
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Errore di connessione durante l\'invio.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compila Candidatura'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) InlineErrorBanner(message: _error!),

              // Riepilogo annuncio
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.annuncio.titolo, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(widget.annuncio.aziendaNome, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Generalità del candidato (nessuna registrazione richiesta)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nomeCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, 'il nome', 50),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cognomeCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Cognome *',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, 'il cognome', 50),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _messaggioCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Lettera di motivazione / Note (opzionale)',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.message_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Allegato Curriculum Vitae
              const Text('Curriculum Vitae *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: _cvFileName != null ? Colors.teal : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _cvFileName != null ? Icons.picture_as_pdf : Icons.upload_file,
                        size: 40,
                        color: _cvFileName != null ? Colors.red : Colors.teal,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _cvFileName ?? 'Nessun file selezionato',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _cvSize != null
                                  ? '${(_cvSize! / 1024).toStringAsFixed(1)} KB'
                                  : 'Formati consentiti: PDF, DOC, DOCX, TXT',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _selezionaCurriculum,
                        icon: const Icon(Icons.attach_file),
                        label: Text(_cvFileName == null ? 'Seleziona' : 'Cambia'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Pulsante conferma invio
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Conferma e Invia Candidatura',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
