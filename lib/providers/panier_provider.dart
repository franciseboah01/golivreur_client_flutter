import 'package:flutter/foundation.dart';
import '../models/produit.dart';
import '../models/panier_item.dart';

class PanierProvider extends ChangeNotifier {
  final List<PanierItem> _items = [];
  int? _commercantId;
  String? _commercantNom;

  List<PanierItem> get items => List.unmodifiable(_items);
  int? get commercantId => _commercantId;
  String? get commercantNom => _commercantNom;

  int get totalArticles => _items.fold(0, (sum, item) => sum + item.quantite);

  double get totalPrix => _items.fold(0.0, (sum, item) => sum + item.produit.prix * item.quantite);

  bool get isEmpty => _items.isEmpty;

  /// Retourne la quantité d'un produit dans le panier (0 si absent)
  int quantiteProduit(int produitId) {
    final index = _items.indexWhere((i) => i.produit.id == produitId);
    return index >= 0 ? _items[index].quantite : 0;
  }

  /// Ajouter un produit — si c'est un nouveau commercant, vider le panier d'abord
  void ajouter(Produit produit, int commercantId, String commercantNom) {
    if (_commercantId != null && _commercantId != commercantId) {
      // Panier d'une autre boutique — on vide
      _items.clear();
    }
    _commercantId = commercantId;
    _commercantNom = commercantNom;

    final index = _items.indexWhere((i) => i.produit.id == produit.id);
    if (index >= 0) {
      _items[index].quantite++;
    } else {
      _items.add(PanierItem(produit: produit, quantite: 1));
    }
    notifyListeners();
  }

  /// Réduire la quantité d'un produit (supprime si quantité tombe à 0)
  void reduire(int produitId) {
    final index = _items.indexWhere((i) => i.produit.id == produitId);
    if (index < 0) return;
    if (_items[index].quantite > 1) {
      _items[index].quantite--;
    } else {
      _items.removeAt(index);
    }
    if (_items.isEmpty) {
      _commercantId = null;
      _commercantNom = null;
    }
    notifyListeners();
  }

  /// Supprimer un produit complètement
  void supprimer(int produitId) {
    _items.removeWhere((i) => i.produit.id == produitId);
    if (_items.isEmpty) {
      _commercantId = null;
      _commercantNom = null;
    }
    notifyListeners();
  }

  /// Vider tout le panier
  void vider() {
    _items.clear();
    _commercantId = null;
    _commercantNom = null;
    notifyListeners();
  }
}