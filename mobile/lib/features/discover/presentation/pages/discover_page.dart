import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/weather_controller.dart';
import '../controllers/places_controller.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';
import 'package:turota_mobile/features/discover/presentation/widgets/neighborhood_detail_bottom_sheet.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  // We'll build the header dynamically in the build method.

  static const _categories = [
    _DiscoverCategoryUiModel('Gastronomi', Icons.restaurant_rounded),
    _DiscoverCategoryUiModel('Sanat ve Kültür', Icons.museum_rounded),
    _DiscoverCategoryUiModel('Şehrin Işıkları', Icons.celebration_rounded),
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectTemporaryDestination(int index) {
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
      return;
    }
    const messages = {
      2: 'AI asistan ekranı yakında eklenecek.',
      3: 'Profil ekranı yakında eklenecek.',
    };
    final message = messages[index];
    if (message != null) {
      _showMessage(message);
    }
  }

  Widget _buildWeatherSection() {
    final weatherState = ref.watch(weatherControllerProvider);

    return weatherState.when(
      data: (forecast) {
        final days = forecast.dailyForecasts.asMap().entries.map((entry) {
          final index = entry.key;
          final dto = entry.value;
          final isToday = index == 0;
          final dayName = isToday ? 'Bugün' : _getDayName(dto.date.weekday);

          return _WeatherDayUiModel(
            dayName,
            '${dto.maxTemperature.round()}°',
            _getWeatherIcon(dto.weatherCode),
            isToday,
          );
        }).toList();

        return _WeatherStrip(days: days);
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Hava durumu yüklenemedi',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
              TextButton(
                onPressed: () => ref.refresh(weatherControllerProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbySection() {
    final placesState = ref.watch(nearestPlacesControllerProvider);

    return placesState.when(
      data: (places) {
        if (places.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Text('Yakınınızda mekan bulunamadı.'),
          );
        }

        return Column(
          children: [
            for (final place in places) ...[
              _NearbyPlaceCard(
                place: _NearbyPlaceUiModel(
                  name: place.name,
                  description: place.address,
                  distance: place.distanceMeters != null
                      ? '${(place.distanceMeters! / 1000).toStringAsFixed(1)} km uzaklıkta'
                      : 'Bilinmeyen uzaklık',
                  transportIcon: Icons.location_on_rounded,
                  imageUrl:
                      'https://picsum.photos/seed/${place.id}/400/300', // Replace with real image if API supports
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => NeighborhoodDetailBottomSheet(
                      name: place.name,
                      description: place.address,
                      imageUrl: 'https://picsum.photos/seed/${place.id}/400/300',
                      distance: place.distanceMeters != null
                          ? '${(place.distanceMeters! / 1000).toStringAsFixed(1)} km uzaklıkta'
                          : 'Bilinmeyen uzaklık',
                    ),
                  );
                },
              ),
              if (place != places.last) const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Mekanlar yüklenemedi',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
              TextButton(
                onPressed: () => ref.refresh(nearestPlacesControllerProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const names = {
      1: 'Pzt',
      2: 'Sal',
      3: 'Çar',
      4: 'Per',
      5: 'Cum',
      6: 'Cmt',
      7: 'Paz',
    };
    return names[weekday] ?? '';
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0 || code == 1) return Icons.wb_sunny_rounded;
    if (code == 2 || code == 3) return Icons.cloud_queue_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 55) return Icons.grain_rounded;
    if (code >= 61 && code <= 65) return Icons.water_drop_rounded;
    if (code >= 71 && code <= 75) return Icons.ac_unit_rounded;
    if (code >= 95 && code <= 99) return Icons.thunderstorm_rounded;
    return Icons.cloud_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(currentUserProvider);
    final userName = userState.value?.firstName ?? '...';

    final headerModel = _DiscoverHeaderModel(
      userName: userName,
      dateLabel: '12 Ekim Cumartesi',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        key: const ValueKey('discover-scroll-view'),
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DiscoverHeader(
              model: headerModel,
              onNotificationsPressed: () =>
                  _showMessage('Bildirimler yakında eklenecek.'),
              onProfilePressed: () => _selectTemporaryDestination(3),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionTitle('7 Günlük Hava Durumu'),
                  const SizedBox(height: AppSpacing.md),
                  _buildWeatherSection(),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionTitle('Mevcut Konumunuz'),
                  const SizedBox(height: AppSpacing.md),
                  _LocationPreviewCard(
                    onMapPressed: () =>
                        Navigator.of(context).pushNamed(AppRouter.map),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionTitle('Kategoriye Göre Keşfet'),
                  const SizedBox(height: AppSpacing.md),
                  _CategoryGrid(
                    categories: _categories,
                    onCategoryPressed: (category) {
                      if (category.label == 'Şehrin Işıkları') {
                        Navigator.of(context).pushNamed(AppRouter.cityLights);
                      } else if (category.label == 'Sanat ve Kültür') {
                        Navigator.of(context).pushNamed(AppRouter.artCulture);
                      } else if (category.label == 'Gastronomi') {
                        Navigator.of(context).pushNamed(AppRouter.gastronomy);
                      } else {
                        _showMessage(
                          '${category.label} kategorisi yakında açılacak.',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _NearbyHeader(
                    onSeeAllPressed: () =>
                        _showMessage('Tüm mekanlar ekranı yakında eklenecek.'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildNearbySection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverHeaderModel {
  const _DiscoverHeaderModel({required this.userName, required this.dateLabel});

  final String userName;
  final String dateLabel;
}

class _WeatherDayUiModel {
  const _WeatherDayUiModel(
    this.day,
    this.temperature,
    this.icon,
    this.isActive,
  );

  final String day;
  final String temperature;
  final IconData icon;
  final bool isActive;
}

class _DiscoverCategoryUiModel {
  const _DiscoverCategoryUiModel(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _NearbyPlaceUiModel {
  const _NearbyPlaceUiModel({
    required this.name,
    required this.description,
    required this.distance,
    required this.transportIcon,
    required this.imageUrl,
  });

  final String name;
  final String description;
  final String distance;
  final IconData transportIcon;
  final String imageUrl;
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader({
    required this.model,
    required this.onNotificationsPressed,
    required this.onProfilePressed,
  });

  final _DiscoverHeaderModel model;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onProfilePressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        border: const Border(bottom: BorderSide(color: AppColors.primary)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Günaydın, ${model.userName}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      model.dateLabel,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                key: const ValueKey('discover-notifications'),
                onPressed: onNotificationsPressed,
                tooltip: 'Bildirimler',
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              const SizedBox(width: AppSpacing.sm),
              Semantics(
                button: true,
                label: 'Profil',
                child: InkWell(
                  key: const ValueKey('discover-profile-avatar'),
                  onTap: onProfilePressed,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary,
                      child: Text(
                        'Ş',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _WeatherStrip extends StatelessWidget {
  const _WeatherStrip({required this.days});

  final List<_WeatherDayUiModel> days;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('weather-horizontal-scroll'),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < days.length; index++) ...[
            _WeatherDayCard(day: days[index]),
            if (index != days.length - 1) const SizedBox(width: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _WeatherDayCard extends StatelessWidget {
  const _WeatherDayCard({required this.day});

  final _WeatherDayUiModel day;

  @override
  Widget build(BuildContext context) {
    final foreground = day.isActive
        ? AppColors.onPrimary
        : AppColors.textPrimary;
    return Container(
      key: ValueKey('weather-${day.day}'),
      width: 78,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: day.isActive ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: day.isActive ? AppColors.primary : AppColors.primary,
        ),
      ),
      child: Column(
        children: [
          Text(
            day.day,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: foreground),
          ),
          const SizedBox(height: AppSpacing.sm),
          Icon(day.icon, color: day.isActive ? foreground : AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            day.temperature,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _LocationPreviewCard extends StatefulWidget {
  const _LocationPreviewCard({required this.onMapPressed});

  final VoidCallback onMapPressed;

  @override
  State<_LocationPreviewCard> createState() => _LocationPreviewCardState();
}

class _LocationPreviewCardState extends State<_LocationPreviewCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = Tween<double>(
      begin: 0.7,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
    _pulseController.forward().then((_) {
      if (mounted) {
        _pulseController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.xl,
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
      child: SizedBox(
        height: 190,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl - 1),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: FlutterMap(
                    options: const MapOptions(
                      initialCenter: LatLng(40.990, 29.020),
                      initialZoom: 14.0,
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.turota.mobile',
                      ),
                    ],
                  ),
                ),
              ),
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              const Icon(
                Icons.location_on_rounded,
                size: 50,
                color: AppColors.primaryContainer,
              ),
              Positioned(
                bottom: AppSpacing.md,
                child: FilledButton.icon(
                  key: const ValueKey('full-map-button'),
                  onPressed: widget.onMapPressed,
                  icon: const Icon(Icons.map_outlined, size: 20),
                  label: const Text('Tam Haritayı Gör'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.onCategoryPressed,
  });

  final List<_DiscoverCategoryUiModel> categories;
  final ValueChanged<_DiscoverCategoryUiModel> onCategoryPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < categories.length; index++) ...[
          Expanded(
            child: _CategoryCard(
              category: categories[index],
              onPressed: () => onCategoryPressed(categories[index]),
            ),
          ),
          if (index != categories.length - 1)
            const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onPressed});

  final _DiscoverCategoryUiModel category;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: AppCard(
        padding: EdgeInsets.zero,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        child: InkWell(
          key: ValueKey('category-${category.label}'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.onPrimary,
                  child: Icon(category.icon),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  category.label,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NearbyHeader extends StatelessWidget {
  const _NearbyHeader({required this.onSeeAllPressed});

  final VoidCallback onSeeAllPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Yakınındaki Mekanlar',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        TextButton(
          key: const ValueKey('see-all-places'),
          onPressed: onSeeAllPressed,
          child: const Text('Tümünü Gör'),
        ),
      ],
    );
  }
}

class _NearbyPlaceCard extends StatelessWidget {
  const _NearbyPlaceCard({required this.place, required this.onPressed});

  final _NearbyPlaceUiModel place;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: AppCard(
        padding: EdgeInsets.zero,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        child: InkWell(
          key: ValueKey('place-${place.name}'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _PlaceVisualArea(imageUrl: place.imageUrl),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          place.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            place.transportIcon,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              place.distance,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.primaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceVisualArea extends StatelessWidget {
  const _PlaceVisualArea({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(AppRadius.lg),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.primaryContainer.withValues(alpha: 0.3),
            child: const Center(
              child: Icon(Icons.broken_image, color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}
