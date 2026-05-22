import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_transitions.dart';
import '../../widgets/skeleton_widgets.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<dynamic> _conversations = [];
  bool _loading = true;
  bool _erreur = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() { _loading = true; _erreur = false; });
    try {
      // Route : GET /messages/{autre_id} — on charge les derniers messages
      // L'API ne fournit pas de liste de conversations, on simule depuis
      // les messages reçus. À adapter si une route /conversations est ajoutée.
      final res = await ApiService.get('/messages/recents');
      if (!mounted) return;

      if (res.statusCode == 200) {
        setState(() {
          _conversations = jsonDecode(res.body);
          _loading = false;
        });
      } else {
        // Route /messages/recents absente → fallback affichage vide propre
        setState(() { _conversations = []; _loading = false; });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; _conversations = []; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: List.generate(4, (_) => const SkeletonListTile()),
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
                style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadConversations,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
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
              child: const Icon(Icons.chat_bubble_outline, color: AppColors.grey, size: 44),
            ),
            const SizedBox(height: 20),
            const Text('Aucun message',
                style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Vos conversations apparaîtront ici',
                style: TextStyle(color: AppColors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _conversations.length,
      separatorBuilder: (_, __) => Divider(
        color: AppColors.border, height: 1, indent: 72,
      ),
      itemBuilder: (_, i) {
        final conv = _conversations[i];
        final nom = conv['nom'] ?? conv['prenom'] ?? 'Utilisateur';
        final dernierMsg = conv['dernier_message'] ?? '';
        final nonLus = conv['non_lus'] ?? 0;
        final autreId = conv['id'] ?? conv['user_id'] ?? 0;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              nom.isNotEmpty ? nom[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          title: Text(nom,
              style: TextStyle(
                color: AppColors.white,
                fontWeight: nonLus > 0 ? FontWeight.bold : FontWeight.normal,
              )),
          subtitle: Text(
            dernierMsg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: nonLus > 0 ? AppColors.white : AppColors.grey,
              fontSize: 13,
            ),
          ),
          trailing: nonLus > 0
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text('$nonLus',
                      style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                )
              : const Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 14),
          onTap: () => Navigator.push(
            context,
            AppTransitions.slideRight(
              ChatScreen(destinataireId: autreId, destinataireNom: nom),
            ),
          ).then((_) => _loadConversations()),
        );
      },
    );
  }
}