import 'package:flutter/material.dart';

import '../database/sql_helper.dart';
import '../utils/app_theme.dart';
import '../widgets/drawer_widget.dart';
import 'livre_consultation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> livres = [];
  List<Map<String, dynamic>> ecrivains = [];
  List<Map<String, dynamic>> favoris = [];

  bool chargement = true;

  @override
  void initState() {
    super.initState();
    chargerDonnees();
  }

  Future<void> chargerDonnees() async {
    try {
      final resultats = await Future.wait([
        SQLHelper.getLivres(),
        SQLHelper.getEcrivains(),
        SQLHelper.getLivresFavoris(),
      ]);

      if (!mounted) return;

      setState(() {
        livres = resultats[0];
        ecrivains = resultats[1];
        favoris = resultats[2];
        chargement = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => chargement = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur de chargement : $e')));
    }
  }

  String titreLivre(Map<String, dynamic> livre) {
    for (final key in ['titre', 'title', 'nom']) {
      final value = livre[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return 'Livre sans titre';
  }

  String auteurLivre(Map<String, dynamic> livre) {
    for (final key in ['nomEcrivain', 'ecrivain', 'auteur', 'writer']) {
      final value = livre[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return 'Auteur non renseigné';
  }

  Widget carteIndicateur(
    String titre,
    int valeur,
    IconData icone,
    Color couleur,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: couleur.withValues(alpha: 0.12),
            child: Icon(icone, color: couleur, size: 21),
          ),
          const SizedBox(height: 13),
          Text(
            '$valeur',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26352D),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            titre,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget raccourci(
    BuildContext context,
    String titre,
    IconData icone,
    String route,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Icon(icone, color: AppTheme.forest, size: 27),
              const SizedBox(height: 8),
              Text(
                titre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        title: const Text(
          'LibraryFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.forest,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: chargerDonnees,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: chargement
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: chargerDonnees,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppTheme.forest,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue dans votre bibliothèque !',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 9),
                        Text(
                          'Organisez, découvrez et retrouvez vos livres préférés.',
                          style: TextStyle(color: Colors.white70, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Vue d’ensemble',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 13),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      carteIndicateur(
                        'Total des livres',
                        livres.length,
                        Icons.menu_book_rounded,
                        AppTheme.forest,
                      ),
                      carteIndicateur(
                        'Écrivains',
                        ecrivains.length,
                        Icons.people_alt_rounded,
                        Colors.blue,
                      ),
                      carteIndicateur(
                        'Favoris',
                        favoris.length,
                        Icons.favorite_rounded,
                        Colors.redAccent,
                      ),
                      carteIndicateur(
                        'Sans écrivain',
                        livres
                            .where((livre) => livre['ecrivainId'] == null)
                            .length,
                        Icons.bookmark_remove_rounded,
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Accès rapide',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 13),

                  Row(
                    children: [
                      raccourci(context, 'Livres', Icons.menu_book, '/livres'),
                      const SizedBox(width: 10),
                      raccourci(
                        context,
                        'Écrivains',
                        Icons.people,
                        '/ecrivains',
                      ),
                      const SizedBox(width: 10),
                      raccourci(
                        context,
                        'Recherche',
                        Icons.search,
                        '/recherche',
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Livres de la bibliothèque',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/livres'),
                        child: const Text('Tout voir'),
                      ),
                    ],
                  ),

                  if (livres.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            size: 45,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text('Votre bibliothèque est encore vide.'),
                        ],
                      ),
                    )
                  else
                    ...livres.take(5).map((livre) {
                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.forest.withValues(
                              alpha: 0.10,
                            ),
                            child: Icon(
                              Icons.menu_book,
                              color: AppTheme.forest,
                            ),
                          ),
                          title: Text(
                            titreLivre(livre),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(auteurLivre(livre)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LivreConsultationPage(livre: livre),
                              ),
                            ).then((_) => chargerDonnees());
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
