import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.author,
    required this.comment,
    required this.rating,
    super.key,
  });

  final String author;
  final String comment;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.lg,
      borderColor: AppColors.savedOutlineVariant,
      child: Semantics(
        container: true,
        label: '$author, 5 üzerinden $rating yıldız. $comment',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.savedAccentLight,
                  foregroundColor: AppColors.primary,
                  child: Icon(Icons.person_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    author,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.savedTextPrimary,
                    ),
                  ),
                ),
                ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 18,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(comment, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
