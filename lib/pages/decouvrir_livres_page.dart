import 'package:flutter/material.dart';

import '../services/google_books_service.dart';

class DecouvrirLivresPage extends StatefulWidget {
  const DecouvrirLivresPage({super.key});

  @override
  State<DecouvrirLivresPage> createState() => _DecouvrirLivresPageState();
}

class _DecouvrirLivresPageState extends State<DecouvrirLivresPage> {
  final TextEditingController _rechercheController = TextEditingController();

  List<GoogleBook> _resultats = [];
  final Set<String> _importes = {};

  bool _chargement = false;
  bool _importationEnCours = false;
  String? _erreur;

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  Future<void> _rechercher() async {
    final recherche = _rechercheController.text.trim();

    if (recherche.isEmpty) {
      _message('Saisis un titre ou un nom d’auteur.');
      return;
    }

    setState(() {
      _chargement = true;
      _erreur = null;
      _resultats = [];
      _importes.clear();
    });

    try {
      final livres = await GoogleBooksService.rechercherLivres(
        recherche,
        maxResults: 30,
      );

      if (!mounted) return;

      setState(() {
        _resultats = livres;
        _chargement = false;
      });

      if (livres.isEmpty) {
        _message('Aucun livre trouvé.');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _chargement = false;
        _erreur = 'Impossible de récupérer les livres. Vérifie ta connexion.';
      });
    }
  }

  Future<void> _importerUn(GoogleBook livre) async {
    try {
      final resultat = await GoogleBooksService.importerLivre(livre);

      if (!mounted) return;

      setState(() {
        _importes.add(livre.id);
      });

      _message(
        resultat
            ? '« ${livre.titre} » ajouté à ta bibliothèque.'
            : 'Ce livre existe déjà dans ta bibliothèque.',
      );
    } catch (e) {
      if (!mounted) return;
      _message('Erreur pendant l’importation du livre.');
    }
  }

  Future<void> _importerTout() async {
    if (_resultats.isEmpty) return;

    setState(() => _importationEnCours = true);

    try {
      final resultat = await GoogleBooksService.importerPlusieurs(_resultats);

      if (!mounted) return;

      setState(() {
        _importationEnCours = false;
        _importes.addAll(_resultats.map((livre) => livre.id));
      });

      _message(
        '${resultat['importes']} livre(s) ajouté(s), '
        '${resultat['doublons']} doublon(s) ignoré(s).',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _importationEnCours = false);
      _message('Une erreur est survenue pendant l’importation.');
    }
  }

  void _message(String texte) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texte)));
  }

  Widget _construireCouverture(GoogleBook livre) {
    if (livre.couverture.isEmpty) {
      return Container(
        width: 90,
        height: 125,
        color: Colors.grey.shade200,
        child: const Icon(Icons.menu_book, size: 38),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        livre.couverture,
        width: 90,
        height: 125,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 90,
            height: 125,
            color: Colors.grey.shade200,
            child: const Icon(Icons.menu_book, size: 38),
          );
        },
      ),
    );
  }

  Widget _construireLivre(GoogleBook livre) {
    final dejaImporte = _importes.contains(livre.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construireCouverture(livre),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    livre.titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    livre.auteur,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  if (livre.dateSortie.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Publication : ${livre.dateSortie}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  if (livre.editeur.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      livre.editeur,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                  if (livre.isbn.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ISBN : ${livre.isbn}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: dejaImporte
                        ? FilledButton.tonalIcon(
                            onPressed: null,
                            icon: Icon(Icons.check),
                            label: Text('Traité'),
                          )
                        : FilledButton.tonalIcon(
                            onPressed: () => _importerUn(livre),
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter à ma bibliothèque'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Découvrir des livres'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _rechercheController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _rechercher(),
                  decoration: InputDecoration(
                    hintText: 'Titre, auteur, ISBN...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: _rechercher,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_resultats.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _importationEnCours ? null : _importerTout,
                      icon: const Icon(Icons.library_add),
                      label: Text(
                        _importationEnCours
                            ? 'Importation en cours...'
                            : 'Importer tous les résultats',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_chargement)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_erreur != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_erreur!, textAlign: TextAlign.center),
                ),
              ),
            )
          else if (_resultats.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 65,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Découvre de nouveaux livres',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('Recherche un titre ou un auteur.'),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _resultats.length,
                itemBuilder: (context, index) {
                  return _construireLivre(_resultats[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}
