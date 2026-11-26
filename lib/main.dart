import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:bibliotheque_app/database/sql_helper.dart';
import 'package:bibliotheque_app/pages/home_page.dart';
import 'package:bibliotheque_app/pages/livres_page.dart';
import 'package:bibliotheque_app/pages/ecrivains_page.dart';
import 'package:bibliotheque_app/pages/statistiques_page.dart';
import 'package:bibliotheque_app/utils/app_theme.dart';
import 'package:bibliotheque_app/pages/favoris_page.dart';
import 'package:bibliotheque_app/pages/recherche_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  await SQLHelper.db();

  runApp(const BibliothequeApp());
}

class BibliothequeApp extends StatelessWidget {
  const BibliothequeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LibraryFlow',
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/livres': (context) => const LivresPage(),
        '/ecrivains': (context) => const EcrivainsPage(),
        '/statistiques': (context) => const StatistiquesPage(),
        '/favoris': (context) => const FavorisPage(),
        '/recherche': (context) => const RecherchePage(),
      },
    );
  }
}
