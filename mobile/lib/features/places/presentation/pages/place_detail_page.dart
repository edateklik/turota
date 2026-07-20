import 'package:flutter/material.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_bottom_navigation.dart';
import 'package:turota_mobile/core/widgets/app_button.dart';
import 'package:turota_mobile/core/widgets/app_scaffold.dart';
import 'package:turota_mobile/features/places/presentation/widgets/ai_match_card.dart';
import 'package:turota_mobile/features/places/presentation/widgets/opening_hours_card.dart';
import 'package:turota_mobile/features/places/presentation/widgets/place_detail_header.dart';
import 'package:turota_mobile/features/places/presentation/widgets/place_feature_card.dart';
import 'package:turota_mobile/features/places/presentation/widgets/review_card.dart';

class PlaceDetailPage extends StatefulWidget {
  const PlaceDetailPage({super.key});

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  static const _place = _PlaceDetailUiModel(
    name: 'Monstera Coffee House',
    tags: ['Botanik Kafe', 'Sessiz', '₺₺'],
    description:
        'Şehrin temposundan uzaklaşabileceğiniz, bitkilerle çevrili sakin bir '
        'kahve deneyimi. Özenle hazırlanan kahveleri, gün boyu doğal ışık alan '
        'çalışma köşeleri ve dingin atmosferiyle üretmek ve dinlenmek için '
        'ideal.',
    features: [
      _PlaceFeatureUiModel('Wi-Fi', Icons.wifi_rounded),
      _PlaceFeatureUiModel('Priz', Icons.power_rounded),
      _PlaceFeatureUiModel('Pour Over', Icons.coffee_rounded),
      _PlaceFeatureUiModel('Sessiz Alan', Icons.volume_off_rounded),
    ],
    reviews: [
      _ReviewUiModel(
        author: 'Elif K.',
        rating: 5,
        comment:
            'Bitkiler, gün ışığı ve sakin müzik harika. Uzun süre çalışmak '
            'için şehirdeki favori yerim oldu.',
      ),
      _ReviewUiModel(
        author: 'Mert A.',
        rating: 4,
        comment:
            'Pour over kahvesi çok başarılı. Hafta içi sabahları oldukça '
            'sessiz ve çalışanlar çok ilgili.',
      ),
    ],
    openingHours: [
      ('Pazartesi - Cuma', '08:00 - 22:00'),
      ('Cumartesi', '09:00 - 23:00'),
      ('Pazar', '09:00 - 21:00'),
    ],
  );

  bool _isBookmarked = true;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    _showMessage(
      _isBookmarked
          ? '${_place.name} kaydedilenlere eklendi.'
          : '${_place.name} kaydedilenlerden çıkarıldı.',
    );
  }

  void _handleBottomNavigation(int index) {
    if (index == 0) {
      Navigator.of(context).maybePop();
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRouter.saved);
    } else if (index == 2) {
      _showMessage('AI asistan ekranı yakında eklenecek.');
    } else if (index == 3) {
      _showMessage('Profil ekranı yakında eklenecek.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.savedBackground,
      padding: EdgeInsets.zero,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: 0,
        onDestinationSelected: _handleBottomNavigation,
      ),
      body: Column(
        children: [
          PlaceDetailHeader(
            isBookmarked: _isBookmarked,
            onBackPressed: () => Navigator.of(context).maybePop(),
            onSharePressed: () =>
                _showMessage('Paylaşım özelliği yakında eklenecek.'),
            onBookmarkPressed: _toggleBookmark,
          ),
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('place-detail-scroll'),
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _BotanicalHero(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _place.name,
                              key: const ValueKey('place-detail-title'),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: AppColors.savedTextPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _TagWrap(tags: _place.tags),
                            const SizedBox(height: AppSpacing.lg),
                            const _SectionTitle('Mekan Hakkında'),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _place.description,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.savedTextSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            const _SectionTitle('Özellikler'),
                            const SizedBox(height: AppSpacing.md),
                            _FeatureGrid(features: _place.features),
                            const SizedBox(height: AppSpacing.xl),
                            const _SectionTitle('Yorumlar'),
                            const SizedBox(height: AppSpacing.md),
                            for (
                              var index = 0;
                              index < _place.reviews.length;
                              index++
                            ) ...[
                              ReviewCard(
                                author: _place.reviews[index].author,
                                comment: _place.reviews[index].comment,
                                rating: _place.reviews[index].rating,
                              ),
                              if (index != _place.reviews.length - 1)
                                const SizedBox(height: AppSpacing.md),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            const _SectionTitle('Çalışma Saatleri'),
                            const SizedBox(height: AppSpacing.md),
                            OpeningHoursCard(hours: _place.openingHours),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              key: const ValueKey('place-directions'),
                              label: 'Yol Tarifi Al',
                              icon: Icons.directions_rounded,
                              onPressed: () => _showMessage(
                                'Harita entegrasyonu yakında eklenecek.',
                              ),
                              isFullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotanicalHero extends StatelessWidget {
  const _BotanicalHero();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Bitkilerle çevrili Monstera Coffee House illüstrasyonu',
      child: SizedBox(
        height: 330,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              bottom: AppSpacing.xl,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.xl),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFDCEED8),
                        Color(0xFF89B98B),
                        Color(0xFF315F49),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      const Positioned(
                        left: 20,
                        top: 26,
                        child: Icon(
                          Icons.eco_rounded,
                          size: 100,
                          color: Color(0x99619A65),
                        ),
                      ),
                      const Positioned(
                        right: 22,
                        top: 38,
                        child: Icon(
                          Icons.local_florist_rounded,
                          size: 126,
                          color: Color(0xAA1F593C),
                        ),
                      ),
                      Positioned(
                        left: 54,
                        right: 54,
                        bottom: 28,
                        child: Container(
                          height: 86,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6E4934),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.coffee_rounded,
                              size: 62,
                              color: Color(0xFFFFF4D8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              bottom: 0,
              child: AiMatchCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagWrap extends StatelessWidget {
  const _TagWrap({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final tag in tags)
          Chip(
            label: Text(tag),
            backgroundColor: AppColors.savedAccentLight,
            side: const BorderSide(color: AppColors.savedOutlineVariant),
            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AppColors.savedTextPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.features});

  final List<_PlaceFeatureUiModel> features;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        final width =
            (constraints.maxWidth - ((columns - 1) * AppSpacing.sm)) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final feature in features)
              SizedBox(
                width: width,
                child: PlaceFeatureCard(
                  label: feature.label,
                  icon: feature.icon,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PlaceDetailUiModel {
  const _PlaceDetailUiModel({
    required this.name,
    required this.tags,
    required this.description,
    required this.features,
    required this.reviews,
    required this.openingHours,
  });

  final String name;
  final List<String> tags;
  final String description;
  final List<_PlaceFeatureUiModel> features;
  final List<_ReviewUiModel> reviews;
  final List<(String, String)> openingHours;
}

class _PlaceFeatureUiModel {
  const _PlaceFeatureUiModel(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _ReviewUiModel {
  const _ReviewUiModel({
    required this.author,
    required this.rating,
    required this.comment,
  });

  final String author;
  final int rating;
  final String comment;
}
