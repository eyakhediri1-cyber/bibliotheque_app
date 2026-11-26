import 'dart:io';

import 'package:flutter/material.dart';

import 'livre_detail_page.dart';

import 'package:bibliotheque_app/database/sql_helper.dart';
import 'package:bibliotheque_app/widgets/drawer_widget.dart';
import 'package:bibliotheque_app/widgets/couverture_picker.dart';

class LivresPage extends StatefulWidget {
  const LivresPage({super.key});

  @override
  State<LivresPage> createState() => _LivresPageState();
}

class _LivresPageState extends State<LivresPage> {
  bool _afficherFavoris = false;

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _livres = [];
  bool _isLoading = true;

  static const Color forest = Color(0xFF183F35);
  static const Color green = Color(0xFF477A60);
  static const Color cream = Color(0xFFF7F5EF);

  @override
  void initState() {
    super.initState();
    _loadLivres();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavori(Map<String, dynamic> livre) async {
    final id = livre['id'] as int?;
    if (id == null) return;

    final actuel = (livre['favori'] ?? 0) == 1;

    await SQLHelper.setFavori(id, !actuel);

    if (!mounted) return;

    setState(() {
      livre['favori'] = actuel ? 0 : 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          actuel ? 'Livre retiré des favoris' : 'Livre ajouté aux favoris',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _loadLivres([String query = '']) async {
    setState(() => _isLoading = true);

    final data = query.trim().isEmpty
        ? await SQLHelper.getLivres()
        : await SQLHelper.searchLivres(query.trim());

    if (!mounted) return;

    setState(() {
      _livres = data;
      _isLoading = false;
    });
  }

  Future<void> _showForm({Map<String, dynamic>? livre}) async {
    final titreController = TextEditingController(text: livre?['titre'] ?? '');
    final isbnController = TextEditingController(text: livre?['isbn'] ?? '');

    final formKey = GlobalKey<FormState>();
    final isEditing = livre != null;

    String dateSortie = livre?['dateSortie'] ?? '';
    String? photo = livre?['photo'];
    int? selectedWriter = livre?['ecrivainId'];

    List<Map<String, dynamic>> writers = await SQLHelper.getEcrivains();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                isEditing ? 'Modifier le livre' : 'Nouveau livre',
                style: const TextStyle(
                  color: forest,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CouverturePicker(
                        initialImage: photo,
                        initialQuery: titreController.text,
                        onChanged: (value) {
                          setDialogState(() => photo = value);
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: titreController,
                        decoration: const InputDecoration(
                          labelText: 'Titre du livre *',
                          prefixIcon: Icon(Icons.menu_book_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Le titre est obligatoire'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: isbnController,
                        decoration: const InputDecoration(
                          labelText: 'ISBN',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int?>(
                        initialValue: selectedWriter,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Écrivain',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Non attribué'),
                          ),
                          ...writers.map(
                            (writer) => DropdownMenuItem<int?>(
                              value: writer['id'] as int,
                              child: Text(
                                '${writer['prenom']} ${writer['nom']}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() => selectedWriter = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.tryParse(dateSortie) ?? DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setDialogState(() {
                              dateSortie =
                                  '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          dateSortie.isEmpty
                              ? 'Choisir la date de sortie'
                              : 'Date : $dateSortie',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: forest,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    if (isEditing) {
                      await SQLHelper.updateLivre(
                        livre['id'] as int,
                        titreController.text.trim(),
                        isbnController.text.trim(),
                        dateSortie,
                        photo,
                        selectedWriter,
                      );
                    } else {
                      await SQLHelper.createLivre(
                        titreController.text.trim(),
                        isbnController.text.trim(),
                        dateSortie,
                        photo,
                        selectedWriter,
                      );
                    }

                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    await _loadLivres(_searchController.text);
                    _showMessage(isEditing ? 'Livre modifié' : 'Livre ajouté');
                  },
                  child: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );

    titreController.dispose();
    isbnController.dispose();
  }

  Future<void> _deleteLivre(Map<String, dynamic> livre) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer ce livre ?'),
        content: Text('Voulez-vous supprimer "${livre['titre']}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SQLHelper.deleteLivre(livre['id'] as int);
      await _loadLivres(_searchController.text);
      _showMessage('Livre supprimé');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: forest,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text(
          'Ma bibliothèque',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: forest,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: forest,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un livre'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            decoration: const BoxDecoration(
              color: forest,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chaque livre, une nouvelle histoire.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: _loadLivres,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un titre ou ISBN...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        _loadLivres();
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Tous'),
                  icon: Icon(Icons.menu_book),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Favoris'),
                  icon: Icon(Icons.favorite),
                ),
              ],
              selected: {_afficherFavoris},
              onSelectionChanged: (selection) {
                setState(() => _afficherFavoris = selection.first);
                _loadLivres(_searchController.text);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: green))
                : _livres.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
                    itemCount: _livres.length,
                    itemBuilder: (context, index) => _livreCard(_livres[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 65,
              color: green.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 15),
            const Text(
              'Votre bibliothèque est vide',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: forest,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Ajoutez votre premier livre pour commencer votre collection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivreCover(String? photo) {
    if (photo == null || photo.isEmpty) {
      return Container(
        color: cream,
        child: const Icon(Icons.menu_book, color: green, size: 35),
      );
    }

    if (photo.startsWith('base64:')) {
      final bytes = SQLHelper.decoderCouverture(photo);

      if (bytes != null) {
        return Image.memory(bytes, fit: BoxFit.cover);
      }
    }

    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return Image.network(
        photo,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: cream,
          child: const Icon(Icons.menu_book, color: green),
        ),
      );
    }

    final file = File(photo);

    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }

    return Container(
      color: cream,
      child: const Icon(Icons.menu_book, color: green),
    );
  }

  Widget _livreCard(Map<String, dynamic> livre) {
    final photo = livre['photo'] as String?;
    final writer = livre['nomEcrivain'] == null
        ? 'Écrivain non attribué'
        : '${livre['prenomEcrivain']} ${livre['nomEcrivain']}';

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: SizedBox(
                width: 76,
                height: 100,
                child: _buildLivreCover(photo),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    livre['titre'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: forest,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    writer,
                    style: const TextStyle(color: green, fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  if ((livre['isbn'] ?? '').toString().isNotEmpty)
                    Text(
                      'ISBN : ${livre['isbn']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  if ((livre['dateSortie'] ?? '').toString().isNotEmpty)
                    Text(
                      'Sortie : ${livre['dateSortie']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Voir les détails',
                  icon: const Icon(Icons.visibility_outlined, color: forest),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LivreDetailPage(livre: livre),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Favoris',
                  onPressed: () => _toggleFavori(livre),
                  icon: Icon(
                    (livre['favori'] ?? 0) == 1
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: (livre['favori'] ?? 0) == 1
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showForm(livre: livre);
                    } else if (value == 'delete') {
                      _deleteLivre(livre);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Modifier')),
                    PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
