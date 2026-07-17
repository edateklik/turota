import 'package:flutter/material.dart';
import 'package:turota_mobile/features/home/presentation/pages/placeholder_home_page.dart';

abstract final class AppRouter {
  static const String home = '/';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      home => MaterialPageRoute<void>(
        builder: (_) => const PlaceholderHomePage(),
        settings: settings,
      ),
      _ => MaterialPageRoute<void>(
        builder: (_) => const PlaceholderHomePage(),
        settings: settings,
      ),
    };
  }
}
