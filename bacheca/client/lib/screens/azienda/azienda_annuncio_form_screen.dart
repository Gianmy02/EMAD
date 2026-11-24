import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../utils/validators.dart';
import '../../widgets/error_view.dart';

/// Form di creazione/pubblicazione annuncio [Rif. R4, S1]
class AziendaAnnuncioFormScreen extends StatefulWidget {
  const AziendaAnnuncioFormScreen({super.key});

  @override
  State<AziendaAnnuncioFormScreen> createState() => _AziendaAnnuncioFormScreenState();
}

class _AziendaAnnuncioFormScreenState extends State<AziendaAnnuncioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titoloCtrl = TextEditingController();
  final _luogoCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _descrizioneCtrl = TextEditingController();

  String _tipoContratto = 'Tempo indeterminato';
  final List<String> _contratti = [
    'Tempo indeterminato',
    'Tempo determinato',
    'Stage / Tirocinio',
    'Partita IVA / Freelance',
    'Apprendistato',
  ];

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titoloCtrl.dispose();
    _luogoCtrl.dispose();
    _tagsCtrl.dispose();
    _descrizioneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final api = context.read<ApiClient>();
      await api.post('/api/azienda/annunci', body: {
        'titolo': _titoloCtrl.text.trim(),
        'luogo': _luogoCtrl.text.trim().isEmpty ? 'Ibrido' : _luogoCtrl.text.trim(),
        'tipoContratto': _tipoContratto,
        'tags': _tagsCtrl.text.trim(),
        'descrizione': _descrizioneCtrl.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Annuncio pubblicato con successo!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Errore di comunicazione con il server.';
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pubblica Nuovo Annuncio'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) InlineErrorBanner(message: _error!),

              TextFormField(
                controller: _titoloCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) => Validators.required(v, 'il titolo dell\'offerta', 100),
                decoration: const InputDecoration(
                  labelText: 'Titolo Posizione * (es. Flutter Developer)',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _luogoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Sede / Modalità (es. Milano, Ibrido, Full Remote)',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _tipoContratto,
                decoration: const InputDecoration(
                  labelText: 'Tipologia di Contratto',
                  prefixIcon: Icon(Icons.work_outline),
                  border: OutlineInputBorder(),
                ),
                items: _contratti.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _tipoContratto = v);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Competenze / Tag separati da virgola (es. Flutter, Dart, REST)',
                  prefixIcon: Icon(Icons.tag),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descrizioneCtrl,
                maxLines: 5,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) => Validators.required(v, 'la descrizione dell\'offerta', 2000),
                decoration: const InputDecoration(
                  labelText: 'Descrizione dell\'offerta e requisiti *',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: const Icon(Icons.publish),
                  label: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Pubblica Annuncio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
