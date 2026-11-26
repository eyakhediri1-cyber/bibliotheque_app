import 'package:flutter/material.dart';

import '../database/sql_helper.dart';
import '../utils/app_theme.dart';

class LivreConsultationPage extends StatefulWidget {
  final Map<String, dynamic> livre;

  const LivreConsultationPage({super.key, required this.livre});

  @override
  State<LivreConsultationPage> createState() => _LivreConsultationPageState();
}

class _LivreConsultationPageState extends State<LivreConsultationPage> {
  late bool favori;

  @override
  void initState() {
    super.initState();
    final value = widget.livre['favori'];
    favori = value == 1 || value == true || value == '1';
  }

  String lire(List<String> cles) {
    for (final cle in cles) {
      final value = widget.livre[cle];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  Future<void> basculerFavori() async {
    final id = widget.livre['id'];

    if (id is! int) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identifiant du livre invalide.')),
      );
      return;
    }

    try {
      await SQLHelper.setFavori(id, !favori);

      if (!mounted) return;

      setState(() {
        favori = !favori;
        widget.livre['favori'] = favori ? 1 : 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(favori ? 'Ajouté aux favoris' : 'Retiré des favoris'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final titre = lire(['titre', 'title', 'nom']);
    final auteur = lire(['nomEcrivain', 'ecrivain', 'auteur', 'writer']);
    final genre = lire(['genre', 'categorie', 'category']);

    final champs = widget.livre.entries.where((entry) {
      return entry.value != null &&
          ![
            'id',
            'favori',
            'ecrivainId',
            'ecrivain_id',
            'writerId',
          ].contains(entry.key) &&
          entry.value.toString().trim().isNotEmpty;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        title: const Text('Détails du livre'),
        backgroundColor: AppTheme.forest,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Favori',
            onPressed: basculerFavori,
            icon: Icon(
              favori ? Icons.favorite : Icons.favorite_border,
              color: favori ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.forest,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  size: 85,
                  color: Colors.white,
                ),
                const SizedBox(height: 18),
                Text(
                  titre.isEmpty ? 'Livre sans titre' : titre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (auteur.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Text(
                    auteur,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Informations du livre',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26352D),
            ),
          ),
          const SizedBox(height: 12),
          if (genre.isNotEmpty)
            _information('Genre', genre, Icons.category_rounded),
          ...champs.map((entry) {
            return _information(
              entry.key,
              entry.value.toString(),
              Icons.info_outline_rounded,
            );
          }),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: basculerFavori,
            icon: Icon(favori ? Icons.favorite : Icons.favorite_border),
            label: Text(favori ? 'Retirer des favoris' : 'Ajouter aux favoris'),
          ),
        ],
      ),
    );
  }

  Widget _information(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.forest),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
