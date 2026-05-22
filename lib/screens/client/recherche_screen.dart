import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import 'produits_screen.dart';

class RechercheScreen extends StatefulWidget {
  const RechercheScreen({super.key});

  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  final _searchCtrl = TextEditingController();
  final _focusNode = FocusNode();

  List<dynamic> _boutiques = [];
  bool _loading = false;
  bool _hasSearched = false;
  String _lastQuery = '';
  Timer? _debounce;

  final List<String> _recents = ['Poulet braisé', 'Pharmacie', 'Pizza'];
  final List<String> _tendances = [
    'Pizza', 'Pharmacie', 'Poulet braisé', 'Boulangerie', 'Mode', 'Sushi'
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim();
    if (query == _lastQuery) return;
    _lastQuery = query;

    if (query.isEmpty) {
      setState(() { _boutiques = []; _hasSearched = false; _loading = false; });
      _debounce?.cancel();
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _rechercher(query));
  }

  Future<void> _rechercher(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _loading = true);

    try {
      // Route réelle : GET /commercants/recherche?q=...
      final res = await ApiService.get('/commercants/recherche?q=${Uri.encodeComponent(query)}');

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _boutiques = data is List ? data : (data['data'] ?? data['commercants'] ?? []);
          _hasSearched = true;
          _loading = false;
        });
      } else {
        setState(() { _boutiques = []; _hasSearched = true; _loading = false; });
      }

      if (!_recents.contains(query)) {
        setState(() {
          _recents.insert(0, query);
          if (_recents.length > 5) _recents.removeLast();
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _hasSearched = true; });
    }
  }

  void _lancerRecherche(String query) {
    _searchCtrl.text = query;
    _searchCtrl.selection = TextSelection.fromPosition(TextPosition(offset: query.length));
    _rechercher(query);
  }

  void _supprimerRecent(String query) => setState(() => _recents.remove(query));

  @override
  Widget build(BuildContext context) {
    final hasText = _searchCtrl.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.noirProfond,
      appBar: AppBar(
        backgroundColor: AppColors.noirCarbone,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.noirMat,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grisAnthracite),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  focusNode: _focusNode,
                  style: const TextStyle(color: AppColors.blancPur, fontSize: 15),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (v) { if (v.trim().isNotEmpty) _rechercher(v.trim()); },
                  decoration: InputDecoration(
                    hintText: 'Boutiques, produits...',
                    hintStyle: TextStyle(color: AppColors.grisMetallique.withValues(alpha: 0.7), fontSize: 14),
                    prefixIcon: _loading
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: AppColors.orangeNeon, strokeWidth: 2)),
                          )
                        : const Icon(Icons.search, color: AppColors.grisMetallique, size: 20),
                    suffixIcon: hasText
                        ? IconButton(
                            icon: const Icon(Icons.close, color: AppColors.grisMetallique, size: 18),
                            onPressed: () { _searchCtrl.clear(); _focusNode.requestFocus(); },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: AppColors.orangeNeon, fontSize: 14)),
            ),
          ],
        ),
      ),
      body: hasText && _hasSearched ? _buildResultats() : _buildAccueil(),
    );
  }

  Widget _buildAccueil() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_recents.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recherches récentes', style: TextStyle(color: AppColors.blancPur, fontSize: 15, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => setState(() => _recents.clear()),
                child: const Text('Tout effacer', style: TextStyle(color: AppColors.grisMetallique, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ..._recents.map((r) => ListTile(
            leading: const Icon(Icons.history, color: AppColors.grisMetallique, size: 20),
            title: Text(r, style: const TextStyle(color: AppColors.blancPur, fontSize: 14)),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: AppColors.grisMetallique, size: 16),
              onPressed: () => _supprimerRecent(r),
            ),
            contentPadding: EdgeInsets.zero,
            dense: true,
            onTap: () => _lancerRecherche(r),
          )),
          const SizedBox(height: 20),
        ],
        const Text('Tendances', style: TextStyle(color: AppColors.blancPur, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tendances.map((t) => GestureDetector(
            onTap: () => _lancerRecherche(t),
            child: Chip(
              label: Text(t, style: const TextStyle(color: AppColors.orangeNeon, fontSize: 13)),
              backgroundColor: AppColors.noirCarbone,
              side: const BorderSide(color: AppColors.orangeNeon),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildResultats() {
    if (_boutiques.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: AppColors.grisMetallique, size: 64),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat pour\n"${_searchCtrl.text.trim()}"',
              style: const TextStyle(color: AppColors.blancPur, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text('Essayez un autre mot-clé', style: TextStyle(color: AppColors.grisMetallique)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${_boutiques.length} boutique(s) pour "${_searchCtrl.text.trim()}"',
          style: const TextStyle(color: AppColors.grisMetallique, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _sectionHeader('Boutiques', _boutiques.length),
        const SizedBox(height: 10),
        ..._boutiques.map((b) => _buildBoutiqueTile(b)),
      ],
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColors.blancPur, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.orangeNeon.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count', style: const TextStyle(color: AppColors.orangeNeon, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildBoutiqueTile(dynamic b) {
    final estOuvert = b['ouvert'] == true || b['ouvert'] == 1;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProduitsScreen(commercantId: b['id'], commercantNom: b['nom_boutique'] ?? '')),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.noirCarbone,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grisAnthracite),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.orangeNeon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.store, color: AppColors.orangeNeon, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['nom_boutique'] ?? '', style: const TextStyle(color: AppColors.blancPur, fontWeight: FontWeight.bold)),
                  if (b['categorie'] != null)
                    Text(b['categorie'], style: const TextStyle(color: AppColors.grisMetallique, fontSize: 12)),
                  if (b['adresse'] != null)
                    Text(b['adresse'], style: const TextStyle(color: AppColors.grisMetallique, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: estOuvert ? AppColors.vertNeon.withValues(alpha: 0.1) : AppColors.rougeNeon.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                estOuvert ? 'Ouvert' : 'Fermé',
                style: TextStyle(
                  color: estOuvert ? AppColors.vertNeon : AppColors.rougeNeon,
                  fontSize: 11, fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: AppColors.grisMetallique, size: 14),
          ],
        ),
      ),
    );
  }
}