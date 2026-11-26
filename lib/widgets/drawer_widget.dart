import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      backgroundColor: AppTheme.forest,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 25),
            const CircleAvatar(
              radius: 38,
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.local_library_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'LibraryFlow',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Votre bibliothèque, autrement.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 35),

            _menuItem(
              context,
              Icons.dashboard_rounded,
              'Accueil',
              '/home',
              currentRoute,
            ),

            _menuItem(
              context,
              Icons.menu_book_rounded,
              'Gestion des livres',
              '/livres',
              currentRoute,
            ),
            _menuItem(
              context,
              Icons.search_rounded,
              'Recherche avancée',
              '/recherche',
              currentRoute,
            ),

            _menuItem(
              context,
              Icons.people_alt_rounded,
              'Gestion des écrivains',
              '/ecrivains',
              currentRoute,
            ),

            _menuItem(
              context,
              Icons.favorite_rounded,
              'Mes favoris',
              '/favoris',
              currentRoute,
            ),

            _menuItem(
              context,
              Icons.bar_chart_rounded,
              'Statistiques',
              '/statistiques',
              currentRoute,
            ),

            const Spacer(),
            const Divider(color: Colors.white24, indent: 20, endIndent: 20),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'LIBRARYFLOW • VERSION 1.0',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
    String? currentRoute,
  ) {
    final selected = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        selected: selected,
        selectedTileColor: Colors.white.withValues(alpha: 0.14),
        leading: Icon(
          icon,
          color: selected ? const Color(0xFFE4C58C) : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (!selected) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
