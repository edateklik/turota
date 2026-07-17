import 'package:flutter/material.dart';

enum AppButtonVariant { primary, outlined }

enum AppButtonIconPosition { leading, trailing }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.iconPosition = AppButtonIconPosition.leading,
    this.variant = AppButtonVariant.primary,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonIconPosition iconPosition;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? null : onPressed;
    final child = _ButtonContent(
      label: label,
      icon: icon,
      iconPosition: iconPosition,
      isLoading: isLoading,
      progressColor: variant == AppButtonVariant.primary
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.primary,
    );
    final button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: callback,
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: callback,
        child: child,
      ),
    };

    if (!isFullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.iconPosition,
    required this.isLoading,
    required this.progressColor,
  });

  final String label;
  final IconData? icon;
  final AppButtonIconPosition iconPosition;
  final bool isLoading;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: progressColor),
      );
    }

    if (icon == null) {
      return Text(label);
    }

    final iconWidget = Icon(icon, size: 20);
    final labelWidget = Flexible(
      child: Text(label, textAlign: TextAlign.center),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: iconPosition == AppButtonIconPosition.leading
          ? [iconWidget, const SizedBox(width: 8), labelWidget]
          : [labelWidget, const SizedBox(width: 8), iconWidget],
    );
  }
}
