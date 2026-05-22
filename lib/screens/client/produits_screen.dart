import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../models/produit.dart';
import '../../providers/panier_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/skeleton_widgets.dart';

class ProduitsScreen extends StatefulWidget {
  final int commercantId;
  final String commercantNom;

  const ProduitsScreen({super.key, required this.commercantId, required this.commercantNom});

  @override
  State<ProduitsScreen> createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends State<ProduitsScreen> {
  List<Produit> _produits = [];
  bool _loading = true;
  bool _erreur = false;

  @override
  void initState() {
    super.initState();
    _loadProduits();
  }

  Future<void> _loadProduits() async {
    setState(() { _loading = true; _erreur = false; });
    try {
      final response = await ApiService.get('/commercants/${widget.commercantId}/produits');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _produits = data.map((j) => Produit.fromJson(j)).toList();
          _loading = false;
        });
      } else {
        setState(() { _loading = false; _erreur = true; });
      }
    } catch (e) {
      setState(() { _loading = false; _erreur = true; });
    }
  }

  Future<bool> _verifierChangementBoutique(PanierProvider panier) async {
    if (panier.isEmpty || panier.commercantId == widget.commercantId) return true;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Changer de boutique ?', style: TextStyle(color: AppColors.white)),
        content: Text(
          'Votre panier contient des articles de "${panier.commercantNom}".\nVoulez-vous vider le panier et commander ici ?',
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Changer'),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  Future<void> _ajouterAuPanier(Produit p) async {
    final panier = context.read<PanierProvider>();
    final ok = await _verifierChangementBoutique(panier);
    if (!ok) return;
    panier.ajouter(p, widget.commercantId, widget.commercantNom);
  }

  @override
  Widget build(BuildContext context) {
    final panier = context.watch<PanierProvider>();
    final totalArticles = panier.commercantId == widget.commercantId ? panier.totalArticles : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(widget.commercantNom, style: const TextStyle(color: AppColors.white)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProduits,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: _buildBody(panier),
      ),
      bottomNavigationBar: totalArticles > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$totalArticles article(s)',
                            style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                        Text('${panier.totalPrix.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(color: AppColors.white, fontSize: 12)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.shopping_cart, color: AppColors.primary),
                      label: const Text('Voir le panier', style: TextStyle(color: AppColors.primary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(PanierProvider panier) {
    if (_loading) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.72,
          crossAxisSpacing: 12, mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const SkeletonProduitCard(),
      );
    }

    if (_erreur) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: AppColors.grisMetallique, size: 60),
            const SizedBox(height: 16),
            const Text('Erreur de connexion',
                style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProduits,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    if (_produits.isEmpty) {
      return const Center(
        child: Text('Aucun produit disponible', style: TextStyle(color: AppColors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.72,
        crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: _produits.length,
      itemBuilder: (_, i) {
        final p = _produits[i];
        final qte = panier.commercantId == widget.commercantId
            ? panier.quantiteProduit(p.id)
            : 0;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: qte > 0 ? AppColors.primary : AppColors.border,
              width: qte > 0 ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Center(child: Icon(Icons.fastfood, color: AppColors.primary, size: 40)),
                  ),
                  if (!p.disponible)
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Text('Indisponible',
                            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nom,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('${p.prix.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (qte == 0)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: p.disponible ? () => _ajouterAuPanier(p) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Ajouter', style: TextStyle(fontSize: 12)),
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _btnQte(Icons.remove, AppColors.grey, () => panier.reduire(p.id)),
                          Text('$qte',
                              style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          _btnQte(Icons.add, AppColors.primary, () => _ajouterAuPanier(p)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _btnQte(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}