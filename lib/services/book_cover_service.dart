import 'dart:convert';

import 'package:http/http.dart' as http;

class BookCover {
  final String title;
  final String authors;
  final String imageUrl;
  final String? isbn;

  const BookCover({
    required this.title,
    required this.authors,
    required this.imageUrl,
    this.isbn,
  });
}

class BookCoverService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  static Future<List<BookCover>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(_baseUrl)
          .replace(queryParameters: {'q': query.trim(), 'maxResults': '20'});

      final response = await http.get(uri);

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final items = data['items'] as List? ?? [];

      return items
          .map((item) {
            final volume = item['volumeInfo'] ?? {};
            final authors = volume['authors'] as List? ?? [];
            final identifiers = volume['industryIdentifiers'] as List? ?? [];

            String? isbn;

            for (final identifier in identifiers) {
              if (identifier['type'] == 'ISBN_13' ||
                  identifier['type'] == 'ISBN_10') {
                isbn = identifier['identifier']?.toString();
                break;
              }
            }

            final imageLinks = volume['imageLinks'] ?? {};
            final imageUrl =
                (imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '')
                    .toString()
                    .replaceFirst('http://', 'https://');

            return BookCover(
              title: (volume['title'] ?? 'Titre inconnu').toString(),
              authors: authors.join(', '),
              imageUrl: imageUrl,
              isbn: isbn,
            );
          })
          .where((book) => book.imageUrl.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<BookCover>> search(String query) {
    return searchBooks(query);
  }
}
