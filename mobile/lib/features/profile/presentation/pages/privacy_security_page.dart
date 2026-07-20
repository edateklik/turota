import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';

class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

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
          'Gizlilik ve Güvenlik',
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
          children: [
            _buildInfoPanel(context),
            const SizedBox(height: AppSpacing.xl),
            
            const _SectionHeader(title: 'HESAP GÜVENLİĞİ'),
            AppCard(
              padding: EdgeInsets.zero,
              borderRadius: AppRadius.xl,
              child: Column(
                children: [
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Şifreyi Değiştir',
                    subtitle: '3 ay önce değiştirildi',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.surfaceVariant),
                  _SettingsItem(
                    icon: Icons.security_update_good_outlined,
                    title: 'İki Faktörlü Doğrulama',
                    subtitle: 'SMS ile etkinleştirildi',
                    subtitleColor: AppColors.primary,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            const _SectionHeader(title: 'YASAL VE DOKÜMANTASYON'),
            AppCard(
              padding: EdgeInsets.zero,
              borderRadius: AppRadius.xl,
              child: Column(
                children: [
                  _SettingsItem(
                    icon: Icons.policy_outlined,
                    title: 'Gizlilik Politikası',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 64, color: AppColors.surfaceVariant),
                  _SettingsItem(
                    icon: Icons.gavel_outlined,
                    title: 'Şartlar ve Koşullar',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Danger Zone
            Container(
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_forever, color: AppColors.error),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hesabı Sil',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Bu işlem kalıcıdır ve geri alınamaz',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.error.withValues(alpha: 0.4)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel(BuildContext context) {
    return AppCard(
      borderRadius: AppRadius.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.shield, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Güveniniz Önceliğimizdir',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'TUROTA\'da gizliliğin temel bir hak olduğuna inanıyoruz. Bu ayarlar, verilerinizin nasıl kullanıldığını yönetmenize ve hesabınızın korunmasına yardımcı olur.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.surfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(Icons.verified_user, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Uçtan uca şifreleme aktif',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.outline,
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surfaceLow,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: subtitleColor ?? AppColors.outline,
                        fontWeight: subtitleColor != null ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.outlineVariant),
          ],
        ),
      ),
    );
  }
}
