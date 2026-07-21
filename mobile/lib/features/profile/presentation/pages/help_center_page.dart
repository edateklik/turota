import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Yardım Merkezi',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Hero Section
            AppCard(
              borderRadius: AppRadius.xl,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nasıl yardımcı olabiliriz?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cevapları bulmak için bilgi tabanımızda arama yapın veya aşağıdaki popüler konulara göz atın.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Makale ara...',
                      hintStyle: const TextStyle(
                        color: AppColors.outlineVariant,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.outline,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceLow,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Categories List
            _HelpCategoryItem(
              icon: Icons.quiz,
              title: 'Sıkça Sorulan Sorular',
              subtitle: 'Yaygın sorular ve çözümler',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            _HelpCategoryItem(
              icon: Icons.support_agent,
              title: 'Destekle İletişime Geç',
              subtitle: 'Yerel uzmanlarımızla sohbet edin',
              onTap: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            _HelpCategoryItem(
              icon: Icons.report,
              title: 'Sorun Bildir',
              subtitle: 'Bir şeylerin bozuk olduğunu bize bildirin',
              isError: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCategoryItem extends StatelessWidget {
  const _HelpCategoryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isError = false,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = isError ? AppColors.error : AppColors.primary;
    final bgColor = isError
        ? AppColors.error.withValues(alpha: 0.1)
        : AppColors.primary.withValues(alpha: 0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppRadius.xl,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: primaryColor, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppColors.outline),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}
