import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  List<dynamic> _zones = [];
  bool _loadingZones = true;
  int? _zoneId;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final res = await ApiService.get('/zones');
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() {
          _zones = jsonDecode(res.body);
          _loadingZones = false;
        });
      } else {
        setState(() => _loadingZones = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingZones = false);
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  String? _validateNom(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le nom est requis';
    if (value.trim().length < 2) return 'Minimum 2 caractères';
    return null;
  }

  String? _validatePrenom(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le prénom est requis';
    if (value.trim().length < 2) return 'Minimum 2 caractères';
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirmez votre mot de passe';
    if (value != _passwordCtrl.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  void _inscrire() async {
    if (!_formKey.currentState!.validate()) return;
    if (_zoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez choisir votre ville'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    final result = await auth.inscrireAvecMessage(
      _nomCtrl.text.trim(),
      _prenomCtrl.text.trim(),
      _telCtrl.text.trim(),
      _passwordCtrl.text,
      'client',
      zoneId: _zoneId,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie ! Connectez-vous.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$result'), backgroundColor: AppColors.error),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Header
                  const SizedBox(height: 16),
                  Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.blancPur),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.noirCarbone,
                      border: Border.all(color: AppColors.orangeNeon, width: 2),
                      boxShadow: [BoxShadow(color: AppColors.orangeNeon.withValues(alpha: 0.3), blurRadius: 20)],
                    ),
                    child: const Icon(Icons.person_add, size: 40, color: AppColors.orangeNeon),
                  ),
                  const SizedBox(height: 16),
                  const Text('Créer un compte',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.blancPur)),
                  const SizedBox(height: 4),
                  const Text('Rejoignez GoLivreur aujourd\'hui',
                      style: TextStyle(fontSize: 13, color: AppColors.grisMetallique, letterSpacing: 1)),
                  const SizedBox(height: 32),

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
                        // Nom & Prénom
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nomCtrl,
                              textCapitalization: TextCapitalization.words,
                              validator: _validateNom,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: const InputDecoration(labelText: 'Nom', prefixIcon: Icon(Icons.badge)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _prenomCtrl,
                              textCapitalization: TextCapitalization.words,
                              validator: _validatePrenom,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: const InputDecoration(labelText: 'Prénom', prefixIcon: Icon(Icons.person)),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),

                        // Téléphone
                        TextFormField(
                          controller: _telCtrl,
                          keyboardType: TextInputType.phone,
                          validator: _validateTelephone,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                            prefixIcon: Icon(Icons.phone),
                            hintText: 'Ex: 0701234567',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mot de passe
                        TextFormField(
                          controller: _passwordCtrl,
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
                        const SizedBox(height: 16),

                        // Confirmer mot de passe
                        TextFormField(
                          controller: _confirmPasswordCtrl,
                          obscureText: _obscureConfirm,
                          validator: _validateConfirmPassword,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration: InputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.grey,
                              ),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sélecteur de ville
                        _loadingZones
                            ? Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.noirMat,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.grisAnthracite),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(color: AppColors.orangeNeon, strokeWidth: 2),
                                  ),
                                ),
                              )
                            : DropdownButtonFormField<int>(
                                value: _zoneId,
                                dropdownColor: AppColors.noirCarbone,
                                style: const TextStyle(color: AppColors.blancPur),
                                decoration: const InputDecoration(
                                  labelText: 'Votre ville',
                                  prefixIcon: Icon(Icons.location_city),
                                ),
                                items: _zones
                                    .map((z) => DropdownMenuItem<int>(
                                          value: z['id'] as int,
                                          child: Text(z['nom'].toString(),
                                              style: const TextStyle(color: AppColors.blancPur)),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _zoneId = v),
                                validator: (v) => v == null ? 'Choisissez votre ville' : null,
                              ),
                        const SizedBox(height: 24),

                        // Bouton inscription
                        SizedBox(
                          width: double.infinity, height: 55,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [BoxShadow(color: AppColors.orangeNeon.withValues(alpha: 0.4), blurRadius: 15)],
                            ),
                            child: ElevatedButton(
                              onPressed: _loading ? null : _inscrire,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.orangeNeon,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              child: _loading
                                  ? const SizedBox(width: 24, height: 24,
                                      child: CircularProgressIndicator(color: AppColors.blancPur, strokeWidth: 2))
                                  : const Text("S'inscrire",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: "Déjà un compte ? ",
                        style: const TextStyle(color: AppColors.grisMetallique),
                        children: const [
                          TextSpan(
                            text: "Se connecter",
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}