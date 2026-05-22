import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final String redirectRole;
  final String redirectRoute;
  const SplashScreen({super.key, required this.redirectRole, required this.redirectRoute});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _checkAndNavigate();
    });
  }

  Future<void> _checkAndNavigate() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await auth.tryAutoLogin();
    if (!mounted) return;

    if (auth.isAuth && auth.role == widget.redirectRole) {
      Navigator.pushReplacementNamed(context, widget.redirectRoute);
    } else if (auth.isAuth) {
      // Mauvais rôle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ce compte n\'est pas un compte ${widget.redirectRole}')),
      );
      await auth.deconnecter();
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.noirProfond,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.noirCarbone,
                          border: Border.all(color: AppColors.orangeNeon, width: 3),
                          boxShadow: [BoxShadow(color: AppColors.orangeNeon.withValues(alpha: 0.5), blurRadius: 40)],
                        ),
                        child: const Icon(Icons.delivery_dining, size: 60, color: AppColors.orangeNeon),
                      ),
                      const SizedBox(height: 32),
                      Text('GOLIVREUR', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.blancPur, letterSpacing: 4, shadows: [Shadow(color: AppColors.orangeNeon.withValues(alpha: 0.5), blurRadius: 20)])),
                      const SizedBox(height: 12),
                      Text('Commandez. Envoyez. Recevez.', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.grisMetallique, letterSpacing: 2)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40, left: 40, right: 40,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(value: _controller.value, backgroundColor: AppColors.grisAnthracite, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orangeNeon), minHeight: 3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}