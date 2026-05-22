import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class DetailCommandeScreen extends StatefulWidget {
  final int commandeId;
  const DetailCommandeScreen({super.key, required this.commandeId});

  @override
  State<DetailCommandeScreen> createState() => _DetailCommandeScreenState();
}

class _DetailCommandeScreenState extends State<DetailCommandeScreen> {
  Map<String, dynamic>? _cmd;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.get('/commandes/${widget.commandeId}');
    if (res.statusCode == 200) setState(() => _cmd = jsonDecode(res.body));
  }

  Color _c(String s) {
    switch (s) {
      case 'en_attente': return AppColors.warning;
      case 'acceptee': case 'en_livraison': return AppColors.primary;
      case 'livree': return AppColors.success;
      default: return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cmd == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final c = _cmd!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Commande #${c['id']}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text('${c['total']} FCFA', style: const TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _c(c['statut']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(c['statut'] ?? '', style: TextStyle(color: _c(c['statut']), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _row('Adresse', c['adresse_livraison'] ?? ''),
            _row('Paiement', c['mode_paiement'] ?? ''),
            _row('Livraison', '${c['frais_livraison'] ?? 0} FCFA'),
            if (c['code_confirmation'] != null) _row('Code', c['code_confirmation']),
            if (c['livreur'] != null) _row('Livreur', '${c['livreur']['user']['nom']} ${c['livreur']['user']['prenom']}'),
            if (c['produits'] != null) ...[
              const SizedBox(height: 16),
              const Text('Produits', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
              ...(c['produits'] as List).map((p) => ListTile(
                title: Text(p['nom'] ?? '', style: const TextStyle(color: AppColors.white)),
                subtitle: Text('${p['pivot']['quantite']} x ${p['pivot']['prix_unitaire']} FCFA', style: const TextStyle(color: AppColors.grey)),
              )),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [Text('$l : ', style: const TextStyle(color: AppColors.grey)), Text(v, style: const TextStyle(color: AppColors.white))]),
  );
}