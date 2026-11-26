class Livre {
  final int? id;
  final String titre;
  final String? isbn;
  final String? dateSortie;
  final String? photo;
  final int? ecrivainId;

  Livre({
    this.id,
    required this.titre,
    this.isbn,
    this.dateSortie,
    this.photo,
    this.ecrivainId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'isbn': isbn,
      'dateSortie': dateSortie,
      'photo': photo,
      'ecrivainId': ecrivainId,
    };
  }

  factory Livre.fromMap(Map<String, dynamic> map) {
    return Livre(
      id: map['id'] as int?,
      titre: map['titre'] as String,
      isbn: map['isbn'] as String?,
      dateSortie: map['dateSortie'] as String?,
      photo: map['photo'] as String?,
      ecrivainId: map['ecrivainId'] as int?,
    );
  }
}
