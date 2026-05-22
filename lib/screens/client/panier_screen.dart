import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/panier_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class PanierScreen extends StatefulWidget {
  const PanierScreen({super.key});

  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  final _adresseCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _adresseCtrl.dispose();
    super.dispose();
  }

  Future<void> _passerCommande(PanierProvider panier) async {
    if (_adresseCtrl.text.trim().isEmpty) {
      _showSnack('Veuillez saisir une adresse de livraison');
      return;
    }
    setState(() => _loading = true);
    try {
      final produits = panier.items
          .map((p) => {'id': p.produit.id, 'quantite': p.quantite})
          .toList();

      final res = await ApiService.post('/commandes', {
        'commercant_id': panier.commercantId,
        'produits': produits,
        'adresse_livraison': _adresseCtrl.text.trim(),
      });

      if (!mounted) return;

      if (res.statusCode == 201) {
        panier.vider();
        _adresseCtrl.clear();
        _showSnack('Commande passée avec succès !', success: true);
      } else {
        final data = jsonDecode(res.body);
        _showSnack(data['message'] ?? 'Erreur lors de la commande');
      }
    } catch (_) {
      _showSnack('Erreur réseau, veuillez réessayer');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? AppColors.success : AppColors.error,
    ));
  }

  void _confirmerSuppression(BuildContext context, PanierProvider panier, int produitId, String nom) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Retirer du panier', style: TextStyle(color: AppColors.white)),
        content: Text('Retirer "$nom" du panier ?', style: const TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () { panier.supprimer(produitId); Navigator.pop(context); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();

    if (panier.isEmpty) return _buildPanierVide();

    final fraisLivraison = 500.0;
    final totalFinal = panier.totalPrix + fraisLivraison;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // En-tête boutique
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.surface,
            child: Row(
              children: [
                const Icon(Icons.store, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(panier.commercantNom ?? 'Boutique',
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('Vider le panier', style: TextStyle(color: AppColors.white)),
                      content: const Text('Voulez-vous vider tout votre panier ?',
                          style: TextStyle(color: AppColors.grey)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                        ElevatedButton(
                          onPressed: () { panier.vider(); Navigator.pop(context); },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: const Text('Vider'),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 16),
                  label: const Text('Vider', style: TextStyle(color: AppColors.error, fontSize: 13)),
                ),
              ],
            ),
          ),

          // Liste articles
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: panier.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final item = panier.items[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fastfood, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.produit.nom,
                                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${item.produit.prix.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _btnQte(
                            icon: item.quantite == 1 ? Icons.delete_outline : Icons.remove,
                            color: item.quantite == 1 ? AppColors.error : AppColors.grey,
                            onTap: () {
                              if (item.quantite == 1) {
                                _confirmerSuppression(context, panier, item.produit.id, item.produit.nom);
                              } else {
                                panier.reduire(item.produit.id);
                              }
                            },
                          ),
                          Container(
                            width: 32,
                            alignment: Alignment.center,
                            child: Text('${item.quantite}',
                                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          _btnQte(
                            icon: Icons.add,
                            color: AppColors.primary,
                            onTap: () => panier.ajouter(item.produit, panier.commercantId!, panier.commercantNom!),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Récapitulatif & commande
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _adresseCtrl,
                  style: const TextStyle(color: AppColors.white),
                  decoration: const InputDecoration(
                    labelText: 'Adresse de livraison',
                    prefixIcon: Icon(Icons.location_on),
                    hintText: 'Ex: Cocody, Abidjan',
                  ),
                ),
                const SizedBox(height: 16),
                _lignePrix('Sous-total', '${panier.totalPrix.toStringAsFixed(0)} FCFA'),
                _lignePrix('Frais de livraison', '${fraisLivraison.toStringAsFixed(0)} FCFA'),
                const Divider(color: AppColors.border, height: 24),
                _lignePrix('Total', '${totalFinal.toStringAsFixed(0)} FCFA', bold: true, color: AppColors.primary),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : () => _passerCommande(panier),
                    icon: _loading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _loading ? 'Commande en cours...' : 'Confirmer la commande',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _btnQte({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }

  Widget _lignePrix(String label, String valeur, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            color: bold ? AppColors.white : AppColors.grey,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          )),
          Text(valeur, style: TextStyle(
            color: color ?? (bold ? AppColors.white : AppColors.grey),
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 16 : 14,
          )),
        ],
      ),
    );
  }

  Widget _buildPanierVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.grey, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('Votre panier est vide',
              style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Ajoutez des produits depuis une boutique',
              style: TextStyle(color: AppColors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}