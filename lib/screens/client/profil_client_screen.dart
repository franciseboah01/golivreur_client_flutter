import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_transitions.dart';
import 'mes_commandes_screen.dart';
import 'favoris_screen.dart';

class ProfilClientScreen extends StatefulWidget {
  const ProfilClientScreen({super.key});

  @override
  State<ProfilClientScreen> createState() => _ProfilClientScreenState();
}

class _ProfilClientScreenState extends State<ProfilClientScreen> {
  int _nbCommandes = 0;
  int _nbColis = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final results = await Future.wait([
        ApiService.get('/commandes'),
        ApiService.get('/colis/envois'),
      ]);
      if (!mounted) return;
      setState(() {
        if (results[0].statusCode == 200) {
          final List data = jsonDecode(results[0].body);
          _nbCommandes = data.length;
        }
        if (results[1].statusCode == 200) {
          final List data = jsonDecode(results[1].body);
          _nbColis = data.length;
        }
        _loadingStats = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  void _confirmerDeconnexion(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Se déconnecter', style: TextStyle(color: AppColors.white)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?',
            style: TextStyle(color: AppColors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.deconnecter();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppColors.noirProfond,
      appBar: AppBar(
        backgroundColor: AppColors.noirCarbone,
        title: const Text('Mon profil', style: TextStyle(color: AppColors.blancPur)),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: AppColors.orangeNeon,
        backgroundColor: AppColors.surface,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar + infos
            Column(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.orangeNeon.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.orangeNeon, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      _initiales(auth.nom, auth.prenom),
                      style: const TextStyle(color: AppColors.orangeNeon, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${auth.prenom ?? ''} ${auth.nom ?? ''}',
                  style: const TextStyle(color: AppColors.blancPur, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(auth.telephone ?? '',
                    style: const TextStyle(color: AppColors.grisMetallique)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.orangeNeon.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('🏆 Client GoLivreur',
                      style: TextStyle(color: AppColors.orangeNeon, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats dynamiques
            Row(
              children: [
                _buildStat(
                  _loadingStats ? '…' : '$_nbCommandes',
                  'Commandes',
                ),
                const SizedBox(width: 12),
                _buildStat(
                  _loadingStats ? '…' : '$_nbColis',
                  'Colis envoyés',
                ),
                const SizedBox(width: 12),
                _buildStat('4.9', 'Ma note'),
              ],
            ),
            const SizedBox(height: 24),

            // Mon compte
            _sectionTitle('Mon compte'),
            _menuItem(Icons.person, 'Informations personnelles', () => _comingSoon(context, 'Informations personnelles')),
            _menuItem(Icons.location_on, 'Mes adresses', () => _comingSoon(context, 'Mes adresses')),
            _menuItem(Icons.payment, 'Moyens de paiement', () => _comingSoon(context, 'Moyens de paiement')),
            _menuItem(Icons.notifications, 'Notifications', () => _comingSoon(context, 'Notifications')),
            const SizedBox(height: 16),

            // Mes achats
            _sectionTitle('Mes achats'),
            _menuItem(Icons.receipt_long, 'Historique des commandes', () {
              Navigator.push(context, AppTransitions.slideRight(const MesCommandesScreen()));
            }),
            _menuItem(Icons.favorite, 'Mes favoris', () {
              Navigator.push(context, AppTransitions.slideRight(const FavorisScreen()));
            }),
            _menuItem(Icons.star, 'Mes avis', () => _comingSoon(context, 'Mes avis')),
            const SizedBox(height: 16),

            // Parrainage
            _sectionTitle('Parrainage'),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.orangeNeon, AppColors.orangeFonce]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('🎁 Parrainer un ami',
                      style: TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Gagnez 500 FCFA chacun',
                      style: TextStyle(color: AppColors.blancPur, fontSize: 13)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: AppColors.blancPur, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      'GOL-${(auth.nom ?? 'USER').toUpperCase().substring(0, (auth.nom?.length ?? 4).clamp(0, 4))}${auth.userId ?? '00'}',
                      style: const TextStyle(
                          color: AppColors.orangeNeon,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _comingSoon(context, 'Partager mon code'),
                    child: const Text('Partager mon code',
                        style: TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Support
            _sectionTitle('Support'),
            _menuItem(Icons.help, 'Centre d\'aide', () => _comingSoon(context, 'Centre d\'aide')),
            _menuItem(Icons.chat, 'Contacter le support', () => _comingSoon(context, 'Contacter le support')),
            _menuItem(Icons.description, 'Conditions d\'utilisation', () => _comingSoon(context, 'CGU')),
            _menuItem(Icons.privacy_tip, 'Confidentialité', () => _comingSoon(context, 'Confidentialité')),
            const SizedBox(height: 24),

            // Déconnexion avec confirmation
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _confirmerDeconnexion(context, auth),
                icon: const Icon(Icons.logout, color: AppColors.rougeNeon),
                label: const Text('Se déconnecter',
                    style: TextStyle(color: AppColors.rougeNeon, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.rougeNeon),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _initiales(String? nom, String? prenom) {
    final n = nom?.isNotEmpty == true ? nom![0].toUpperCase() : '';
    final p = prenom?.isNotEmpty == true ? prenom![0].toUpperCase() : '';
    return '$p$n';
  }

  void _comingSoon(BuildContext context, String titre) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$titre — Bientôt disponible'),
        backgroundColor: AppColors.noirCarbone,
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.noirCarbone, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: AppColors.orangeNeon, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                style: const TextStyle(color: AppColors.grisMetallique, fontSize: 11),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(
              color: AppColors.orangeNeon, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: AppColors.noirCarbone,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.orangeNeon),
        title: Text(title, style: const TextStyle(color: AppColors.blancPur)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.grisMetallique, size: 16),
        onTap: onTap,
      ),
    );
  }
}