import 'package:flutter/material.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/theme/app_typography.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCvMxp3Sg5AoGJi3_BNFH9s4Q-BldYT17zYVyRa0ygClofFPArLFLd5cQoXSy_XMtwrmVbCFdpKMoBZobrFBQ7gKvrtzUaBsGyD29sCI5-1_8rakCaI_m_8S7EEZdQ8l0WvW6J9GWzQ4Kpr736M981Bg3oeCOGGgxKU4vJVRO3TMgwxfQeCBERiOaY3QDJ8JLAbRa6SiICtAz74QM1xlcwnUcDF3SNNS8dgb5qM9Feag0DRzoe-FtmL',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Sarah Johnson',
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
    final iconColor = isDestructive ? AppColors.primary : AppColors.primaryContainer;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
              ),
            ),
            if (!isDestructive)
              const Icon(Icons.chevron_right, color: AppColors.outline, size: 24),
          ],
        ),
      ),
    );
  }
}
