import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import 'mes_commandes_screen.dart';

class ColisScreen extends StatefulWidget {
  const ColisScreen({super.key});

  @override
  State<ColisScreen> createState() => _ColisScreenState();
}

class _ColisScreenState extends State<ColisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _adresseRamassageCtrl = TextEditingController();
  final _adresseLivraisonCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _taille = 'petit';
  bool _loading = false;

  // Prix par taille
  static const Map<String, int> _prix = {'petit': 1000, 'moyen': 1500, 'grand': 2000};
  static const Map<String, IconData> _icones = {
    'petit': Icons.mail,
    'moyen': Icons.inventory_2,
    'grand': Icons.warehouse,
  };

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    _adresseRamassageCtrl.dispose();
    _adresseLivraisonCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String? _validateNom(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le nom du destinataire est requis';
    if (value.trim().length < 2) return 'Minimum 2 caractères';
    return null;
  }

  String? _validateTelephone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Le téléphone est requis';
    final cleaned = value.trim().replaceAll(' ', '');
    if (cleaned.length < 8) return 'Numéro trop court';
    if (!RegExp(r'^[0-9+]+$').hasMatch(cleaned)) return 'Numéro invalide';
    return null;
  }

  String? _validateAdresse(String? value) {
    if (value == null || value.trim().isEmpty) return 'L\'adresse est requise';
    if (value.trim().length < 5) return 'Adresse trop courte';
    return null;
  }

  Future<void> _creerColis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final response = await ApiService.post('/colis', {
        'destinataire_nom': _nomCtrl.text.trim(),
        'destinataire_telephone': _telCtrl.text.trim(),
        'adresse_ramassage': _adresseRamassageCtrl.text.trim(),
        'adresse_livraison': _adresseLivraisonCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'taille': _taille,
      });
      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _showSuccessDialog(data);
      } else {
        final data = jsonDecode(response.body);
        _showSnack(data['message'] ?? 'Erreur lors de la création');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Erreur réseau, veuillez réessayer');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccessDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Colis créé !', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Votre code de confirmation :', style: TextStyle(color: AppColors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: Text(
                data['code_confirmation'] ?? '------',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Partagez ce code avec le destinataire',
              style: TextStyle(color: AppColors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
                Navigator.push(context, MaterialPageRoute(builder: (_) => const MesCommandesScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Voir mes colis'),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () { Navigator.pop(context); _resetForm(); },
              child: const Text('Envoyer un autre colis', style: TextStyle(color: AppColors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nomCtrl.clear();
    _telCtrl.clear();
    _adresseRamassageCtrl.clear();
    _adresseLivraisonCtrl.clear();
    _descCtrl.clear();
    setState(() => _taille = 'petit');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.noirProfond,
      appBar: AppBar(
        backgroundColor: AppColors.noirCarbone,
        title: const Text('Expédier un colis', style: TextStyle(color: AppColors.blancPur)),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section destinataire
              _sectionTitle('Destinataire', Icons.person_outline),
              const SizedBox(height: 12),
              _buildField('Nom complet', _nomCtrl, Icons.person, validator: _validateNom),
              const SizedBox(height: 12),
              _buildField('Téléphone', _telCtrl, Icons.phone,
                  keyboardType: TextInputType.phone, validator: _validateTelephone),

              const SizedBox(height: 24),
              _sectionTitle('Adresses', Icons.location_on_outlined),
              const SizedBox(height: 12),
              _buildField('Adresse de ramassage', _adresseRamassageCtrl, Icons.location_on,
                  hint: 'Où venir chercher le colis', validator: _validateAdresse),
              const SizedBox(height: 12),
              _buildField('Adresse de livraison', _adresseLivraisonCtrl, Icons.location_city,
                  hint: 'Où livrer le colis', validator: _validateAdresse),

              const SizedBox(height: 24),
              _sectionTitle('Détails du colis', Icons.inventory_2_outlined),
              const SizedBox(height: 12),
              _buildField('Description (optionnel)', _descCtrl, Icons.description,
                  maxLines: 3),
              const SizedBox(height: 16),

              // Sélecteur de taille
              const Text('Taille du colis', style: TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              Row(
                children: ['petit', 'moyen', 'grand'].map((t) {
                  final selected = _taille == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _taille = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.orangeNeon.withValues(alpha: 0.1)
                              : AppColors.noirCarbone,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.orangeNeon : AppColors.grisAnthracite,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _icones[t],
                              color: selected ? AppColors.orangeNeon : AppColors.grisMetallique,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              t[0].toUpperCase() + t.substring(1),
                              style: TextStyle(
                                color: selected ? AppColors.orangeNeon : AppColors.grisMetallique,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${_prix[t]} F',
                              style: const TextStyle(color: AppColors.grisMetallique, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              // Bouton créer
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orangeNeon.withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _creerColis,
                    icon: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.blancPur, strokeWidth: 2))
                        : const Icon(Icons.send),
                    label: Text(
                      _loading ? 'Création...' : 'Créer le colis',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeNeon,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.orangeNeon, size: 18),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: AppColors.orangeNeon, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}