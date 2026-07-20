import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';

class PlaceDetailHeader extends StatelessWidget {
  const PlaceDetailHeader({
    required this.isBookmarked,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.onBookmarkPressed,
    super.key,
  });

  final bool isBookmarked;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onBookmarkPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            IconButton(
              key: const ValueKey('place-detail-back'),
              onPressed: onBackPressed,
              tooltip: 'Geri dön',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Expanded(
              child: Text(
                'Mekan Detayı',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.savedTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('place-detail-share'),
              onPressed: onSharePressed,
              tooltip: 'Mekanı paylaş',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.ios_share_rounded),
            ),
            IconButton(
              key: const ValueKey('place-detail-bookmark'),
              onPressed: onBookmarkPressed,
              tooltip: isBookmarked ? 'Kaydı kaldır' : 'Mekanı kaydet',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
