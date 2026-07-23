import 'package:flutter/material.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/app_button.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  static const _collections = [
    _SavedCollectionUiModel(
      'Hafta Sonu Kahvaltısı',
      _CollectionVisual.breakfast,
    ),
    _SavedCollectionUiModel('Sanat Rotası', _CollectionVisual.art),
    _SavedCollectionUiModel('Gizli Cevherler', _CollectionVisual.garden),
    _SavedCollectionUiModel('Yeni Liste', _CollectionVisual.newList),
  ];

  static const _places = [
    _SavedPlaceUiModel(
      id: 'minoa',
      name: 'Minoa Books & Coffee',
      category: 'Kitabevi & Kafe',
      match: '%94 Eşleşme',
      location: '1.2 km • 8 dk yürüyüş',
      visual: _SavedPlaceVisual.minoa,
    ),
    _SavedPlaceUiModel(
      id: 'hearth',
      name: 'The Hearth Bakery',
      category: 'Artisanal Fırın',
      match: '%88 Eşleşme',
      location: '0.4 km • 3 dk yürüyüş',
      visual: _SavedPlaceVisual.hearth,
    ),
    _SavedPlaceUiModel(
      id: 'vantage',
      name: 'Vantage Point Bar',
      category: 'Kokteyller & Manzara',
      match: '%91 Eşleşme',
      location: '2.8 km • 12 dk sürüş',
      visual: _SavedPlaceVisual.vantage,
    ),
  ];

  final Set<String> _bookmarkedPlaceIds = {
    for (final place in _places) place.id,
  };
  int _activeTab = 0;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleBookmark(_SavedPlaceUiModel place) {
    final wasBookmarked = _bookmarkedPlaceIds.contains(place.id);
    setState(() {
      if (wasBookmarked) {
        _bookmarkedPlaceIds.remove(place.id);
      } else {
        _bookmarkedPlaceIds.add(place.id);
      }
    });
    _showMessage(
      wasBookmarked
          ? '${place.name} kaydedilenlerden çıkarıldı.'
          : '${place.name} kaydedilenlere eklendi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _SavedHeader(
            onSearchPressed: () =>
                _showMessage('Kayıtlı içeriklerde arama yakında eklenecek.'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _SavedTabSelector(
              activeIndex: _activeTab,
              onTabSelected: (index) => setState(() => _activeTab = index),
              onAddPressed: () =>
                  _showMessage('Yeni koleksiyon oluşturma yakında eklenecek.'),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _activeTab == 0
                  ? _PlacesTab(
                      key: const ValueKey('saved-places-tab'),
                      collections: _collections,
                      places: _places,
                      bookmarkedPlaceIds: _bookmarkedPlaceIds,
                      onCollectionPressed: (collection) => _showMessage(
                        collection.visual == _CollectionVisual.newList
                            ? 'Yeni koleksiyon oluşturma yakında eklenecek.'
                            : '${collection.name} koleksiyonu yakında açılacak.',
                      ),
                      onSeeAllPressed: () => _showMessage(
                        'Tüm koleksiyonlar ekranı yakında eklenecek.',
                      ),
                      onPlacePressed: (place) => _showMessage(
                        '${place.name} detay ekranı yakında eklenecek.',
                      ),
                      onBookmarkPressed: _toggleBookmark,
                    )
                  : _PlansEmptyState(
                      key: const ValueKey('saved-plans-tab'),
                      onDiscoverPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRouter.home),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CollectionVisual { breakfast, art, garden, newList }

class _SavedCollectionUiModel {
  const _SavedCollectionUiModel(this.name, this.visual);

  final String name;
  final _CollectionVisual visual;
}

enum _SavedPlaceVisual { minoa, hearth, vantage }

class _SavedPlaceUiModel {
  const _SavedPlaceUiModel({
    required this.id,
    required this.name,
    required this.category,
    required this.match,
    required this.location,
    required this.visual,
  });

  final String id;
  final String name;
  final String category;
  final String match;
  final String location;
  final _SavedPlaceVisual visual;
}

class _SavedHeader extends StatelessWidget {
  const _SavedHeader({required this.onSearchPressed});

  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'Kaydedilenler',
                key: const ValueKey('saved-page-title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  key: const ValueKey('saved-search'),
                  onPressed: onSearchPressed,
                  tooltip: 'Kayıtlı içeriklerde ara',
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedTabSelector extends StatelessWidget {
  const _SavedTabSelector({
    required this.activeIndex,
    required this.onTabSelected,
    required this.onAddPressed,
  });

  final int activeIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SavedTab(
            label: 'Mekanlar',
            isActive: activeIndex == 0,
            onPressed: () => onTabSelected(0),
          ),
        ),
        Expanded(
          child: _SavedTab(
            label: 'Planlar',
            isActive: activeIndex == 1,
            onPressed: () => onTabSelected(1),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton.filled(
          key: const ValueKey('saved-add-collection'),
          onPressed: onAddPressed,
          tooltip: 'Yeni koleksiyon ekle',
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('saved-tab-$label'),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? AppColors.primary : AppColors.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AnimatedContainer(
              key: isActive ? ValueKey('saved-active-tab-$label') : null,
              duration: const Duration(milliseconds: 220),
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacesTab extends StatelessWidget {
  const _PlacesTab({
    required this.collections,
    required this.places,
    required this.bookmarkedPlaceIds,
    required this.onCollectionPressed,
    required this.onSeeAllPressed,
    required this.onPlacePressed,
    required this.onBookmarkPressed,
    super.key,
  });

  final List<_SavedCollectionUiModel> collections;
  final List<_SavedPlaceUiModel> places;
  final Set<String> bookmarkedPlaceIds;
  final ValueChanged<_SavedCollectionUiModel> onCollectionPressed;
  final VoidCallback onSeeAllPressed;
  final ValueChanged<_SavedPlaceUiModel> onPlacePressed;
  final ValueChanged<_SavedPlaceUiModel> onBookmarkPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 380
            ? AppSpacing.md
            : AppSpacing.lg;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.lg,
            horizontalPadding,
            AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CollectionsHeader(onSeeAllPressed: onSeeAllPressed),
                  const SizedBox(height: AppSpacing.md),
                  _CollectionsStrip(
                    collections: collections,
                    onCollectionPressed: onCollectionPressed,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  for (final place in places) ...[
                    _SavedPlaceCard(
                      place: place,
                      isBookmarked: bookmarkedPlaceIds.contains(place.id),
                      onPressed: () => onPlacePressed(place),
                      onBookmarkPressed: () => onBookmarkPressed(place),
                    ),
                    if (place != places.last)
                      const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CollectionsHeader extends StatelessWidget {
  const _CollectionsHeader({required this.onSeeAllPressed});

  final VoidCallback onSeeAllPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Koleksiyonlarım',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        TextButton(
          key: const ValueKey('saved-see-all-collections'),
          onPressed: onSeeAllPressed,
          child: const Text('Tümünü gör'),
        ),
      ],
    );
  }
}

class _CollectionsStrip extends StatelessWidget {
  const _CollectionsStrip({
    required this.collections,
    required this.onCollectionPressed,
  });

  final List<_SavedCollectionUiModel> collections;
  final ValueChanged<_SavedCollectionUiModel> onCollectionPressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('saved-collections-scroll'),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < collections.length; index++) ...[
            _CollectionCard(
              collection: collections[index],
              onPressed: () => onCollectionPressed(collections[index]),
            ),
            if (index != collections.length - 1)
              const SizedBox(width: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection, required this.onPressed});

  final _SavedCollectionUiModel collection;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isNew = collection.visual == _CollectionVisual.newList;
    return SizedBox(
      key: ValueKey('collection-${collection.name}'),
      width: 160,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          children: [
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                color: isNew ? AppColors.surfaceLow : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: isNew ? AppColors.primary : AppColors.outlineVariant,
                ),
                boxShadow: isNew
                    ? null
                    : const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _CollectionVisualWidget(type: collection.visual),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              collection.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionVisualWidget extends StatelessWidget {
  const _CollectionVisualWidget({required this.type});

  final _CollectionVisual type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      _CollectionVisual.breakfast => const _BreakfastVisual(),
      _CollectionVisual.art => const _ArtVisual(),
      _CollectionVisual.garden => const _GardenVisual(),
      _CollectionVisual.newList => const Center(
        child: Icon(Icons.add_rounded, size: 52, color: AppColors.primary),
      ),
    };
  }
}

class _BreakfastVisual extends StatelessWidget {
  const _BreakfastVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFE7C7),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 22,
            bottom: 26,
            child: Icon(
              Icons.coffee_rounded,
              size: 48,
              color: Color(0xFF8C5A3C),
            ),
          ),
          Positioned(
            right: 20,
            top: 28,
            child: Container(
              width: 58,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE8A55D),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtVisual extends StatelessWidget {
  const _ArtVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0ECE8),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFDC7A68),
              child: const Icon(Icons.circle, color: Color(0xFFF6D267)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              color: const Color(0xFF6F9FA5),
              child: const Icon(Icons.change_history, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenVisual extends StatelessWidget {
  const _GardenVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFDDF2DA), Color(0xFF5F8C68)],
        ),
      ),
      child: const Stack(
        children: [
          Positioned(
            left: 20,
            bottom: 18,
            child: Icon(Icons.park_rounded, size: 72, color: Color(0xFF315A3D)),
          ),
          Positioned(
            right: 24,
            top: 24,
            child: Icon(Icons.lightbulb, color: Color(0xFFFFE69A)),
          ),
        ],
      ),
    );
  }
}

class _SavedPlaceCard extends StatelessWidget {
  const _SavedPlaceCard({
    required this.place,
    required this.isBookmarked,
    required this.onPressed,
    required this.onBookmarkPressed,
  });

  final _SavedPlaceUiModel place;
  final bool isBookmarked;
  final VoidCallback onPressed;
  final VoidCallback onBookmarkPressed;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.xl,
      boxShadow: const [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 14,
          offset: Offset(0, 6),
        ),
      ],
      child: InkWell(
        key: ValueKey('saved-place-${place.id}'),
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _SavedPlaceVisualWidget(type: place.visual),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: IconButton.filledTonal(
                      key: ValueKey('bookmark-${place.id}'),
                      onPressed: onBookmarkPressed,
                      tooltip: isBookmarked
                          ? '${place.name} kaydını kaldır'
                          : '${place.name} kaydet',
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          place.match,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
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
                  Text(
                    place.category,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.near_me_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          place.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedPlaceVisualWidget extends StatelessWidget {
  const _SavedPlaceVisualWidget({required this.type});

  final _SavedPlaceVisual type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      _SavedPlaceVisual.minoa => const _MinoaVisual(),
      _SavedPlaceVisual.hearth => const _HearthVisual(),
      _SavedPlaceVisual.vantage => const _VantageVisual(),
    };
  }
}

class _MinoaVisual extends StatelessWidget {
  const _MinoaVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFB98762),
      child: Stack(
        children: [
          for (final top in [20.0, 58.0, 96.0])
            Positioned(
              left: 18,
              right: 18,
              top: top,
              child: Container(height: 8, color: const Color(0xFF5C3828)),
            ),
          const Center(
            child: Icon(Icons.local_cafe, size: 62, color: Color(0xFFFFE2B6)),
          ),
        ],
      ),
    );
  }
}

class _HearthVisual extends StatelessWidget {
  const _HearthVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFE2B8),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.bakery_dining, size: 58, color: Color(0xFFB36A38)),
          Icon(Icons.breakfast_dining, size: 52, color: Color(0xFFD58B50)),
        ],
      ),
    );
  }
}

class _VantageVisual extends StatelessWidget {
  const _VantageVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3A36F), Color(0xFF594C78)],
        ),
      ),
      child: const Stack(
        children: [
          Positioned(
            left: 24,
            bottom: 0,
            child: Icon(
              Icons.location_city,
              size: 100,
              color: Color(0xFF332C4D),
            ),
          ),
          Positioned(
            right: 30,
            top: 26,
            child: Icon(Icons.local_bar, size: 54, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _PlansEmptyState extends StatelessWidget {
  const _PlansEmptyState({required this.onDiscoverPressed, super.key});

  final VoidCallback onDiscoverPressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AppCard(
            borderRadius: AppRadius.xl,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.surfaceLow,
                  foregroundColor: AppColors.primary,
                  child: Icon(Icons.route_rounded, size: 46),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Henüz kayıtlı planın yok',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Beğendiğin rotaları kaydettiğinde burada görebilirsin.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  key: const ValueKey('saved-discover-action'),
                  label: 'Keşfetmeye Başla',
                  onPressed: onDiscoverPressed,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
