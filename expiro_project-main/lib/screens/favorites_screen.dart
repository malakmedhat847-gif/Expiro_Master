import 'package:expiro_project/state/items_store.dart';
import 'package:expiro_project/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../models/items.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c      = AppColors.of(context);
    final store  = ItemsScope.of(context);
    final isDark = c.isDark;

    final favorites = store.items.where((item) => item.isFavorite).toList();

    return Container(
      decoration: !isDark
          ? const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD6CFCF), Color(0xFFD5CECE)],
        ),
      )
          : null,
      child: SafeArea(
        child: Column(
          children: [
            // ── AppBar (no back button) ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.favorite_rounded, color: AppColors.red, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Favorites',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: c.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${favorites.length} item${favorites.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 72, color: c.textHint),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the ♥ on any item to add it here',
                      style: TextStyle(fontSize: 13, color: c.textHint),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: favorites.length,
                itemBuilder: (ctx, i) => _FavoriteItemCard(
                  item: favorites[i],
                  onUnfavorite: () =>
                      ItemsScope.read(context).toggleFavorite(favorites[i].id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onUnfavorite;

  const _FavoriteItemCard({required this.item, required this.onUnfavorite});

  @override
  Widget build(BuildContext context) {
    final c      = AppColors.of(context);
    final isDark = c.isDark;

    final daysText = item.daysLeft < 0
        ? 'Expired ${-item.daysLeft} day(s) ago'
        : item.daysLeft == 0
        ? 'Expires today'
        : 'Expires in ${item.daysLeft} day(s)';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF281C30) : const Color(0xFFEAEAF2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.red.withOpacity(0.5), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: item.statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.type.icon, color: item.statusColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: c.textPrimary)),
                  const SizedBox(height: 2),
                  Text(item.type.label,
                      style: TextStyle(color: c.textSecondary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(daysText,
                      style: TextStyle(color: item.statusColor, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(item.statusLabel,
                  style: TextStyle(color: item.statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onUnfavorite,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.red.withOpacity(0.3)),
                ),
                child: const Icon(Icons.favorite_rounded, color: AppColors.red, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
