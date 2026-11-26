import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:bibliotheque_app/database/sql_helper.dart';
import 'package:bibliotheque_app/widgets/drawer_widget.dart';

class EcrivainsPage extends StatefulWidget {
  const EcrivainsPage({super.key});

  @override
  State<EcrivainsPage> createState() => _EcrivainsPageState();
}

class _EcrivainsPageState extends State<EcrivainsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _ecrivains = [];
  bool _isLoading = true;

  static const Color forest = Color(0xFF183F35);
  static const Color green = Color(0xFF477A60);
  static const Color cream = Color(0xFFF7F5EF);

  @override
  void initState() {
    super.initState();
    _loadEcrivains();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEcrivains([String query = '']) async {
    setState(() => _isLoading = true);

    final data = query.trim().isEmpty
        ? await SQLHelper.getEcrivains()
        : await SQLHelper.searchEcrivains(query.trim());

    if (!mounted) return;

    setState(() {
      _ecrivains = data;
      _isLoading = false;
    });
  }

  Future<void> _showForm({Map<String, dynamic>? ecrivain}) async {
    final nomController = TextEditingController(text: ecrivain?['nom'] ?? '');
    final prenomController = TextEditingController(
      text: ecrivain?['prenom'] ?? '',
    );
    final telController = TextEditingController(text: ecrivain?['tel'] ?? '');

    final formKey = GlobalKey<FormState>();
    final isEditing = ecrivain != null;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            isEditing ? 'Modifier l’écrivain' : 'Nouvel écrivain',
            style: const TextStyle(color: forest, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formField(nomController, 'Nom', Icons.person_outline),
                  const SizedBox(height: 14),
                  _formField(prenomController, 'Prénom', Icons.badge_outlined),
                  const SizedBox(height: 14),
                  _formField(
                    telController,
                    'Téléphone',
                    Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
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
                  await SQLHelper.updateEcrivain(
                    ecrivain['id'] as int,
                    nomController.text.trim(),
                    prenomController.text.trim(),
                    telController.text.trim(),
                  );
                } else {
                  await SQLHelper.createEcrivain(
                    nomController.text.trim(),
                    prenomController.text.trim(),
                    telController.text.trim(),
                  );
                }

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                await _loadEcrivains(_searchController.text);
                _showMessage(
                  isEditing
                      ? 'Écrivain modifié avec succès'
                      : 'Écrivain ajouté avec succès',
                );
              },
              child: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
            ),
          ],
        );
      },
    );

    nomController.dispose();
    prenomController.dispose();
    telController.dispose();
  }

  Widget _formField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ce champ est obligatoire';
        }
        return null;
      },
    );
  }

  Future<void> _deleteEcrivain(Map<String, dynamic> ecrivain) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous supprimer ${ecrivain['prenom']} ${ecrivain['nom']} ?',
        ),
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
      await SQLHelper.deleteEcrivain(ecrivain['id'] as int);
      await _loadEcrivains(_searchController.text);
      _showMessage('Écrivain supprimé');
    }
  }

  Future<void> _callEcrivain(String tel) async {
    try {
      await FlutterPhoneDirectCaller.callNumber(tel);
    } catch (e) {
      _showMessage('Impossible de lancer l’appel');
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
          'Écrivains',
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
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Ajouter'),
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
                  'Les talents derrière les livres.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: _loadEcrivains,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un écrivain...',
                    hintStyle: const TextStyle(color: Colors.white60),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        _loadEcrivains();
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: green))
                : _ecrivains.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
                    itemCount: _ecrivains.length,
                    itemBuilder: (context, index) {
                      final ecrivain = _ecrivains[index];
                      return _ecrivainCard(ecrivain);
                    },
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
              Icons.people_outline,
              size: 65,
              color: green.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 15),
            const Text(
              'Aucun écrivain trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: forest,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Ajoutez votre premier écrivain pour commencer votre bibliothèque.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ecrivainCard(Map<String, dynamic> ecrivain) {
    final nomComplet = '${ecrivain['prenom']} ${ecrivain['nom']}';
    final initials =
        '${ecrivain['prenom'].toString().isNotEmpty ? ecrivain['prenom'].toString()[0] : ''}'
        '${ecrivain['nom'].toString().isNotEmpty ? ecrivain['nom'].toString()[0] : ''}';

    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor: green.withValues(alpha: 0.13),
              child: Text(
                initials.toUpperCase(),
                style: const TextStyle(
                  color: forest,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomComplet,
                    style: const TextStyle(
                      color: forest,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: green),
                      const SizedBox(width: 5),
                      Text(
                        ecrivain['tel'].toString(),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Appeler',
              onPressed: () => _callEcrivain(ecrivain['tel'].toString()),
              icon: const Icon(Icons.call, color: green),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onSelected: (value) {
                if (value == 'edit') {
                  _showForm(ecrivain: ecrivain);
                } else if (value == 'delete') {
                  _deleteEcrivain(ecrivain);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, color: forest),
                      SizedBox(width: 10),
                      Text('Modifier'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Supprimer'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
