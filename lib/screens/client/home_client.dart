import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/skeleton_widgets.dart';
import 'produits_screen.dart';
import 'colis_screen.dart';

class HomeClient extends StatefulWidget {
  const HomeClient({super.key});

  @override
  State<HomeClient> createState() => _HomeClientState();
}

class _HomeClientState extends State<HomeClient> {
  List<Map<String, String>> _categories = [];
  List<dynamic> _boutiques = [];
  bool _loadingCat = true;
  bool _loadingBout = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBoutiques();
  }

  Future<void> _loadCategories() async {
    try {
      final res = await ApiService.get('/categories');
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _categories = data
              .map<Map<String, String>>(
                  (c) => {'nom': c['nom'].toString(), 'icone': c['icone'].toString()})
              .toList();
          _loadingCat = false;
        });
      }
    } catch (_) {
      setState(() => _loadingCat = false);
    }
  }

  Future<void> _loadBoutiques() async {
    try {
      final res = await ApiService.get('/commercants');
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _boutiques = data;
          _loadingBout = false;
        });
      }
    } catch (_) {
      setState(() => _loadingBout = false);
    }
  }

  Future<void> _refresh() async {
    setState(() { _loadingCat = true; _loadingBout = true; });
    await Future.wait([_loadCategories(), _loadBoutiques()]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.orangeNeon,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          // Salutation
          Text(
            'Bonjour ${auth.nom ?? ''} ! ☀️',
            style: const TextStyle(color: AppColors.blancPur, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Que voulez-vous aujourd\'hui ?',
            style: TextStyle(color: AppColors.grisMetallique, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Boutons actions rapides
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.orangeNeon, AppColors.orangeFonce]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.store, color: AppColors.blancPur, size: 32),
                      SizedBox(height: 8),
                      Text('Commander', style: TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Produits & services', style: TextStyle(color: AppColors.blancPur, fontSize: 11)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColisScreen())),
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.noirCarbone,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.orangeNeon.withValues(alpha: 0.3)),
                    ),
                    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.local_shipping, color: AppColors.orangeNeon, size: 32),
                      SizedBox(height: 8),
                      Text('Envoyer un colis', style: TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('À n\'importe qui', style: TextStyle(color: AppColors.grisMetallique, fontSize: 11)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Catégories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Catégories', style: TextStyle(color: AppColors.blancPur, fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('Tout voir →', style: TextStyle(color: AppColors.orangeNeon))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: _loadingCat
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(5, (_) => const SkeletonCategorie()),
                  )
                : _categories.isEmpty
                    ? const Center(child: Text('Aucune catégorie', style: TextStyle(color: AppColors.grisMetallique)))
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: _categories.map((cat) => _buildCategorie(cat['icone']!, cat['nom']!)).toList(),
                      ),
          ),
          const SizedBox(height: 24),

          // Boutiques populaires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Populaires près de vous', style: TextStyle(color: AppColors.blancPur, fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('Voir tout →', style: TextStyle(color: AppColors.orangeNeon))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _loadingBout
                ? ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(4, (_) => const SkeletonBoutiqueCard()),
                  )
                : _boutiques.isEmpty
                    ? const Center(child: Text('Aucune boutique', style: TextStyle(color: AppColors.grisMetallique)))
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: _boutiques.map((b) => _buildBoutiqueCard(b)).toList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorie(String emoji, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.noirCarbone,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grisAnthracite),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppColors.grisMetallique, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildBoutiqueCard(dynamic b) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProduitsScreen(
            commercantId: b['id'],
            commercantNom: b['nom_boutique'] ?? '',
          ),
        ),
      ),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.noirCarbone,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grisAnthracite),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.orangeNeon.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Center(child: Icon(Icons.store, color: AppColors.orangeNeon, size: 40)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['nom_boutique'] ?? '',
                      style: const TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(b['categorie'] ?? '',
                      style: const TextStyle(color: AppColors.grisMetallique, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star, color: AppColors.orangeNeon, size: 14),
                    const Text(' 4.8', style: TextStyle(color: AppColors.blancPur, fontSize: 12)),
                    Text(' (127)', style: TextStyle(color: AppColors.grisMetallique, fontSize: 11)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}