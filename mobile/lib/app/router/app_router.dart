import 'package:flutter/material.dart';
import 'package:turota_mobile/features/home/presentation/pages/placeholder_home_page.dart';
import 'package:turota_mobile/features/splash/presentation/pages/splash_page.dart';

abstract final class AppRouter {
  static const String splash = '/';
  static const String home = '/home';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      splash => MaterialPageRoute<void>(
        builder: (_) => const SplashPage(),
        settings: settings,
      ),
      home => MaterialPageRoute<void>(
        builder: (_) => const PlaceholderHomePage(),
        settings: settings,
      ),
      _ => MaterialPageRoute<void>(
        builder: (_) => const SplashPage(),
        settings: settings,
      ),
    };
  }
}
