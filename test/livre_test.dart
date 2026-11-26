import 'package:flutter_test/flutter_test.dart';
import 'package:bibliotheque_app/models/livre.dart';

void main() {
  group('Livre Model Tests', () {
    test('Convertit un livre en Map', () {
      final livre = Livre(
        id: 1,
        titre: 'Le Petit Prince',
        isbn: '123456789',
        dateSortie: '1943',
        ecrivainId: 2,
      );

      final map = livre.toMap();

      expect(map['id'], 1);
      expect(map['titre'], 'Le Petit Prince');
      expect(map['isbn'], '123456789');
      expect(map['ecrivainId'], 2);
    });

    test('Reconstruit un livre depuis une Map', () {
      final livre = Livre.fromMap({
        'id': 1,
        'titre': 'Le Petit Prince',
        'isbn': '123456789',
        'dateSortie': '1943',
        'photo': null,
        'ecrivainId': 2,
      });

      expect(livre.id, 1);
      expect(livre.titre, 'Le Petit Prince');
      expect(livre.ecrivainId, 2);
    });
  });
}
