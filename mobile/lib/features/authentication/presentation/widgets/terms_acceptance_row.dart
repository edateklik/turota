import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';

class TermsAcceptanceRow extends StatelessWidget {
  const TermsAcceptanceRow({
    required this.value,
    required this.onChanged,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
    this.errorText,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = bodyStyle?.copyWith(
      color: AppColors.primaryContainer,
      fontWeight: FontWeight.w600,
    );

    return Semantics(
      label: 'Kullanım şartlarını ve gizlilik politikasını kabul et',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: (nextValue) => onChanged(nextValue ?? false),
              ),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                      onPressed: onTermsPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                      child: Text('Kullanım Şartları', style: linkStyle),
                    ),
                    Text(' ve ', style: bodyStyle),
                    TextButton(
                      onPressed: onPrivacyPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                      child: Text('Gizlilik Politikası', style: linkStyle),
                    ),
                    Text("'nı kabul ediyorum", style: bodyStyle),
                  ],
                ),
              ),
            ],
          ),
          if (errorText case final message?)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
    );
  }
}
