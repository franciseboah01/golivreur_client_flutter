class Produit {
  final int id;
  final int commercantId;
  final String nom;
  final String? description;
  final double prix;
  final String? categorie;
  final bool disponible;

  Produit({
    required this.id,
    required this.commercantId,
    required this.nom,
    this.description,
    required this.prix,
    this.categorie,
    required this.disponible,
  });

  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      id: json['id'],
      commercantId: json['commercant_id'],
      nom: json['nom'],
      description: json['description'],
      prix: double.parse(json['prix'].toString()),
      categorie: json['categorie'],
      disponible: json['disponible'] == 1 || json['disponible'] == true,
    );
  }
}