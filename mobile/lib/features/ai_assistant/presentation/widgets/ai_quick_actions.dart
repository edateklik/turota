import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';

class AiQuickAction {
  const AiQuickAction(this.label, this.icon);

  final String label;
  final IconData icon;
}

class AiQuickActions extends StatelessWidget {
  const AiQuickActions({
    required this.actions,
    required this.onSelected,
    super.key,
  });

  final List<AiQuickAction> actions;
  final ValueChanged<AiQuickAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        key: const ValueKey('ai-quick-actions'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final action = actions[index];
          return ActionChip(
            avatar: Icon(action.icon, size: 20, color: AppColors.primary),
            label: Text(action.label),
            onPressed: () => onSelected(action),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.savedOutlineVariant),
            tooltip: action.label,
          );
        },
      ),
    );
  }
}
