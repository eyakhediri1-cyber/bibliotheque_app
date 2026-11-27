import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../database/sql_helper.dart';
import 'catalogue_cover_stub.dart'
    if (dart.library.io) 'catalogue_cover_io.dart'
    as cover;

class CatalogueInitialService {
  static const int objectif = 40;
  static const String _cle = 'libraryflow_catalogue_initial_v1';

  // Catalogue local : aucune API nécessaire.
  static const List<Map<String, String?>> _catalogue = [
    {
      'titre': '1984',
      'auteur': 'George Orwell',
      'isbn': '9780451524935',
      'date': '1949',
    },
    {
      'titre': 'Animal Farm',
      'auteur': 'George Orwell',
      'isbn': '9780451526342',
      'date': '1945',
    },
    {
      'titre': 'The Great Gatsby',
      'auteur': 'F. Scott Fitzgerald',
      'isbn': '9780743273565',
      'date': '1925',
    },
    {
      'titre': 'To Kill a Mockingbird',
      'auteur': 'Harper Lee',
      'isbn': '9780061120084',
      'date': '1960',
    },
    {
      'titre': 'The Catcher in the Rye',
      'auteur': 'J. D. Salinger',
      'isbn': '9780316769488',
      'date': '1951',
    },
    {
      'titre': 'The Hobbit',
      'auteur': 'J. R. R. Tolkien',
      'isbn': '9780547928227',
      'date': '1937',
    },
    {
      'titre': 'Harry Potter and the Philosopher\'s Stone',
      'auteur': 'J. K. Rowling',
      'isbn': '9780590353427',
      'date': '1997',
    },
    {
      'titre': 'The Fellowship of the Ring',
      'auteur': 'J. R. R. Tolkien',
      'isbn': '9780544003415',
      'date': '1954',
    },
    {
      'titre': 'Pride and Prejudice',
      'auteur': 'Jane Austen',
      'isbn': '9780141439518',
      'date': '1813',
    },
    {
      'titre': 'Jane Eyre',
      'auteur': 'Charlotte Bronte',
      'isbn': '9780141441146',
      'date': '1847',
    },
    {
      'titre': 'Wuthering Heights',
      'auteur': 'Emily Bronte',
      'isbn': '9780141439556',
      'date': '1847',
    },
    {
      'titre': 'Little Women',
      'auteur': 'Louisa May Alcott',
      'isbn': '9780147514011',
      'date': '1868',
    },
    {
      'titre': 'The Alchemist',
      'auteur': 'Paulo Coelho',
      'isbn': '9780061122415',
      'date': '1988',
    },
    {
      'titre': 'Sapiens',
      'auteur': 'Yuval Noah Harari',
      'isbn': '9780062316097',
      'date': '2011',
    },
    {
      'titre': 'Atomic Habits',
      'auteur': 'James Clear',
      'isbn': '9780735211292',
      'date': '2018',
    },
    {
      'titre': 'How to Win Friends and Influence People',
      'auteur': 'Dale Carnegie',
      'isbn': '9780671027032',
      'date': '1936',
    },
    {
      'titre': 'Think and Grow Rich',
      'auteur': 'Napoleon Hill',
      'isbn': '9781585424337',
      'date': '1937',
    },
    {
      'titre': 'Rich Dad Poor Dad',
      'auteur': 'Robert Kiyosaki',
      'isbn': '9781612680194',
      'date': '1997',
    },
    {
      'titre': 'Deep Work',
      'auteur': 'Cal Newport',
      'isbn': '9781455586691',
      'date': '2016',
    },
    {
      'titre': 'Clean Code',
      'auteur': 'Robert C. Martin',
      'isbn': '9780132350884',
      'date': '2008',
    },
    {
      'titre': 'Design Patterns',
      'auteur': 'Erich Gamma',
      'isbn': '9780201633610',
      'date': '1994',
    },
    {
      'titre': 'The Pragmatic Programmer',
      'auteur': 'David Thomas',
      'isbn': '9780135957059',
      'date': '2019',
    },
    {
      'titre': 'Introduction to Algorithms',
      'auteur': 'Thomas H. Cormen',
      'isbn': '9780262046305',
      'date': '2022',
    },
    {
      'titre': 'Python Crash Course',
      'auteur': 'Eric Matthes',
      'isbn': '9781593279288',
      'date': '2019',
    },
    {
      'titre': 'Clean Architecture',
      'auteur': 'Robert C. Martin',
      'isbn': '9780134494166',
      'date': '2017',
    },
    {
      'titre': 'The Lean Startup',
      'auteur': 'Eric Ries',
      'isbn': '9780307887894',
      'date': '2011',
    },
    {
      'titre': 'Zero to One',
      'auteur': 'Peter Thiel',
      'isbn': '9780804139298',
      'date': '2014',
    },
    {
      'titre': 'The Intelligent Investor',
      'auteur': 'Benjamin Graham',
      'isbn': '9780060555665',
      'date': '1949',
    },
    {
      'titre': 'A Brief History of Time',
      'auteur': 'Stephen Hawking',
      'isbn': '9780553380163',
      'date': '1988',
    },
    {
      'titre': 'Cosmos',
      'auteur': 'Carl Sagan',
      'isbn': '9780345539434',
      'date': '1980',
    },
    {
      'titre': 'Educated',
      'auteur': 'Tara Westover',
      'isbn': '9780399590504',
      'date': '2018',
    },
    {
      'titre': 'Becoming',
      'auteur': 'Michelle Obama',
      'isbn': '9781524763138',
      'date': '2018',
    },
    {
      'titre': 'The Kite Runner',
      'auteur': 'Khaled Hosseini',
      'isbn': '9781594631931',
      'date': '2003',
    },
    {
      'titre': 'Life of Pi',
      'auteur': 'Yann Martel',
      'isbn': '9780156027328',
      'date': '2001',
    },
    {
      'titre': 'The Book Thief',
      'auteur': 'Markus Zusak',
      'isbn': '9780375842207',
      'date': '2005',
    },
    {
      'titre': 'The Little Prince',
      'auteur': 'Antoine de Saint-Exupery',
      'isbn': '9780156012195',
      'date': '1943',
    },
    {
      'titre': 'Dune',
      'auteur': 'Frank Herbert',
      'isbn': '9780441172719',
      'date': '1965',
    },
    {
      'titre': 'Fahrenheit 451',
      'auteur': 'Ray Bradbury',
      'isbn': '9781451673319',
      'date': '1953',
    },
    {
      'titre': 'Brave New World',
      'auteur': 'Aldous Huxley',
      'isbn': '9780060850524',
      'date': '1932',
    },
    {
      'titre': 'The Handmaid\'s Tale',
      'auteur': 'Margaret Atwood',
      'isbn': '9780385490818',
      'date': '1985',
    },
    {
      'titre': 'The Midnight Library',
      'auteur': 'Matt Haig',
      'isbn': null,
      'date': '2020',
    },
  ];

