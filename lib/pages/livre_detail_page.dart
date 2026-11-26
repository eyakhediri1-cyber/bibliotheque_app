import 'dart:io';

import 'package:flutter/material.dart';

class LivreDetailPage extends StatelessWidget {
  final Map<String, dynamic> livre;

  const LivreDetailPage({super.key, required this.livre});

  static const Color forest = Color(0xFF183F35);
  static const Color green = Color(0xFF477A60);
  static const Color cream = Color(0xFFF7F5EF);

  @override
  Widget build(BuildContext context) {
    final photo = livre['photo'] as String?;
    final titre = livre['titre']?.toString() ?? 'Sans titre';
    final nom = livre['nomEcrivain']?.toString() ?? '';
    final prenom = livre['prenomEcrivain']?.toString() ?? '';
    final ecrivain = '$prenom $nom'.trim();

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text('Détails du livre'),
        backgroundColor: forest,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 190,
                  height: 250,
                  child: photo != null && File(photo).existsSync()
                      ? Image.file(File(photo), fit: BoxFit.cover)
                      : Container(
                          color: Colors.white,
                          child: const Icon(
                            Icons.menu_book,
                            size: 90,
                            color: green,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: forest,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Chip(
                avatar: Icon(
                  (livre['favori'] ?? 0) == 1
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                  size: 18,
                ),
                label: Text(
                  (livre['favori'] ?? 0) == 1
                      ? 'Dans mes favoris'
                      : 'Pas encore favori',
                ),
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Informations bibliographiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: forest,
              ),
            ),
            const SizedBox(height: 12),
            _infoCard(
              Icons.person_outline,
              'Écrivain',
              ecrivain.isEmpty ? 'Non attribué' : ecrivain,
            ),
            _infoCard(
              Icons.qr_code,
              'ISBN',
              livre['isbn']?.toString().isNotEmpty == true
                  ? livre['isbn'].toString()
                  : 'Non renseigné',
            ),
            _infoCard(
              Icons.calendar_today,
              'Date de sortie',
              livre['dateSortie']?.toString().isNotEmpty == true
                  ? livre['dateSortie'].toString()
                  : 'Non renseignée',
            ),
            _infoCard(
              Icons.numbers,
              'Identifiant',
              livre['id']?.toString() ?? 'Non disponible',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: green),
        title: Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            color: forest,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
