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
      version: 1,
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
            FOREIGN KEY(ecrivainId)
              REFERENCES ecrivains(id)
              ON DELETE SET NULL
          )
        ''');

        await database.execute(
          'CREATE INDEX idx_livres_titre ON livres(titre)',
        );
      },
    );

    return _database!;
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

  static Future<int> countLivres() async {
    final database = await db();
    final result = await database.rawQuery(
      'SELECT COUNT(*) AS total FROM livres',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
