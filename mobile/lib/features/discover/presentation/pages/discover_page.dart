import 'package:flutter/material.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';
import 'package:turota_mobile/core/widgets/app_bottom_navigation.dart';
import 'package:turota_mobile/core/widgets/app_scaffold.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  // TODO: Replace the sample identity and date with authenticated user and
  // localized current-date data.
  static const _header = _DiscoverHeaderModel(
    userName: 'Şevval',
    dateLabel: '12 Ekim Cumartesi',
  );

  // TODO: Replace this sample forecast with weather API data.
  static const _weatherDays = [
    _WeatherDayUiModel('Bugün', '24°', Icons.wb_sunny_rounded, true),
    _WeatherDayUiModel('Paz', '22°', Icons.cloud_queue_rounded, false),
    _WeatherDayUiModel('Pzt', '19°', Icons.cloud_rounded, false),
    _WeatherDayUiModel('Sal', '17°', Icons.grain_rounded, false),
    _WeatherDayUiModel('Çar', '20°', Icons.cloud_queue_rounded, false),
  ];

  static const _categories = [
    _DiscoverCategoryUiModel('Gastronomi', Icons.restaurant_rounded),
    _DiscoverCategoryUiModel('Sanat ve Kültür', Icons.museum_rounded),
    _DiscoverCategoryUiModel(
      'Gece Hayatı ve Etkinlik',
      Icons.celebration_rounded,
    ),
  ];

  static const _places = [
    _NearbyPlaceUiModel(
      name: 'Balat',
      description:
          'Tarihi dokusu ve renkli evleriyle ünlü, fotoğraf çekmek için '
          'ideal bir semt.',
      distance: '2.4 km uzaklıkta',
      transportIcon: Icons.directions_walk_rounded,
      visual: _PlaceVisual.balat,
    ),
    _NearbyPlaceUiModel(
      name: 'Nişantaşı',
      description:
          "Lüks mağazalar, şık kafeler ve hareketli sokaklarıyla İstanbul'un "
          'moda merkezi.',
      distance: '4.1 km uzaklıkta',
      transportIcon: Icons.directions_car_rounded,
      visual: _PlaceVisual.nisantasi,
    ),
    _NearbyPlaceUiModel(
      name: 'Moda, Kadıköy',
      description:
          "Sahili, tarihi tramvayı ve üçüncü nesil kahvecileriyle Anadolu "
          "Yakası'nın gözdesi.",
      distance: '8.5 km uzaklıkta',
      transportIcon: Icons.directions_transit_rounded,
      visual: _PlaceVisual.moda,
    ),
  ];

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectTemporaryDestination(int index) {
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRouter.saved);
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.discoverBackground,
      padding: EdgeInsets.zero,
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: 0,
        onDestinationSelected: _selectTemporaryDestination,
      ),
      body: SingleChildScrollView(
        key: const ValueKey('discover-scroll-view'),
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DiscoverHeader(
              model: _header,
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
                  _WeatherStrip(days: _weatherDays),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionTitle('Mevcut Konumunuz'),
                  const SizedBox(height: AppSpacing.md),
                  _LocationPreviewCard(
                    onMapPressed: () =>
                        _showMessage('Tam harita ekranı yakında eklenecek.'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _SectionTitle('Kategoriye Göre Keşfet'),
                  const SizedBox(height: AppSpacing.md),
                  _CategoryGrid(
                    categories: _categories,
                    onCategoryPressed: (category) => _showMessage(
                      '${category.label} kategorisi yakında açılacak.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _NearbyHeader(
                    onSeeAllPressed: () =>
                        _showMessage('Tüm mekanlar ekranı yakında eklenecek.'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final place in _places) ...[
                    _NearbyPlaceCard(
                      place: place,
                      onPressed: () => _showMessage(
                        '${place.name} detay ekranı yakında eklenecek.',
                      ),
                    ),
                    if (place != _places.last)
                      const SizedBox(height: AppSpacing.md),
                  ],
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

enum _PlaceVisual { balat, nisantasi, moda }

class _NearbyPlaceUiModel {
  const _NearbyPlaceUiModel({
    required this.name,
    required this.description,
    required this.distance,
    required this.transportIcon,
    required this.visual,
  });

  final String name;
  final String description;
  final String distance;
  final IconData transportIcon;
  final _PlaceVisual visual;
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
        border: const Border(
          bottom: BorderSide(color: AppColors.discoverSecondary),
        ),
      ),
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
                    backgroundColor: AppColors.discoverPrimaryContainer,
                    foregroundColor: AppColors.onDiscoverPrimaryContainer,
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
          color: day.isActive ? AppColors.primary : AppColors.discoverSecondary,
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
      borderColor: AppColors.discoverSecondary,
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
              const Positioned.fill(child: CustomPaint(painter: _MapPainter())),
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

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(AppColors.illustrationBackground, BlendMode.src);
    final blockPaint = Paint()..color = AppColors.discoverPrimaryContainer;
    final roadPaint = Paint()
      ..color = AppColors.surface
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final routePaint = Paint()
      ..color = AppColors.discoverSecondary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(18, 18, size.width * 0.28, 48),
        const Radius.circular(10),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.66, 28, size.width * 0.24, 58),
        const Radius.circular(10),
      ),
      blockPaint,
    );
    canvas.drawLine(
      Offset(-10, size.height * 0.72),
      Offset(size.width + 15, size.height * 0.28),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.22, -10),
      Offset(size.width * 0.76, size.height + 10),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.82),
      Offset(size.width * 0.9, size.height * 0.34),
      routePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        borderColor: AppColors.discoverSecondary,
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
                  backgroundColor: AppColors.discoverPrimaryContainer,
                  foregroundColor: AppColors.onDiscoverPrimaryContainer,
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
        borderColor: AppColors.discoverSecondary,
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
              Expanded(flex: 2, child: _PlaceVisualArea(type: place.visual)),
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
  const _PlaceVisualArea({required this.type});

  final _PlaceVisual type;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(
        left: Radius.circular(AppRadius.lg),
      ),
      child: switch (type) {
        _PlaceVisual.balat => const _BalatVisual(),
        _PlaceVisual.nisantasi => const _NisantasiVisual(),
        _PlaceVisual.moda => const _ModaVisual(),
      },
    );
  }
}

class _BalatVisual extends StatelessWidget {
  const _BalatVisual();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFE7D6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: const [
          Expanded(child: ColoredBox(color: Color(0xFFE98A7A))),
          SizedBox(width: 3),
          Expanded(child: ColoredBox(color: Color(0xFFF2C14E))),
          SizedBox(width: 3),
          Expanded(child: ColoredBox(color: Color(0xFF66B2B2))),
        ],
      ),
    );
  }
}

class _NisantasiVisual extends StatelessWidget {
  const _NisantasiVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E1D9),
      alignment: Alignment.center,
      child: const Icon(
        Icons.storefront_rounded,
        size: 58,
        color: AppColors.primaryContainer,
      ),
    );
  }
}

class _ModaVisual extends StatelessWidget {
  const _ModaVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDFF6F8), Color(0xFF74C9D2)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.tram_rounded,
        size: 54,
        color: AppColors.primaryContainer,
      ),
    );
  }
}
