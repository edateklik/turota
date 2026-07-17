import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.backgroundColor = AppColors.background,
    super.key,
  });

  final Widget body;
  final String? title;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: title == null ? null : AppBar(title: Text(title!)),
      body: SafeArea(
        child: Padding(padding: padding, child: body),
      ),
    );
  }
}
