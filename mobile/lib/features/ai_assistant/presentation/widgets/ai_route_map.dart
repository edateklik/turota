import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';

class AiRouteMap extends StatelessWidget {
  const AiRouteMap({
    required this.onMapPressed,
    required this.onLocationPressed,
    required this.onFitRoutePressed,
    super.key,
  });

  final VoidCallback onMapPressed;
  final VoidCallback onLocationPressed;
  final VoidCallback onFitRoutePressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Karaköy rotası harita önizlemesi',
      button: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: const ValueKey('ai-route-map'),
          onTap: onMapPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FBF7), Color(0xFFE9F5F4)],
              ),
              border: Border.all(color: AppColors.savedOutlineVariant),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _MapPainter()),
                ),
                const Positioned(
                  left: 18,
                  top: 26,
                  child: RoutePin(
                    number: 1,
                    label: 'Komorebi Coffee',
                    isActive: true,
                  ),
                ),
                const Positioned(
                  left: 48,
                  top: 132,
                  child: RoutePin(number: 2, label: 'The Linear Gallery'),
                ),
                const Positioned(
                  right: 42,
                  bottom: 34,
                  child: RoutePin(number: 3, label: 'Flora Kitchen'),
                ),
                const Positioned(
                  right: 94,
                  top: 112,
                  child: _UserLocationDot(),
                ),
                Positioned(
                  right: AppSpacing.sm,
                  top: AppSpacing.sm,
                  child: Column(
                    children: [
                      _MapControl(
                        key: const ValueKey('map-my-location'),
                        icon: Icons.my_location_rounded,
                        tooltip: 'Konumum',
                        onPressed: onLocationPressed,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _MapControl(
                        key: const ValueKey('map-fit-route'),
                        icon: Icons.zoom_out_map_rounded,
                        tooltip: 'Rotayı sığdır',
                        onPressed: onFitRoutePressed,
                      ),
                    ],
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

class RoutePin extends StatelessWidget {
  const RoutePin({
    required this.number,
    required this.label,
    this.isActive = false,
    super.key,
  });

  final int number;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$number. durak: $label${isActive ? ', aktif' : ''}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: ValueKey('route-pin-$number'),
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isActive ? AppColors.onPrimary : AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              constraints: const BoxConstraints(maxWidth: 132),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 8),
                ],
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapControl extends StatelessWidget {
  const _MapControl({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.shadow,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Icon(icon, color: AppColors.primaryContainer),
      ),
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tahmini kullanıcı konumu',
      child: Container(
        key: const ValueKey('user-location-dot'),
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0x334285F4),
          shape: BoxShape.circle,
        ),
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
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
    final gridPaint = Paint()
      ..color = const Color(0x12707975)
      ..strokeWidth = 1;
    for (double x = 20; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 18; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final blockPaint = Paint()..color = const Color(0xFFE3E8DF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .40, 22, size.width * .25, 62),
        const Radius.circular(12),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(16, size.height * .62, size.width * .25, 54),
        const Radius.circular(10),
      ),
      blockPaint,
    );

    final roadPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16;
    final road = Path()
      ..moveTo(-10, size.height * .43)
      ..cubicTo(
        size.width * .28,
        size.height * .26,
        size.width * .52,
        size.height * .72,
        size.width + 10,
        size.height * .48,
      );
    canvas.drawPath(road, roadPaint);

    final routePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5;
    final route = Path()
      ..moveTo(38, 56)
      ..cubicTo(
        size.width * .20,
        size.height * .28,
        size.width * .12,
        size.height * .54,
        68,
        154,
      )
      ..cubicTo(
        size.width * .35,
        size.height * .72,
        size.width * .62,
        size.height * .62,
        size.width - 61,
        size.height - 52,
      );
    canvas.drawPath(route, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
