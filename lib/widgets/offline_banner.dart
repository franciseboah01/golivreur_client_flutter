import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../utils/app_colors.dart';
import '../config/api_config.dart';

/// Surveille la connectivité réseau via un ping léger sur l'API.
/// Affiche une bannière animée en haut quand hors ligne.
///
/// Usage :
///   Scaffold(
///     body: OfflineBanner(child: MonWidget()),
///   )
class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  bool _isOffline = false;
  Timer? _timer;
  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _checkConnectivity();
    // Vérification toutes les 10 secondes
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkConnectivity());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final wasOffline = _isOffline;
    try {
      // Ping léger sur route publique
      final res = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/categories'))
          .timeout(const Duration(seconds: 4));
      final offline = res.statusCode >= 500;
      if (!mounted) return;
      setState(() => _isOffline = offline);
      if (_isOffline && !wasOffline) _animCtrl.forward();
      if (!_isOffline && wasOffline) _animCtrl.reverse();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isOffline = true);
      if (!wasOffline) _animCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SlideTransition(
          position: _slideAnim,
          child: _isOffline
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: AppColors.error,
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, color: AppColors.white, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Pas de connexion internet',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _checkConnectivity,
                          child: const Text(
                            'Réessayer',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}