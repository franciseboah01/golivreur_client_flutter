import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class DetailColisScreen extends StatefulWidget {
  final int colisId;
  const DetailColisScreen({super.key, required this.colisId});

  @override
  State<DetailColisScreen> createState() => _DetailColisScreenState();
}

class _DetailColisScreenState extends State<DetailColisScreen> {
  Map<String, dynamic>? _colis;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.get('/colis/${widget.colisId}');
    if (res.statusCode == 200) setState(() => _colis = jsonDecode(res.body));
  }

  Color _c(String s) {
    switch (s) {
      case 'en_attente': return AppColors.warning;
      case 'accepte': case 'en_livraison': return AppColors.primary;
      case 'livre': return AppColors.success;
      case 'annule': return AppColors.error;
      default: return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_colis == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final c = _colis!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Colis #${c['id']}')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text(c['destinataire_nom'] ?? '', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: _c(c['statut']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(c['statut'] ?? '', style: TextStyle(color: _c(c['statut']), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            _row('De', c['adresse_ramassage'] ?? ''),
            _row('À', c['adresse_livraison'] ?? ''),
            _row('Taille', c['taille'] ?? ''),
            _row('Prix', '${c['prix_livraison'] ?? '0'} FCFA'),
            _row('Code', c['code_confirmation'] ?? ''),
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