import 'package:flutter/material.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/login_page.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/register_page.dart';
import 'package:turota_mobile/features/discover/presentation/pages/discover_page.dart';
import 'package:turota_mobile/features/home/presentation/pages/main_shell_page.dart';
import 'package:turota_mobile/features/onboarding/location/presentation/pages/location_permission_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:turota_mobile/features/saved/presentation/pages/saved_page.dart';
import 'package:turota_mobile/features/splash/presentation/pages/splash_page.dart';

abstract final class AppRouter {
  static const String splash = '/';
  static const String locationPermission = '/onboarding/location';
  static const String login = '/authentication/login';
  static const String register = '/authentication/register';
  static const String discover = '/discover';
  static const String saved = '/saved';
  static const String home = '/home';
  static const String editProfile = '/profile/edit';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    return switch (settings.name) {
      splash => MaterialPageRoute<void>(
        builder: (_) => const SplashPage(),
        settings: settings,
      ),
      locationPermission => MaterialPageRoute<void>(
        builder: (_) => const LocationPermissionPage(),
        settings: settings,
      ),
      login => MaterialPageRoute<void>(
        builder: (_) => const LoginPage(),
        settings: settings,
      ),
      register => MaterialPageRoute<void>(
        builder: (_) => const RegisterPage(),
        settings: settings,
      ),
      discover => MaterialPageRoute<void>(
        builder: (_) => const DiscoverPage(),
        settings: settings,
      ),
      saved => MaterialPageRoute<void>(
        builder: (_) => const SavedPage(),
        settings: settings,
      ),
      home => MaterialPageRoute<void>(
        builder: (_) => const MainShellPage(),
        settings: settings,
      ),
      editProfile => MaterialPageRoute<void>(
        builder: (_) => const EditProfilePage(),
        settings: settings,
      ),
      _ => MaterialPageRoute<void>(
        builder: (_) => const SplashPage(),
        settings: settings,
      ),
    };
  }
}
