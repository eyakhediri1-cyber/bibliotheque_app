import 'package:flutter/material.dart';

import '../database/sql_helper.dart';
import '../utils/app_theme.dart';
import '../widgets/drawer_widget.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key});

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  Map<String, int> statistiques = {};
  List<Map<String, dynamic>> statistiquesEcrivains = [];

  bool loading = true;
  String? erreur;

  @override
  void initState() {
    super.initState();
    chargerStatistiques();
  }

  Future<void> chargerStatistiques() async {
    setState(() {
      loading = true;
      erreur = null;
    });

    try {
      final resultats = await Future.wait([
        SQLHelper.getStatistiquesGenerales(),
        SQLHelper.getStatistiquesEcrivains(),
      ]);

      if (!mounted) return;

      setState(() {
        statistiques = Map<String, int>.from(resultats[0] as Map);

        statistiquesEcrivains = List<Map<String, dynamic>>.from(
          resultats[1] as List,
        );

        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erreur = e.toString();
        loading = false;
      });
    }
  }

  int lireStat(List<String> cles) {
    for (final cle in cles) {
      if (statistiques.containsKey(cle)) {
        return statistiques[cle] ?? 0;
      }
    }
    return 0;
  }

  String lireTexte(Map<String, dynamic> element, List<String> cles) {
    for (final cle in cles) {
      final valeur = element[cle];
      if (valeur != null && valeur.toString().trim().isNotEmpty) {
        return valeur.toString();
      }
    }
    return '';
  }

  Widget carteStatistique({
    required String titre,
    required int valeur,
    required IconData icone,
    required Color couleur,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: couleur.withValues(alpha: 0.12),
            child: Icon(icone, color: couleur),
          ),
          const SizedBox(height: 15),
          Text(
            valeur.toString(),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26352D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            titre,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalLivres = lireStat(['totalLivres', 'livres', 'total_livres']);

    final totalEcrivains = lireStat([
      'totalEcrivains',
      'ecrivains',
      'total_ecrivains',
    ]);

    final totalFavoris = lireStat(['totalFavoris', 'favoris', 'total_favoris']);

    final sansEcrivain = lireStat([
      'livresSansEcrivain',
      'sansEcrivain',
      'livres_sans_ecrivain',
    ]);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        title: const Text(
          'Statistiques',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.forest,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: chargerStatistiques,
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : erreur != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Impossible de charger les statistiques',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      erreur!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: chargerStatistiques,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: chargerStatistiques,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'Vue d’ensemble',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF26352D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Découvrez les chiffres de votre bibliothèque.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 13,
                    mainAxisSpacing: 13,
                    childAspectRatio: 1.25,
                    children: [
                      carteStatistique(
                        titre: 'Total des livres',
                        valeur: totalLivres,
                        icone: Icons.menu_book_rounded,
                        couleur: AppTheme.forest,
                      ),
                      carteStatistique(
                        titre: 'Écrivains',
                        valeur: totalEcrivains,
                        icone: Icons.people_alt_rounded,
                        couleur: Colors.blue,
                      ),
                      carteStatistique(
                        titre: 'Livres favoris',
                        valeur: totalFavoris,
                        icone: Icons.favorite_rounded,
                        couleur: Colors.redAccent,
                      ),
                      carteStatistique(
                        titre: 'Sans écrivain',
                        valeur: sansEcrivain,
                        icone: Icons.bookmark_remove_rounded,
                        couleur: Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Livres par écrivain',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF26352D),
                    ),
                  ),
                  const SizedBox(height: 13),

                  if (statistiquesEcrivains.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Aucune donnée disponible pour le moment.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...statistiquesEcrivains.map((element) {
                      final nom = lireTexte(element, [
                        'nom',
                        'name',
                        'nomEcrivain',
                      ]);

                      final nombre =
                          int.tryParse(
                            lireTexte(element, [
                              'totalLivres',
                              'nombreLivres',
                              'total',
                            ]),
                          ) ??
                          0;

                      final proportion = totalLivres == 0
                          ? 0.0
                          : (nombre / totalLivres).clamp(0.0, 1.0);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    nom.isEmpty ? 'Écrivain' : nom,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$nombre livre(s)',
                                  style: TextStyle(
                                    color: AppTheme.forest,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: proportion,
                                minHeight: 9,
                                backgroundColor: Colors.grey.shade200,
                                color: AppTheme.forest,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
