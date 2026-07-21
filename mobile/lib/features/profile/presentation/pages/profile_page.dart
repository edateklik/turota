import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/theme/app_typography.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () {},
        ),
        title: const Text(
          AppConstants.brandName,
          style: AppTypography.splashBrand,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl * 3, // Space for bottom nav
        ),
        child: Column(
          children: [
            // Profile Header
            const _ProfileHeader(),
            const SizedBox(height: AppSpacing.xl),

            // Sections
            _ProfileSection(
              title: 'HESAP',
              children: [
                _ProfileListItem(
                  icon: Icons.person_outline,
                  label: 'Profili Düzenle',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.editProfile);
                  },
                ),
                _ProfileListItem(
                  icon: Icons.lock_outline,
                  label: 'Gizlilik ve Güvenlik',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.privacySecurity);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _ProfileSection(
              title: 'TERCİHLER',
              children: [
                _ProfileListItem(
                  icon: Icons.notifications_none,
                  label: 'Bildirimler',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.notifications);
                  },
                ),
                _ProfileListItem(
                  icon: Icons.location_on_outlined,
                  label: 'Konum İzni',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.locationSettings);
                  },
                ),
                _ProfileListItem(
                  icon: Icons.language,
                  label: 'Dil',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.languageSelection);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _ProfileSection(
              title: 'DESTEK',
              children: [
                _ProfileListItem(
                  icon: Icons.help_outline,
                  label: 'Yardım Merkezi',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.helpCenter);
                  },
                ),
                _ProfileListItem(
                  icon: Icons.info_outline,
                  label: 'TUROTA Hakkında',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.about);
                  },
                ),
                _ProfileListItem(
                  icon: Icons.logout,
                  label: 'Çıkış Yap',
                  isDestructive: true,
                  onTap: () async {
                    await ref.read(authRepositoryProvider).logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacementNamed(AppRouter.splash);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final fullName = userState.value != null 
        ? '${userState.value!.firstName} ${userState.value!.lastName}' 
        : '...';

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceLow,
            border: Border.all(color: AppColors.surface, width: 4),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const ClipOval(
            child: Icon(
              Icons.person,
              size: 50,
              color: AppColors.outlineVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          fullName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.xl,
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceVariant),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  const _ProfileListItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.primary : AppColors.textPrimary;
    final iconColor = isDestructive
        ? AppColors.primary
        : AppColors.primaryContainer;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 20,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: color),
              ),
            ),
            if (!isDestructive)
              const Icon(
                Icons.chevron_right,
                color: AppColors.outline,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
