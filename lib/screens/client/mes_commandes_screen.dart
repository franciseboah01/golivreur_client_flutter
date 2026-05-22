import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../models/commande.dart';
import '../../models/colis.dart';
import '../../utils/app_colors.dart';
import '../../widgets/skeleton_widgets.dart';
import 'detail_colis_screen.dart';
import 'detail_commande_screen.dart';

class MesCommandesScreen extends StatefulWidget {
  const MesCommandesScreen({super.key});

  @override
  State<MesCommandesScreen> createState() => _MesCommandesScreenState();
}

class _MesCommandesScreenState extends State<MesCommandesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Commande> _commandes = [];
  List<Colis> _colis = [];
  bool _loading = true;
  bool _erreur = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _erreur = false; });
    try {
      final results = await Future.wait([
        ApiService.get('/commandes'),       // GET /commandes
        ApiService.get('/colis/envois'),    // GET /colis/envois
      ]);

      final cmdRes = results[0];
      final colisRes = results[1];

      setState(() {
        if (cmdRes.statusCode == 200) {
          final List<dynamic> data = jsonDecode(cmdRes.body);
          _commandes = data.map((j) => Commande.fromJson(j)).toList();
        }
        if (colisRes.statusCode == 200) {
          final List<dynamic> data = jsonDecode(colisRes.body);
          _colis = data.map((j) => Colis.fromJson(j)).toList();
        }
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _erreur = true; });
    }
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'en_attente': return AppColors.jauneNeon;
      case 'acceptee': case 'accepte': case 'en_livraison': return AppColors.orangeNeon;
      case 'livree': case 'livre': return AppColors.vertNeon;
      case 'annulee': case 'annule': return AppColors.rougeNeon;
      default: return AppColors.grisMetallique;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.noirProfond,
      appBar: AppBar(
        backgroundColor: AppColors.noirCarbone,
        title: const Text('Mes commandes & colis', style: TextStyle(color: AppColors.blancPur)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.orangeNeon,
          labelColor: AppColors.orangeNeon,
          unselectedLabelColor: AppColors.grisMetallique,
          tabs: [
            Tab(text: 'Commandes (${_loading ? '…' : _commandes.length})'),
            Tab(text: 'Colis (${_loading ? '…' : _colis.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTab(_buildCommandes),
          _buildTab(_buildColis),
        ],
      ),
    );
  }

  Widget _buildTab(Widget Function() builder) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.orangeNeon,
      backgroundColor: AppColors.surface,
      child: _loading
          ? ListView(
              padding: const EdgeInsets.all(12),
              children: List.generate(5, (_) => const SkeletonCommandeCard()),
            )
          : _erreur
              ? _buildErreur()
              : builder(),
    );
  }

  Widget _buildErreur() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: AppColors.grisMetallique, size: 60),
          const SizedBox(height: 16),
          const Text('Erreur de connexion',
              style: TextStyle(color: AppColors.blancPur, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tirez vers le bas pour réessayer',
              style: TextStyle(color: AppColors.grisMetallique)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orangeNeon),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandes() {
    if (_commandes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, color: AppColors.grisMetallique, size: 60),
            SizedBox(height: 16),
            Text('Aucune commande', style: TextStyle(color: AppColors.grisMetallique, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _commandes.length,
      itemBuilder: (_, i) {
        final c = _commandes[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailCommandeScreen(commandeId: c.id)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.noirCarbone,
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: _statutColor(c.statut), width: 4)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Commande #${c.id}',
                    style: const TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statutColor(c.statut).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(c.statut,
                      style: TextStyle(color: _statutColor(c.statut), fontSize: 11)),
                ),
              ]),
              const SizedBox(height: 8),
              Text('${c.total.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(color: AppColors.orangeNeon, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(c.adresseLivraison, style: const TextStyle(color: AppColors.grisMetallique)),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildColis() {
    if (_colis.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2, color: AppColors.grisMetallique, size: 60),
            SizedBox(height: 16),
            Text('Aucun colis envoyé', style: TextStyle(color: AppColors.grisMetallique, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _colis.length,
      itemBuilder: (_, i) {
        final c = _colis[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailColisScreen(colisId: c.id)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.noirCarbone,
              borderRadius: BorderRadius.circular(16),
              border: Border(left: BorderSide(color: _statutColor(c.statut), width: 4)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Colis #${c.id} · ${c.destinataireNom}',
                    style: const TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statutColor(c.statut).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(c.statut,
                      style: TextStyle(color: _statutColor(c.statut), fontSize: 11)),
                ),
              ]),
              const SizedBox(height: 8),
              Text('${c.prixLivraison.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(color: AppColors.orangeNeon, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.vpn_key, color: AppColors.grisMetallique, size: 14),
                const SizedBox(width: 4),
                Text('Code : ${c.codeConfirmation}',
                    style: const TextStyle(color: AppColors.grisMetallique, fontSize: 13)),
              ]),
            ]),
          ),
        );
      },
    );
  }
}