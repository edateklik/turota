import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({required this.value, this.height = 8, super.key})
    : assert(value >= 0 && value <= 1);

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: LinearProgressIndicator(
        minHeight: height,
        value: value,
        backgroundColor: AppColors.progressTrack,
        color: AppColors.primary,
      ),
    );
  }
}
