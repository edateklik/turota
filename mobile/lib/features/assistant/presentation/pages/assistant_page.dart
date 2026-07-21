import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/features/assistant/domain/models/route_stop_ui_model.dart';
import 'package:turota_mobile/features/assistant/presentation/controllers/recommendation_controller.dart';
import 'package:turota_mobile/features/assistant/presentation/widgets/map_view_placeholder.dart';
import 'package:turota_mobile/features/assistant/presentation/widgets/timeline_view.dart';

class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  bool _isTimelineView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recommendationControllerProvider.notifier)
          .generateRecommendation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationControllerProvider);

    List<RouteStopUiModel> stops = [];
    if (state.response != null) {
      stops = state.response!.timeline.map((t) {
        return RouteStopUiModel(
          time: t.startTime.substring(0, 5), // Assumes "HH:MM:SS" format
          imageUrl: 'https://picsum.photos/seed/${t.placeId}/400/300',
          category: 'Öneri Nedeni',
          title: t.placeName,
          duration: '${t.durationMinutes} dk',
          walkingTime: t.explanation,
        );
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: const ColorFilter.mode(
              Colors.transparent,
              BlendMode.srcOver,
            ),
            // Note: Since backdrop filter is heavy, a simple surface color is used.
          ),
        ),
        title: const Text(
          'TUROTA',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F3F4), // surface-container-low
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentButton(
                      title: 'Zaman Çizelgesi',
                      icon: Icons.timeline,
                      isSelected: _isTimelineView,
                      onTap: () => setState(() => _isTimelineView = true),
                    ),
                  ),
                  Expanded(
                    child: _SegmentButton(
                      title: 'Harita',
                      icon: Icons.map,
                      isSelected: !_isTimelineView,
                      onTap: () => setState(() => _isTimelineView = false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Main Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: state.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Yapay zeka size özel rotanızı hazırlıyor...'),
                      ],
                    ),
                  )
                : state.error != null
                ? Center(
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : _isTimelineView
                ? TimelineView(
                    stops: stops,
                    onMapTap: () => setState(() => _isTimelineView = false),
                  )
                : const MapViewPlaceholder(),
          ),

          // AI Integration Area (Fixed Bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0, // Above bottom nav
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0.8),
                    AppColors.background.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick Action Chips
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        _ActionChip(
                          icon: Icons.coffee,
                          label: 'Bu kafe ile değiştir',
                          backgroundColor: const Color(
                            0xFFFFDCC2,
                          ), // tertiary-fixed
                          textColor: const Color(0xFF2E1500),
                        ),
                        const SizedBox(width: 8),
                        _ActionChip(
                          icon: Icons.route,
                          label: 'Rotayı kısalt',
                          backgroundColor: const Color(
                            0xFF90E4EC,
                          ), // secondary-container
                          textColor: const Color(0xFF002023),
                        ),
                        const SizedBox(width: 8),
                        _ActionChip(
                          icon: Icons.museum,
                          label: 'Müze ekle',
                          backgroundColor: const Color(
                            0xFFC7E6EB,
                          ), // surface-container-highest
                          textColor: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        _ActionChip(
                          icon: Icons.payments,
                          label: 'Uygun fiyatlı bul',
                          backgroundColor: const Color(0xFFC7E6EB),
                          textColor: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // AI Prompt Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Rotanı düzenlemek için yaz...',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF90E4EC)
              : Colors.transparent, // secondary-container
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF002023)
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF002023)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
