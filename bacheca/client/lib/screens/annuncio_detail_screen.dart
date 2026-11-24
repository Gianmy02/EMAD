import 'package:flutter/material.dart';

import '../models/annuncio.dart';
import '../routes.dart';

/// Dettaglio di un'offerta di lavoro per il candidato [Rif. R5, S2]
class AnnuncioDetailScreen extends StatelessWidget {
  final Annuncio annuncio;

  const AnnuncioDetailScreen({super.key, required this.annuncio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(annuncio.titolo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Riquadro Azienda
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer.withAlpha(80),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.business, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            annuncio.aziendaNome,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pubblicato il: ${annuncio.createdAt.split("T").first}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Titolo
            Text(
              annuncio.titolo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Caratteristiche contrattuali e luogo
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  avatar: const Icon(Icons.location_on, size: 16),
                  label: Text(annuncio.luogo),
                ),
                Chip(
                  avatar: const Icon(Icons.work_outline, size: 16),
                  label: Text(annuncio.tipoContratto),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Competenze e tags
            if (annuncio.tagList.isNotEmpty) ...[
              const Text(
                'Competenze richieste:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: annuncio.tagList.map((tag) {
                  return Chip(label: Text(tag), backgroundColor: Colors.teal.shade50);
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Descrizione
            const Text(
              'Descrizione dell\'offerta:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                annuncio.descrizione,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),

            // Pulsante Candidatura [Rif. R6, S2]
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                icon: const Icon(Icons.send),
                label: const Text(
                  'Candidati a questa posizione',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    Routes.candidatura,
                    arguments: annuncio,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
