import 'package:flutter/material.dart';
import 'package:bibliotheque_app/database/sql_helper.dart';
import 'package:bibliotheque_app/widgets/drawer_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color forest = Color(0xFF183F35);
  static const Color green = Color(0xFF477A60);
  static const Color cream = Color(0xFFF7F5EF);
  static const Color gold = Color(0xFFC49A55);

  int _livres = 0;
  int _ecrivains = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final results = await Future.wait([
        SQLHelper.countLivres(),
        SQLHelper.countEcrivains(),
      ]);

      if (!mounted) return;

      setState(() {
        _livres = results[0];
        _ecrivains = results[1];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openPage(String route) async {
    await Navigator.pushNamed(context, route);
    if (mounted) _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      drawer: const MyDrawer(),
      appBar: AppBar(
        backgroundColor: forest,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'LibraryFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: forest,
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeCard(),
              const SizedBox(height: 28),
              const Text(
                'Vue d’ensemble',
                style: TextStyle(
                  color: forest,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: 'Livres',
                      value: _livres,
                      icon: Icons.menu_book_rounded,
                      color: green,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: _statCard(
                      title: 'Écrivains',
                      value: _ecrivains,
                      icon: Icons.people_alt_rounded,
                      color: gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text(
                'Votre bibliothèque',
                style: TextStyle(
                  color: forest,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _navigationCard(
                icon: Icons.menu_book_rounded,
                title: 'Gestion des livres',
                description: 'Ajouter, consulter et organiser vos livres',
                onTap: () => _openPage('/livres'),
              ),
              const SizedBox(height: 12),
              _navigationCard(
                icon: Icons.people_alt_rounded,
                title: 'Gestion des écrivains',
                description: 'Gérer les auteurs et leurs coordonnées',
                onTap: () => _openPage('/ecrivains'),
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: gold, size: 28),
                    SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        'Une bibliothèque bien organisée commence par une collection bien renseignée.',
                        style: TextStyle(
                          color: forest,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [forest, green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: forest.withValues(alpha: 0.18),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_stories_rounded, color: Colors.white, size: 35),
          SizedBox(height: 19),
          Text(
            'Bienvenue dans votre bibliothèque !',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Centralisez vos livres et les informations de leurs écrivains dans un seul espace.',
            style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 15),
          Text(
            _loading ? '...' : value.toString(),
            style: const TextStyle(
              color: forest,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _navigationCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: forest, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: forest,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: green, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
