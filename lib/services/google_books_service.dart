import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/sql_helper.dart';

class GoogleBook {
  final String id;
  final String titre;
  final String auteur;
  final String isbn;
  final String dateSortie;
  final String couverture;
  final String description;
  final String editeur;
  final List<String> categories;
  final int pages;

  const GoogleBook({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.isbn,
    required this.dateSortie,
    required this.couverture,
    required this.description,
    required this.editeur,
    required this.categories,
    required this.pages,
  });

  factory GoogleBook.fromJson(Map<String, dynamic> json) {
    final info = json['volumeInfo'] as Map<String, dynamic>? ?? {};

    final authors = (info['authors'] as List<dynamic>?) ?? [];
    final identifiers = (info['industryIdentifiers'] as List<dynamic>?) ?? [];
    final images = info['imageLinks'] as Map<String, dynamic>? ?? {};

    String isbn = '';

    for (final item in identifiers) {
      if (item is Map && item['type'] == 'ISBN_13') {
        isbn = item['identifier']?.toString() ?? '';
        break;
      }
    }

    if (isbn.isEmpty) {
      for (final item in identifiers) {
        if (item is Map && item['type'] == 'ISBN_10') {
          isbn = item['identifier']?.toString() ?? '';
          break;
        }
      }
    }

    String couverture =
        images['extraLarge']?.toString() ??
        images['large']?.toString() ??
        images['medium']?.toString() ??
        images['thumbnail']?.toString() ??
        '';

    couverture = couverture.replaceFirst('http://', 'https://');

    return GoogleBook(
      id: json['id']?.toString() ?? '',
      titre: info['title']?.toString() ?? 'Sans titre',
      auteur: authors.isNotEmpty ? authors.first.toString() : 'Auteur inconnu',
      isbn: isbn,
      dateSortie: info['publishedDate']?.toString() ?? '',
      couverture: couverture,
      description: info['description']?.toString() ?? '',
      editeur: info['publisher']?.toString() ?? '',
      categories:
          (info['categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      pages: (info['pageCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class GoogleBooksService {
  // RECHERCHER DES LIVRES REELS
  static Future<List<GoogleBook>> rechercherLivres(
    String recherche, {
    int maxResults = 20,
    String? langue,
  }) async {
    if (recherche.trim().isEmpty) return [];

    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': recherche.trim(),
      'maxResults': maxResults.clamp(1, 40).toString(),
      'printType': 'books',
      'langRestrict': ?langue,
    });

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur Google Books : ${response.statusCode}');
    }

    final data =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final items = data['items'] as List<dynamic>? ?? [];

    return items
        .whereType<Map<String, dynamic>>()
        .map(GoogleBook.fromJson)
        .where((book) => book.titre != 'Sans titre')
        .toList();
  }

  // VERIFIER SI LE LIVRE EXISTE DEJA
  static Future<bool> livreExiste(GoogleBook livre) async {
    final livres = await SQLHelper.getLivres();

    return livres.any((existing) {
      final isbnExistant = existing['isbn']?.toString().trim() ?? '';

      final titreExistant =
          existing['titre']?.toString().trim().toLowerCase() ?? '';

      if (livre.isbn.isNotEmpty &&
          isbnExistant.isNotEmpty &&
          isbnExistant == livre.isbn) {
        return true;
      }

      final auteurExistant =
          '${existing['prenomEcrivain'] ?? ''} '
                  '${existing['nomEcrivain'] ?? ''}'
              .trim()
              .toLowerCase();

      return titreExistant == livre.titre.trim().toLowerCase() &&
          auteurExistant == livre.auteur.trim().toLowerCase();
    });
  }

  // TROUVER OU CREER UN ECRIVAIN
  static Future<int> _obtenirEcrivain(String nomComplet) async {
    final ecrivains = await SQLHelper.getEcrivains();

    for (final ecrivain in ecrivains) {
      final nomExistant = '${ecrivain['prenom']} ${ecrivain['nom']}'
          .trim()
          .toLowerCase();

      if (nomExistant == nomComplet.trim().toLowerCase()) {
        return ecrivain['id'] as int;
      }
    }

    final mots = nomComplet.trim().split(RegExp(r'\s+'));

    final prenom = mots.first;
    final nom = mots.length > 1 ? mots.skip(1).join(' ') : 'Inconnu';

    return SQLHelper.createEcrivain(nom, prenom, '');
  }

  // IMPORTER UN LIVRE DANS SQLITE
  static Future<bool> importerLivre(GoogleBook livre) async {
    if (await livreExiste(livre)) return false;

    final int? ecrivainId = livre.auteur == 'Auteur inconnu'
        ? null
        : await _obtenirEcrivain(livre.auteur);

    String? photo;

    if (livre.couverture.isNotEmpty) {
      try {
        final response = await http
            .get(Uri.parse(livre.couverture))
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200 &&
            response.bodyBytes.length <= 1500000) {
          photo = SQLHelper.encoderCouverture(response.bodyBytes);
        }
      } catch (_) {
        photo = null;
      }
    }

    await SQLHelper.createLivre(
      livre.titre,
      livre.isbn,
      livre.dateSortie,
      photo,
      ecrivainId,
    );

    return true;
  }

  // IMPORTER PLUSIEURS LIVRES
  static Future<Map<String, int>> importerPlusieurs(
    List<GoogleBook> livres,
  ) async {
    int importes = 0;
    int doublons = 0;

    for (final livre in livres) {
      final resultat = await importerLivre(livre);

      if (resultat) {
        importes++;
      } else {
        doublons++;
      }
    }

    return {'importes': importes, 'doublons': doublons};
  }
}
