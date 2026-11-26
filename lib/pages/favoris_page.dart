import 'package:flutter/material.dart';

import '../database/sql_helper.dart';
import '../widgets/drawer_widget.dart';
import '../utils/app_theme.dart';

class FavorisPage extends StatefulWidget {
  const FavorisPage({super.key});

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
  List<Map<String, dynamic>> favoris = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    chargerFavoris();
  }

  Future<void> chargerFavoris() async {
    final result = await SQLHelper.getLivresFavoris();

    if (!mounted) return;

    setState(() {
      favoris = result;
      loading = false;
    });
  }

  Future<void> retirerFavori(int id) async {
    await SQLHelper.setFavori(id, false);
    await chargerFavoris();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Livre retiré des favoris'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String valeur(Map<String, dynamic> livre, List<String> cles) {
    for (final cle in cles) {
      final value = livre[cle];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F2),
      appBar: AppBar(
        title: const Text(
          'Mes favoris',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.forest,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : favoris.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 75,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Aucun favori pour le moment',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ajoutez vos livres préférés ici.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: chargerFavoris,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoris.length,
                itemBuilder: (context, index) {
                  final livre = favoris[index];

                  final id = livre['id'] as int;
                  final titre = valeur(livre, ['titre', 'title', 'nom']);
                  final auteur = valeur(livre, [
                    'auteur',
                    'ecrivain',
                    'nomEcrivain',
                  ]);
                  final genre = valeur(livre, ['genre', 'categorie']);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 13),
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: AppTheme.forest.withValues(
                          alpha: 0.10,
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: AppTheme.forest,
                        ),
                      ),
                      title: Text(
                        titre.isEmpty ? 'Livre sans titre' : titre,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          [
                            if (auteur.isNotEmpty) auteur,
                            if (genre.isNotEmpty) genre,
                          ].join(' • '),
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: 'Retirer des favoris',
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => retirerFavori(id),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
