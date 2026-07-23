import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_theme.dart';
import 'package:turota_mobile/features/profile/presentation/controllers/profile_photo_controller.dart';

class TurotaApp extends ConsumerWidget {
  const TurotaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts persisted-photo loading and Android lost-data recovery at startup.
    ref.watch(profilePhotoControllerProvider);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
