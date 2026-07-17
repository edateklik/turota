import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  final Widget body;
  final String? title;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: title == null ? null : AppBar(title: Text(title!)),
      body: SafeArea(
        child: Padding(padding: padding, child: body),
      ),
    );
  }
}
