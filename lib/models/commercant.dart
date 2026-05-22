class Commercant {
  final int id;
  final int userId;
  final String nomBoutique;
  final String? description;
  final String adresse;
  final String? telephoneBoutique;
  final String? categorie;
  final String? horaires;
  final bool ouvert;
  final String? photoBoutique;

  Commercant({
    required this.id,
    required this.userId,
    required this.nomBoutique,
    this.description,
    required this.adresse,
    this.telephoneBoutique,
    this.categorie,
    this.horaires,
    required this.ouvert,
    this.photoBoutique,
  });

  factory Commercant.fromJson(Map<String, dynamic> json) {
    return Commercant(
      id: json['id'],
      userId: json['user_id'],
      nomBoutique: json['nom_boutique'],
      description: json['description'],
      adresse: json['adresse'],
      telephoneBoutique: json['telephone_boutique'],
      categorie: json['categorie'],
      horaires: json['horaires'],
      ouvert: json['ouvert'] == 1 || json['ouvert'] == true,
      photoBoutique: json['photo_boutique'],
    );
  }
}