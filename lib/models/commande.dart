class Commande {
  final int id;
  final double total;
  final double fraisLivraison;
  final String statut;
  final String adresseLivraison;
  final String modePaiement;
  final String? createdAt;

  Commande({
    required this.id,
    required this.total,
    required this.fraisLivraison,
    required this.statut,
    required this.adresseLivraison,
    required this.modePaiement,
    this.createdAt,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      id: json['id'],
      total: double.parse(json['total'].toString()),
      fraisLivraison: double.parse(json['frais_livraison'].toString()),
      statut: json['statut'],
      adresseLivraison: json['adresse_livraison'],
      modePaiement: json['mode_paiement'],
      createdAt: json['created_at'],
    );
  }
}