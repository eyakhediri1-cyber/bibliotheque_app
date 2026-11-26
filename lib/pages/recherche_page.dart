import 'package:flutter/material.dart';

import '../database/sql_helper.dart';
import '../utils/app_theme.dart';
import '../widgets/drawer_widget.dart';
import 'livre_consultation_page.dart';

class RecherchePage extends StatefulWidget {
  const RecherchePage({super.key});

  @override
  State<RecherchePage> createState() => _RecherchePageState();
}

class _RecherchePageState extends State<RecherchePage> {
  List<Map<String, dynamic>> livres = [];
  final TextEditingController rechercheController = TextEditingController();

  String genreSelectionne = 'Tous';
  String ecrivainSelectionne = 'Tous';
  String tri = 'A-Z';
  bool favorisUniquement = false;
  bool chargement = true;

  static const clesTitre = ['titre', 'title', 'nom'];
  static const clesGenre = ['genre', 'categorie', 'category'];
  static const clesEcrivain = ['nomEcrivain', 'ecrivain', 'auteur', 'writer'];

  String lire(Map<String, dynamic> livre, List<String> cles) {
    for (final cle in cles) {
      final valeur = livre[cle];
      if (valeur != null && valeur.toString().trim().isNotEmpty) {
        return valeur.toString();
      }
    }
    return '';
  }

  bool estFavori(Map<String, dynamic> livre) {
    final valeur = livre['favori'];
    return valeur == 1 || valeur == true || valeur == '1';
  }

  @override
  void initState() {
    super.initState();
    chargerLivres();
    rechercheController.addListener(() {
      setState(() {});
    });
  }

  Future<void> chargerLivres() async {
    try {
      final resultat = await SQLHelper.getLivres();
      if (!mounted) return;

      setState(() {
        livres = resultat;
        chargement = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => chargement = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur de chargement : $e')));
    }
  }

  List<String> get genres {
    final valeurs = livres
        .map((livre) => lire(livre, clesGenre))
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
    valeurs.sort();
    return ['Tous', ...valeurs];
  }

  List<String> get ecrivains {
    final valeurs = livres
        .map((livre) => lire(livre, clesEcrivain))
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
    valeurs.sort();
    return ['Tous', ...valeurs];
  }

  List<Map<String, dynamic>> get livresFiltres {
    final terme = rechercheController.text.trim().toLowerCase();

    final resultat = livres.where((livre) {
      final correspondRecherche =
          terme.isEmpty ||
          livre.values.any(
            (valeur) =>
                valeur != null &&
                valeur.toString().toLowerCase().contains(terme),
          );

      final correspondGenre =
          genreSelectionne == 'Tous' ||
          lire(livre, clesGenre) == genreSelectionne;

      final correspondEcrivain =
          ecrivainSelectionne == 'Tous' ||
          lire(livre, clesEcrivain) == ecrivainSelectionne;

      final correspondFavori = !favorisUniquement || estFavori(livre);

      return correspondRecherche &&
          correspondGenre &&
          correspondEcrivain &&
          correspondFavori;
    }).toList();

    resultat.sort((a, b) {
      final titreA = lire(a, clesTitre).toLowerCase();
      final titreB = lire(b, clesTitre).toLowerCase();

      return tri == 'A-Z' ? titreA.compareTo(titreB) : titreB.compareTo(titreA);
    });

    return resultat;
  }

  @override
  void dispose() {
    rechercheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultats = livresFiltres;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2),
      appBar: AppBar(
        title: const Text(
          'Recherche avancée',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.forest,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: chargerLivres, icon: const Icon(Icons.refresh)),
        ],
      ),
      drawer: const MyDrawer(),
      body: chargement
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: rechercheController,
                        decoration: InputDecoration(
                          hintText: 'Titre, auteur, genre...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            onPressed: rechercheController.clear,
                            icon: const Icon(Icons.close),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _filtre(
                              'Genre',
                              genreSelectionne,
                              genres,
                              (value) =>
                                  setState(() => genreSelectionne = value!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _filtre(
                              'Écrivain',
                              ecrivainSelectionne,
                              ecrivains,
                              (value) =>
                                  setState(() => ecrivainSelectionne = value!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: tri,
                              decoration: _decoration('Trier par'),
                              items: const [
                                DropdownMenuItem(
                                  value: 'A-Z',
                                  child: Text('A → Z'),
                                ),
                                DropdownMenuItem(
                                  value: 'Z-A',
                                  child: Text('Z → A'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => tri = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilterChip(
                              selected: favorisUniquement,
                              avatar: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 18,
                              ),
                              label: const Text('Favoris'),
                              onSelected: (value) {
                                setState(() => favorisUniquement = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${resultats.length} résultat(s)',
                            style: TextStyle(
                              color: AppTheme.forest,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                rechercheController.clear();
                                genreSelectionne = 'Tous';
                                ecrivainSelectionne = 'Tous';
                                favorisUniquement = false;
                                tri = 'A-Z';
                              });
                            },
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('Réinitialiser'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: resultats.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 65,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text('Aucun livre trouvé'),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: chargerLivres,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: resultats.length,
                            itemBuilder: (context, index) {
                              final livre = resultats[index];
                              final titre = lire(livre, clesTitre);
                              final auteur = lire(livre, clesEcrivain);
                              final genre = lire(livre, clesGenre);

                              return Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.forest.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: Icon(
                                      Icons.menu_book,
                                      color: AppTheme.forest,
                                    ),
                                  ),
                                  title: Text(
                                    titre.isEmpty ? 'Sans titre' : titre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                      if (auteur.isNotEmpty) auteur,
                                      if (genre.isNotEmpty) genre,
                                    ].join(' • '),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            LivreConsultationPage(livre: livre),
                                      ),
                                    );
                                  },
                                  trailing: estFavori(livre)
                                      ? const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _filtre(
    String label,
    String selection,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final valeur = options.contains(selection) ? selection : 'Tous';

    return DropdownButtonFormField<String>(
      initialValue: valeur,
      isExpanded: true,
      decoration: _decoration(label),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
