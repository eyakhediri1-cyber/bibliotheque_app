import 'dart:convert';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Database? _database;

  static Future<Database> db() async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'libraryflow.db');

    _database = await openDatabase(
      path,
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE ecrivains (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            tel TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE livres (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titre TEXT NOT NULL,
            isbn TEXT,
            dateSortie TEXT,
            photo TEXT,
            ecrivainId INTEGER,
            favori INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(ecrivainId)
              REFERENCES ecrivains(id)
              ON DELETE SET NULL
          )
        ''');

        await database.execute(
          'CREATE INDEX idx_livres_titre ON livres(titre)',
        );
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute(
            'ALTER TABLE livres ADD COLUMN favori INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );

    return _database!;
  }

  // ================= COUVERTURES =================

  // Enregistre une image dans un format compatible Chrome et Android.
  static String encoderCouverture(Uint8List bytes) {
    return 'base64:${base64Encode(bytes)}';
  }

  // Décode une couverture enregistrée dans SQLite.
  static Uint8List? decoderCouverture(String? photo) {
    if (photo == null || photo.isEmpty) return null;

    try {
      if (photo.startsWith('base64:')) {
        return base64Decode(photo.substring(7));
      }

      if (photo.startsWith('data:image/')) {
        final separator = photo.indexOf(',');
        if (separator == -1) return null;
        return base64Decode(photo.substring(separator + 1));
      }
    } catch (_) {
      return null;
    }

    // Les anciennes photos enregistrées sous forme de chemin
    // restent intactes dans la base de données.
    return null;
  }

  // ================= ECRIVAINS =================

  static Future<int> createEcrivain(
    String nom,
    String prenom,
    String tel,
  ) async {
    final database = await db();
    return database.insert('ecrivains', {
      'nom': nom,
      'prenom': prenom,
      'tel': tel,
    });
  }

  static Future<List<Map<String, dynamic>>> getEcrivains() async {
    final database = await db();
    return database.query('ecrivains', orderBy: 'nom ASC, prenom ASC');
  }

  static Future<List<Map<String, dynamic>>> searchEcrivains(
    String recherche,
  ) async {
    final database = await db();
    return database.query(
      'ecrivains',
      where: 'nom LIKE ? OR prenom LIKE ? OR tel LIKE ?',
      whereArgs: ['%$recherche%', '%$recherche%', '%$recherche%'],
      orderBy: 'nom ASC',
    );
  }

  static Future<int> updateEcrivain(
    int id,
    String nom,
    String prenom,
    String tel,
  ) async {
    final database = await db();
    return database.update(
      'ecrivains',
      {'nom': nom, 'prenom': prenom, 'tel': tel},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteEcrivain(int id) async {
    final database = await db();
    return database.delete('ecrivains', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> countEcrivains() async {
    final database = await db();
    final result = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM ecrivains',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ================= LIVRES =================

  static Future<int> createLivre(
    String titre,
    String isbn,
    String dateSortie,
    String? photo,
    int? ecrivainId,
  ) async {
    final database = await db();
    return database.insert('livres', {
      'titre': titre,
      'isbn': isbn,
      'dateSortie': dateSortie,
      'photo': photo,
      'ecrivainId': ecrivainId,
    });
  }

  static Future<List<Map<String, dynamic>>> getLivres() async {
    final database = await db();
    return database.rawQuery('''
      SELECT livres.*, ecrivains.nom AS nomEcrivain,
             ecrivains.prenom AS prenomEcrivain
      FROM livres
      LEFT JOIN ecrivains ON livres.ecrivainId = ecrivains.id
      ORDER BY livres.titre ASC
    ''');
  }

  static Future<List<Map<String, dynamic>>> searchLivres(
    String recherche,
  ) async {
    final database = await db();
    return database.rawQuery(
      '''
      SELECT livres.*, ecrivains.nom AS nomEcrivain,
             ecrivains.prenom AS prenomEcrivain
      FROM livres
      LEFT JOIN ecrivains ON livres.ecrivainId = ecrivains.id
      WHERE livres.titre LIKE ? OR livres.isbn LIKE ?
      ORDER BY livres.titre ASC
    ''',
      ['%$recherche%', '%$recherche%'],
    );
  }

  static Future<int> updateLivre(
    int id,
    String titre,
    String isbn,
    String dateSortie,
    String? photo,
    int? ecrivainId,
  ) async {
    final database = await db();
    return database.update(
      'livres',
      {
        'titre': titre,
        'isbn': isbn,
        'dateSortie': dateSortie,
        'photo': photo,
        'ecrivainId': ecrivainId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteLivre(int id) async {
    final database = await db();
    return database.delete('livres', where: 'id = ?', whereArgs: [id]);
  }

  // ================= FAVORIS =================

  static Future<int> setFavori(int id, bool favori) async {
    final database = await db();

    return database.update(
      'livres',
      {'favori': favori ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getLivresFavoris() async {
    final database = await db();

    return database.query(
      'livres',
      where: 'favori = ?',
      whereArgs: [1],
      orderBy: 'titre ASC',
    );
  }

  static Future<int> countLivres() async {
    final database = await db();
    final result = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM livres',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<List<Map<String, dynamic>>> getStatistiquesEcrivains() async {
    final database = await db();

    return database.rawQuery('''
    SELECT
      ecrivains.id,
      ecrivains.nom,
      ecrivains.prenom,
      COUNT(livres.id) AS totalLivres
    FROM ecrivains
    LEFT JOIN livres
      ON ecrivains.id = livres.ecrivainId
    GROUP BY ecrivains.id, ecrivains.nom, ecrivains.prenom
    ORDER BY totalLivres DESC
  ''');
  }

  // ================= STATISTIQUES GENERALES =================

  static Future<Map<String, int>> getStatistiquesGenerales() async {
    final database = await db();

    final totalLivres =
        Sqflite.firstIntValue(
          await database.rawQuery('SELECT COUNT(*) FROM livres'),
        ) ??
        0;

    final totalEcrivains =
        Sqflite.firstIntValue(
          await database.rawQuery('SELECT COUNT(*) FROM ecrivains'),
        ) ??
        0;

    final totalFavoris =
        Sqflite.firstIntValue(
          await database.rawQuery(
            'SELECT COUNT(*) FROM livres WHERE favori = 1',
          ),
        ) ??
        0;

    final livresSansEcrivain =
        Sqflite.firstIntValue(
          await database.rawQuery(
            'SELECT COUNT(*) FROM livres WHERE ecrivainId IS NULL',
          ),
        ) ??
        0;

    return {
      'totalLivres': totalLivres,
      'totalEcrivains': totalEcrivains,
      'totalFavoris': totalFavoris,
      'livresSansEcrivain': livresSansEcrivain,
      'livresAvecEcrivain': totalLivres - livresSansEcrivain,
    };
  }
}
