import 'package:flutter/material.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/theme/app_typography.dart';
import 'package:turota_mobile/core/widgets/app_bottom_navigation.dart';
import 'package:turota_mobile/core/widgets/app_scaffold.dart';
import 'package:turota_mobile/features/ai_assistant/presentation/widgets/ai_prompt_bar.dart';
import 'package:turota_mobile/features/ai_assistant/presentation/widgets/ai_quick_actions.dart';
import 'package:turota_mobile/features/ai_assistant/presentation/widgets/timeline_segmented_control.dart';
import 'package:turota_mobile/features/ai_assistant/presentation/widgets/timeline_stop_card.dart';

class AiPlannerTimelinePage extends StatefulWidget {
  const AiPlannerTimelinePage({super.key});

  @override
  State<AiPlannerTimelinePage> createState() => _AiPlannerTimelinePageState();
}

class _AiPlannerTimelinePageState extends State<AiPlannerTimelinePage> {
  static const _stops = [
    _TimelineStopUiModel(
      time: '09:00',
      category: 'Gastronomi',
      title: 'Komorebi Coffee Roasters',
      duration: '45 dk',
      walkingTime: '0 dk (Başlangıç)',
      visual: TimelineStopVisual.coffee,
    ),
    _TimelineStopUiModel(
      time: '10:30',
      category: 'Kültür',
      title: 'The Linear Gallery',
      duration: '2 saat',
      walkingTime: '12 dk yürüme',
      visual: TimelineStopVisual.gallery,
    ),
    _TimelineStopUiModel(
      time: '13:15',
      category: 'Gastronomi',
      title: 'Flora Kitchen',
      duration: '1.5 saat',
      walkingTime: '8 dk yürüme',
      visual: TimelineStopVisual.flora,
    ),
  ];

  static const _quickActions = [
    AiQuickAction('Bu kafe ile değiştir', Icons.coffee_rounded),
    AiQuickAction('Rotayı kısalt', Icons.route_rounded),
    AiQuickAction('Müze ekle', Icons.museum_rounded),
    AiQuickAction('Daha uygun fiyatlı restoran bul', Icons.payments_outlined),
  ];

  final _promptController = TextEditingController();
  int _selectedView = 0;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectView(int index) {
    setState(() => _selectedView = index);
    if (index == 1) {
      _showMessage('Harita görünümü yakında eklenecek.');
    }
  }

  void _submitPrompt() {
    if (_promptController.text.trim().isEmpty) {
      return;
    }
    _promptController.clear();
    FocusScope.of(context).unfocus();
    _showMessage('İsteğiniz AI Asistan’a iletildi.');
  }

  void _handleBottomNavigation(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRouter.discover);
    } else if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRouter.saved);
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
        selectedIndex: 2,
        onDestinationSelected: _handleBottomNavigation,
      ),
      body: Column(
        children: [
          _TimelineAppBar(
            onBackPressed: () => Navigator.of(context).maybePop(),
            onMenuPressed: () =>
                _showMessage('Plan seçenekleri yakında eklenecek.'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: TimelineSegmentedControl(
                selectedIndex: _selectedView,
                onSelected: _selectView,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selectedView == 0
                  ? _TimelineView(
                      key: const ValueKey('timeline-view'),
                      stops: _stops,
                      onDetailsPressed: (stop) => _showMessage(
                        '${stop.title} detayları yakında eklenecek.',
                      ),
                      onLocationPressed: (stop) => _selectView(1),
                    )
                  : const _MapPlaceholder(key: ValueKey('ai-map-placeholder')),
            ),
          ),
          AiQuickActions(
            actions: _quickActions,
            onSelected: (action) =>
                _showMessage("'${action.label}' isteği AI Asistan’a iletildi."),
          ),
          AiPromptBar(
            controller: _promptController,
            onSubmitted: _submitPrompt,
          ),
        ],
      ),
    );
  }
}

class _TimelineAppBar extends StatelessWidget {
  const _TimelineAppBar({
    required this.onBackPressed,
    required this.onMenuPressed,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            IconButton(
              key: const ValueKey('ai-timeline-back'),
              onPressed: onBackPressed,
              tooltip: 'Geri dön',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const Expanded(
              child: Text(
                AppConstants.brandName,
                textAlign: TextAlign.center,
                style: AppTypography.splashBrand,
              ),
            ),
            IconButton(
              key: const ValueKey('ai-timeline-menu'),
              onPressed: onMenuPressed,
              tooltip: 'Plan seçenekleri',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView({
    required this.stops,
    required this.onDetailsPressed,
    required this.onLocationPressed,
    super.key,
  });

  final List<_TimelineStopUiModel> stops;
  final ValueChanged<_TimelineStopUiModel> onDetailsPressed;
  final ValueChanged<_TimelineStopUiModel> onLocationPressed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('ai-timeline-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              for (var index = 0; index < stops.length; index++)
                _TimelineEntry(
                  stop: stops[index],
                  isLast: index == stops.length - 1,
                  onDetailsPressed: () => onDetailsPressed(stops[index]),
                  onLocationPressed: () => onLocationPressed(stops[index]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({
    required this.stop,
    required this.isLast,
    required this.onDetailsPressed,
    required this.onLocationPressed,
  });

  final _TimelineStopUiModel stop;
  final bool isLast;
  final VoidCallback onDetailsPressed;
  final VoidCallback onLocationPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!isLast)
          const Positioned(
            left: 13,
            top: 18,
            bottom: -18,
            child: ColoredBox(
              color: AppColors.primary,
              child: SizedBox(width: 2),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.savedBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.time,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TimelineStopCard(
                      key: ValueKey('timeline-stop-${stop.title}'),
                      category: stop.category,
                      title: stop.title,
                      duration: stop.duration,
                      walkingTime: stop.walkingTime,
                      visual: stop.visual,
                      onDetailsPressed: onDetailsPressed,
                      onLocationPressed: onLocationPressed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.savedAccentLight,
              foregroundColor: AppColors.primary,
              child: Icon(Icons.map_outlined, size: 48),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Harita görünümü yakında eklenecek.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStopUiModel {
  const _TimelineStopUiModel({
    required this.time,
    required this.category,
    required this.title,
    required this.duration,
    required this.walkingTime,
    required this.visual,
  });

  final String time;
  final String category;
  final String title;
  final String duration;
  final String walkingTime;
  final TimelineStopVisual visual;
}
