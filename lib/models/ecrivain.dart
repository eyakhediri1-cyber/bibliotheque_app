class Ecrivain {
  final int? id;
  final String nom;
  final String prenom;
  final String tel;

  const Ecrivain({
    this.id,
    required this.nom,
    required this.prenom,
    required this.tel,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'nom': nom, 'prenom': prenom, 'tel': tel};
  }

  factory Ecrivain.fromMap(Map<String, dynamic> map) {
    return Ecrivain(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      prenom: map['prenom'] as String,
      tel: map['tel'] as String,
    );
  }
}
