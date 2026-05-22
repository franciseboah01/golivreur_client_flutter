import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifs = [];
  bool _loading = true;
  bool _erreur = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _erreur = false; });
    try {
      // Route : GET /notifications
      final res = await ApiService.get('/notifications');
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() {
          _notifs = jsonDecode(res.body);
          _loading = false;
        });
      } else {
        setState(() { _loading = false; _erreur = true; });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _erreur = true; });
    }
  }

  Future<void> _marquerLue(int id) async {
    try {
      // Route : PUT /notifications/{id}/lire
      await ApiService.put('/notifications/$id/lire', {});
      _load();
    } catch (_) {}
  }

  Future<void> _toutMarquerLu() async {
    try {
      // Route : PUT /notifications/tout-lire
      await ApiService.put('/notifications/tout-lire', {});
      _load();
    } catch (_) {}
  }

  IconData _icone(String? type) {
    switch (type) {
      case 'commande': return Icons.receipt_long;
      case 'livraison': return Icons.local_shipping;
      case 'colis': return Icons.inventory_2;
      case 'paiement': return Icons.payment;
      default: return Icons.notifications;
    }
  }

  Color _couleur(String? type) {
    switch (type) {
      case 'commande': return AppColors.orangeNeon;
      case 'livraison': return AppColors.primary;
      case 'colis': return AppColors.warning;
      case 'paiement': return AppColors.success;
      default: return AppColors.grey;
    }
  }

  int get _nonLues => _notifs.where((n) => n['lu'] != 1 && n['lu'] != true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.noirProfond,
      appBar: AppBar(
        backgroundColor: AppColors.noirCarbone,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications', style: TextStyle(color: AppColors.blancPur)),
            if (!_loading && _nonLues > 0)
              Text('$_nonLues non lue(s)',
                  style: const TextStyle(color: AppColors.orangeNeon, fontSize: 12)),
          ],
        ),
        actions: [
          if (_nonLues > 0)
            TextButton(
              onPressed: _toutMarquerLu,
              child: const Text('Tout lire', style: TextStyle(color: AppColors.orangeNeon)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
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
        children: List.generate(5, (_) => _buildSkeletonNotif()),
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
                style: TextStyle(color: AppColors.blancPur, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Tirez vers le bas pour réessayer',
                style: TextStyle(color: AppColors.grisMetallique)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.orangeNeon),
            ),
          ],
        ),
      );
    }

    if (_notifs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.notifications_none, color: AppColors.grey, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Aucune notification',
                style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Vous êtes à jour !',
                style: TextStyle(color: AppColors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _notifs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final n = _notifs[i];
        final lue = n['lu'] == 1 || n['lu'] == true;
        final couleur = _couleur(n['type']);

        return GestureDetector(
          onTap: () => lue ? null : _marquerLue(n['id']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: lue ? AppColors.noirCarbone : AppColors.noirCarbone,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: lue ? AppColors.border : couleur.withValues(alpha: 0.4),
                width: lue ? 1 : 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône type
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: lue ? 0.06 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icone(n['type']),
                      color: lue ? AppColors.grisMetallique : couleur, size: 22),
                ),
                const SizedBox(width: 12),
                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n['titre'] ?? '',
                              style: TextStyle(
                                color: lue ? AppColors.grisMetallique : AppColors.blancPur,
                                fontWeight: lue ? FontWeight.normal : FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (!lue)
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: couleur, shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n['message'] ?? '',
                        style: TextStyle(
                          color: lue ? AppColors.grisMetallique : AppColors.blancPur.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                      if (n['created_at'] != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(n['created_at']),
                          style: const TextStyle(color: AppColors.grisMetallique, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonNotif() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.noirCarbone,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(12))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: double.infinity, height: 13,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6))),
                const SizedBox(height: 8),
                Container(width: 200, height: 11,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final maintenant = DateTime.now();
      final diff = maintenant.difference(dt);
      if (diff.inMinutes < 1) return 'À l\'instant';
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      if (diff.inDays == 1) return 'Hier';
      if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}