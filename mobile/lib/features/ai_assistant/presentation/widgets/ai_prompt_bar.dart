import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';

class AiPromptBar extends StatelessWidget {
  const AiPromptBar({
    required this.controller,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: AppColors.shadow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.savedAccentLight,
              foregroundColor: AppColors.primary,
              child: Icon(Icons.auto_awesome_rounded),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                key: const ValueKey('ai-prompt-field'),
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                  hintText: 'Rotanı düzenlemek için bir şey yaz...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: const BorderSide(
                      color: AppColors.savedOutlineVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              key: const ValueKey('ai-prompt-send'),
              onPressed: onSubmitted,
              tooltip: 'İsteği gönder',
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
