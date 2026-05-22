class Colis {
  final int id;
  final String destinataireNom;
  final String destinataireTelephone;
  final String adresseRamassage;
  final String adresseLivraison;
  final String? description;
  final String taille;
  final double prixLivraison;
  final String statut;
  final String codeConfirmation;
  final String? createdAt;

  Colis({
    required this.id,
    required this.destinataireNom,
    required this.destinataireTelephone,
    required this.adresseRamassage,
    required this.adresseLivraison,
    this.description,
    required this.taille,
    required this.prixLivraison,
    required this.statut,
    required this.codeConfirmation,
    this.createdAt,
  });

  factory Colis.fromJson(Map<String, dynamic> json) {
    return Colis(
      id: json['id'],
      destinataireNom: json['destinataire_nom'],
      destinataireTelephone: json['destinataire_telephone'],
      adresseRamassage: json['adresse_ramassage'],
      adresseLivraison: json['adresse_livraison'],
      description: json['description'],
      taille: json['taille'],
      prixLivraison: double.parse(json['prix_livraison'].toString()),
      statut: json['statut'],
      codeConfirmation: json['code_confirmation'],
      createdAt: json['created_at'],
    );
  }
}