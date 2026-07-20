import 'package:flutter/material.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/login_page.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/register_page.dart';
import 'package:turota_mobile/features/home/presentation/pages/main_shell_page.dart';
import 'package:turota_mobile/features/onboarding/location/presentation/pages/location_permission_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/notifications_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/privacy_security_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/location_settings_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/language_selection_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/help_center_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/about_page.dart';
import 'package:turota_mobile/features/splash/presentation/pages/splash_page.dart';
import 'package:turota_mobile/features/discover/presentation/pages/map_page.dart';

abstract final class AppRouter {
  static const String splash = '/';
  static const String locationPermission = '/onboarding/location';
  static const String login = '/authentication/login';
  static const String register = '/authentication/register';
  static const String home = '/home';
  static const String editProfile = '/profile/edit';
  static const String privacySecurity = '/profile/privacy';
  static const String notifications = '/profile/notifications';
  static const String locationSettings = '/profile/locationSettings';
  static const String languageSelection = '/profile/language';
  static const String helpCenter = '/profile/helpCenter';
  static const String about = '/profile/about';
  static const String map = '/discover/map';

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
      home => MaterialPageRoute<void>(
        builder: (_) => const MainShellPage(),
        settings: settings,
      ),
      editProfile => MaterialPageRoute<void>(
        builder: (_) => const EditProfilePage(),
        settings: settings,
      ),
      privacySecurity => MaterialPageRoute<void>(
        builder: (_) => const PrivacySecurityPage(),
        settings: settings,
      ),
      notifications => MaterialPageRoute<void>(
        builder: (_) => const NotificationsPage(),
        settings: settings,
      ),
      locationSettings => MaterialPageRoute<void>(
        builder: (_) => const LocationSettingsPage(),
        settings: settings,
      ),
      languageSelection => MaterialPageRoute<void>(
        builder: (_) => const LanguageSelectionPage(),
        settings: settings,
      ),
      helpCenter => MaterialPageRoute<void>(
        builder: (_) => const HelpCenterPage(),
        settings: settings,
      ),
      about => MaterialPageRoute<void>(
        builder: (_) => const AboutPage(),
        settings: settings,
      ),
      map => MaterialPageRoute<void>(
        builder: (_) => const MapPage(),
        settings: settings,
      ),
      _ => MaterialPageRoute<void>(
        builder: (_) => const SplashPage(),
        settings: settings,
      ),
    };
  }
}
