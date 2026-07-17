import 'package:flutter/material.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/theme/app_theme.dart';

class TurotaApp extends StatelessWidget {
  const TurotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRouter.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
