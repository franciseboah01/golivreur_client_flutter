import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Widget de base animé pour le skeleton loading
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: _animation.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

// ── Skeletons spécifiques ────────────────────────────────────────────────────

/// Skeleton pour une carte boutique horizontale (HomeClient)
class SkeletonBoutiqueCard extends StatelessWidget {
  const SkeletonBoutiqueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SkeletonBox(width: 180, height: 80, borderRadius: 0),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 13),
                const SizedBox(height: 6),
                SkeletonBox(width: 80, height: 11),
                const SizedBox(height: 6),
                SkeletonBox(width: 60, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton pour une catégorie (HomeClient)
class SkeletonCategorie extends StatelessWidget {
  const SkeletonCategorie({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          SkeletonBox(width: 56, height: 56, borderRadius: 16),
          const SizedBox(height: 6),
          SkeletonBox(width: 44, height: 10),
        ],
      ),
    );
  }
}

/// Skeleton pour une ligne de liste (boutiques, commandes, colis)
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SkeletonBox(width: 50, height: 50, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 13),
                const SizedBox(height: 8),
                SkeletonBox(width: 140, height: 11),
                const SizedBox(height: 6),
                SkeletonBox(width: 100, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton pour une carte produit (grille)
class SkeletonProduitCard extends StatelessWidget {
  const SkeletonProduitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SkeletonBox(width: double.infinity, height: 100, borderRadius: 0),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 13),
                const SizedBox(height: 6),
                SkeletonBox(width: 80, height: 13),
                const SizedBox(height: 10),
                SkeletonBox(width: double.infinity, height: 32, borderRadius: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton pour une commande/colis dans MesCommandes
class SkeletonCommandeCard extends StatelessWidget {
  const SkeletonCommandeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 130, height: 13),
              SkeletonBox(width: 70, height: 24, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonBox(width: 100, height: 20),
          const SizedBox(height: 8),
          SkeletonBox(width: 200, height: 11),
        ],
      ),
    );
  }
}