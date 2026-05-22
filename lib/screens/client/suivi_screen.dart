import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class SuiviCommandeScreen extends StatefulWidget {
  final int commandeId;
  final int livreurId;
  const SuiviCommandeScreen({super.key, required this.commandeId, required this.livreurId});

  @override
  State<SuiviCommandeScreen> createState() => _SuiviCommandeScreenState();
}

class _SuiviCommandeScreenState extends State<SuiviCommandeScreen> {
  Map<String, dynamic>? _position;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadPosition();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _loadPosition());
  }

  Future<void> _loadPosition() async {
    final res = await ApiService.get('/livreur/${widget.livreurId}/position');
    if (res.statusCode == 200) setState(() => _position = jsonDecode(res.body));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Suivi en direct')),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.location_on, color: AppColors.primary, size: 80),
          const SizedBox(height: 20),
          Text('Livreur : ${_position?['nom'] ?? '...'}', style: const TextStyle(color: AppColors.white, fontSize: 20)),
          const SizedBox(height: 8),
          Text('Lat : ${_position?['latitude'] ?? '...'}', style: const TextStyle(color: AppColors.grey)),
          Text('Lng : ${_position?['longitude'] ?? '...'}', style: const TextStyle(color: AppColors.grey)),
          const SizedBox(height: 24),
          const Text('📍 Position mise à jour toutes les 10s', style: TextStyle(color: AppColors.grey, fontSize: 12)),
        ]),
      ),
    );
  }
}