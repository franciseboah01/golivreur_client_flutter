import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final String redirectRole;
  final String redirectRoute;
  const LoginScreen({super.key, required this.redirectRole, required this.redirectRoute});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateTelephone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le téléphone est requis';
    final cleaned = value.trim().replaceAll(' ', '');
    if (cleaned.length < 8) return 'Numéro trop court (minimum 8 chiffres)';
    if (!RegExp(r'^[0-9+]+$').hasMatch(cleaned)) return 'Numéro invalide';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Le mot de passe est requis';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.connecter(
      _telephoneController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      if (auth.role == widget.redirectRole) {
        Navigator.pushReplacementNamed(context, widget.redirectRoute);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ce compte n\'est pas un compte ${widget.redirectRole}')),
        );
        await auth.deconnecter();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Téléphone ou mot de passe incorrect'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.noirProfond, Color(0xFF1A0A00)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.noirCarbone,
                        border: Border.all(color: AppColors.orangeNeon, width: 2),
                        boxShadow: [BoxShadow(color: AppColors.orangeNeon.withValues(alpha: 0.3), blurRadius: 30)],
                      ),
                      child: const Icon(Icons.delivery_dining, size: 50, color: AppColors.orangeNeon),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'GoLivreur',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blancPur,
                        shadows: [Shadow(color: AppColors.orangeNeon.withValues(alpha: 0.5), blurRadius: 20)],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La livraison du futur',
                      style: TextStyle(fontSize: 14, color: AppColors.grisMetallique, letterSpacing: 2),
                    ),
                    const SizedBox(height: 48),

                    // Formulaire
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.noirCarbone.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.orangeNeon.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          // Téléphone
                          TextFormField(
                            controller: _telephoneController,
                            keyboardType: TextInputType.phone,
                            validator: _validateTelephone,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              labelText: 'Téléphone',
                              prefixIcon: Icon(Icons.phone),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mot de passe
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: _validatePassword,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.grey,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Bouton connexion
                          SizedBox(
                            width: double.infinity, height: 55,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [BoxShadow(color: AppColors.orangeNeon.withValues(alpha: 0.4), blurRadius: 15)],
                              ),
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.orangeNeon,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                ),
                                child: _loading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.blancPur, strokeWidth: 2))
                                    : const Text('Se connecter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: RichText(
                        text: TextSpan(
                          text: "Pas de compte ? ",
                          style: const TextStyle(color: AppColors.grisMetallique),
                          children: const [
                            TextSpan(
                              text: "S'inscrire",
                              style: TextStyle(
                                color: AppColors.orangeNeon,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}