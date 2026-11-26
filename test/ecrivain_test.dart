import 'package:flutter_test/flutter_test.dart';
import 'package:bibliotheque_app/models/ecrivain.dart';

void main() {
  group('Ecrivain Model Tests', () {
    test('Convertit un écrivain en Map', () {
      const ecrivain = Ecrivain(
        id: 1,
        nom: 'Hugo',
        prenom: 'Victor',
        tel: '12345678',
      );

      final map = ecrivain.toMap();

      expect(map['id'], 1);
      expect(map['nom'], 'Hugo');
      expect(map['prenom'], 'Victor');
      expect(map['tel'], '12345678');
    });

    test('Reconstruit un écrivain depuis une Map', () {
      final ecrivain = Ecrivain.fromMap({
        'id': 1,
        'nom': 'Hugo',
        'prenom': 'Victor',
        'tel': '12345678',
      });

      expect(ecrivain.id, 1);
      expect(ecrivain.nom, 'Hugo');
      expect(ecrivain.prenom, 'Victor');
      expect(ecrivain.tel, '12345678');
    });
  });
}
