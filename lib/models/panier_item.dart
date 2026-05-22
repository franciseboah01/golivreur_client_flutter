import 'produit.dart';

class PanierItem {
  Produit produit;
  int quantite;

  PanierItem({required this.produit, this.quantite = 1});
}