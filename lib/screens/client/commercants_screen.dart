import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../models/commercant.dart';
import '../../utils/app_colors.dart';
import '../../widgets/skeleton_widgets.dart';
import 'produits_screen.dart';

class CommercantsScreen extends StatefulWidget {
  const CommercantsScreen({super.key});

  @override
  State<CommercantsScreen> createState() => _CommercantsScreenState();
}

class _CommercantsScreenState extends State<CommercantsScreen> {
  List<Commercant> _commercants = [];
  bool _loading = true;
  bool _erreur = false;

  @override
  void initState() {
    super.initState();
    _loadCommercants();
  }

  Future<void> _loadCommercants() async {
    setState(() { _loading = true; _erreur = false; });
    try {
      final response = await ApiService.get('/commercants');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _commercants = data.map((j) => Commercant.fromJson(j)).toList();
          _loading = false;
        });
      } else {
        setState(() { _loading = false; _erreur = true; });
      }
    } catch (e) {
      setState(() { _loading = false; _erreur = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.noirProfond,
      appBar: AppBar(
        backgroundColor: AppColors.noirCarbone,
        title: const Text('Commerces disponibles', style: TextStyle(color: AppColors.blancPur)),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCommercants,
        color: AppColors.orangeNeon,
        backgroundColor: AppColors.surface,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: List.generate(6, (_) => const SkeletonListTile()),
      );
    }

    if (_erreur) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: AppColors.grisMetallique, size: 60),
            const SizedBox(height: 16),
            const Text('Erreur de connexion', style: TextStyle(color: AppColors.blancPur, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Vérifiez votre connexion internet', style: TextStyle(color: AppColors.grisMetallique)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadCommercants,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.orangeNeon),
            ),
          ],
        ),
      );
    }

    if (_commercants.isEmpty) {
      return const Center(
        child: Text('Aucun commerce disponible', style: TextStyle(color: AppColors.grisMetallique)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _commercants.length,
      itemBuilder: (_, i) {
        final c = _commercants[i];
        return Card(
          color: AppColors.noirCarbone,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: AppColors.orangeNeon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store, color: AppColors.orangeNeon),
            ),
            title: Text(c.nomBoutique,
                style: const TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.bold)),
            subtitle: Text(c.adresse, style: const TextStyle(color: AppColors.grisMetallique)),
            trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.orangeNeon, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProduitsScreen(commercantId: c.id, commercantNom: c.nomBoutique),
              ),
            ),
          ),
        );
      },
    );
  }
}