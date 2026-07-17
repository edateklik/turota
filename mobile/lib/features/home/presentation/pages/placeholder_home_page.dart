import 'package:flutter/material.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/widgets/app_button.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';
import 'package:turota_mobile/core/widgets/app_scaffold.dart';

class PlaceholderHomePage extends StatelessWidget {
  const PlaceholderHomePage({super.key});

  static void _handleStartPressed() {}

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: AppConstants.appName,
      body: Center(
        child: AppCard(
          child: AppButton(
            label: 'Keşfetmeye Başla',
            onPressed: _handleStartPressed,
            isFullWidth: true,
          ),
        ),
      ),
    );
  }
}
