import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import 'produits_screen.dart';

class FavorisScreen extends StatefulWidget {
  const FavorisScreen({super.key});

  @override
  State<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen> {
  List<dynamic> _favoris = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.get('/favoris');
    if (res.statusCode == 200) setState(() { _favoris = jsonDecode(res.body); _loading = false; });
  }

  Future<void> _toggle(Map<String, dynamic> fav) async {
    await ApiService.post('/favoris/toggle', {
      'commercant_id': fav['commercant_id'],
      'produit_id': fav['produit_id'],
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mes favoris')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favoris.isEmpty
              ? const Center(child: Text('Aucun favori', style: TextStyle(color: AppColors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _favoris.length,
                  itemBuilder: (_, i) {
                    final f = _favoris[i];
                    return Card(
                      color: AppColors.surface,
                      child: ListTile(
                        leading: const Icon(Icons.store, color: AppColors.primary),
                        title: Text(f['commercant']?['nom_boutique'] ?? 'Boutique', style: const TextStyle(color: AppColors.white)),
                        subtitle: f['produit'] != null ? Text(f['produit']['nom'], style: const TextStyle(color: AppColors.grey)) : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: AppColors.error),
                          onPressed: () => _toggle(f),
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProduitsScreen(commercantId: f['commercant_id'], commercantNom: f['commercant']?['nom_boutique'] ?? ''))),
                      ),
                    );
                  },
                ),
    );
  }
}