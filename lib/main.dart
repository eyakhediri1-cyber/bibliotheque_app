import 'package:flutter/material.dart';
import 'package:bibliotheque_app/pages/home_page.dart';
import 'package:bibliotheque_app/pages/livres_page.dart';
import 'package:bibliotheque_app/pages/ecrivains_page.dart';
import 'package:bibliotheque_app/utils/app_theme.dart';
import 'package:bibliotheque_app/database/sql_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SQLHelper.db();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      },
    );
  }
}