  static Future<int> initialiser() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final db = await SQLHelper.db();

      final nombreActuel =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM livres'),
          ) ??
          0;

      if (nombreActuel >= objectif) {
        await preferences.setBool(_cle, true);
        debugPrint('LibraryFlow : catalogue déjà complet ($nombreActuel).');
        return 0;
      }

      debugPrint('LibraryFlow : initialisation du catalogue local...');

      final livresExistants = await db.query(
        'livres',
        columns: ['titre', 'isbn'],
      );

      final titresExistants = livresExistants
          .map((e) => _normaliser(e['titre']?.toString() ?? ''))
          .toSet();

      final isbnExistants = livresExistants
          .map((e) => e['isbn']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toSet();

      final colonnesLivres = await _colonnes(db, 'livres');

      int ajoutes = 0;

      for (final livre in _catalogue) {
        if (nombreActuel + ajoutes >= objectif) break;

        final titre = livre['titre']!;
        final auteur = livre['auteur']!;
        final isbn = livre['isbn'];

        final titreNormalise = _normaliser(titre);

        if (titresExistants.contains(titreNormalise)) continue;

        if (isbn != null && isbnExistants.contains(isbn)) continue;

        final parties = auteur.split(RegExp(r'\s+'));
        final prenom = parties.length > 1 ? parties.first : '';
        final nom = parties.length > 1
            ? parties.skip(1).join(' ')
            : parties.first;

        final ecrivainId = await _obtenirOuCreerEcrivain(db, nom, prenom);

        String? photo;

        if (isbn != null && !kIsWeb) {
          try {
            photo = await cover.telechargerCouverture(
              'https://covers.openlibrary.org/b/isbn/$isbn-L.jpg',
              isbn,
            );
          } catch (e) {
            debugPrint('Couverture indisponible pour $titre : $e');
          }
        }

        final donnees = <String, dynamic>{
          'titre': titre,
          'isbn': isbn,
          'dateSortie': livre['date'],
          'photo': photo,
          'ecrivainId': ecrivainId,
          'favori': 0,
        };

        donnees.removeWhere((cle, valeur) => !colonnesLivres.contains(cle));

        final id = await db.insert(
          'livres',
          donnees,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );

        if (id > 0) {
          ajoutes++;
          titresExistants.add(titreNormalise);
          if (isbn != null) isbnExistants.add(isbn);
          debugPrint('Livre ajouté : $titre');
        }
      }

      final totalFinal =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM livres'),
          ) ??
          0;

      if (totalFinal >= objectif) {
        await preferences.setBool(_cle, true);
      }

      debugPrint('LibraryFlow : $ajoutes livres ajoutés.');
      debugPrint('LibraryFlow : $totalFinal livres au total.');

      return ajoutes;
    } catch (e, stack) {
      debugPrint('Erreur préchargement LibraryFlow : $e');
      debugPrintStack(stackTrace: stack);
      return 0;
    }
  }

  static Future<int> _obtenirOuCreerEcrivain(
    Database db,
    String nom,
    String prenom,
  ) async {
    final existant = await db.query(
      'ecrivains',
      columns: ['id'],
      where: 'LOWER(nom) = ? AND LOWER(prenom) = ?',
      whereArgs: [nom.toLowerCase(), prenom.toLowerCase()],
      limit: 1,
    );

    if (existant.isNotEmpty) {
      return existant.first['id'] as int;
    }

    final colonnes = await _colonnes(db, 'ecrivains');

    final donnees = <String, dynamic>{'nom': nom, 'prenom': prenom, 'tel': ''};

    donnees.removeWhere((cle, valeur) => !colonnes.contains(cle));

    return db.insert('ecrivains', donnees);
  }

  static Future<Set<String>> _colonnes(Database db, String table) async {
    final resultats = await db.rawQuery('PRAGMA table_info($table)');
    return resultats.map((e) => e['name'].toString()).toSet();
  }

  static String _normaliser(String texte) {
    return texte.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
