import 'package:flutter/material.dart';
import 'package:turota_mobile/features/ai_assistant/presentation/pages/ai_planner_map_page.dart';
import 'package:turota_mobile/features/ai_assistant/presentation/pages/ai_planner_timeline_page.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/login_page.dart';
import 'package:turota_mobile/features/authentication/presentation/pages/register_page.dart';
import 'package:turota_mobile/features/discover/presentation/pages/discover_page.dart';
import 'package:turota_mobile/features/home/presentation/pages/main_shell_page.dart';
import 'package:turota_mobile/features/onboarding/location/presentation/pages/location_permission_page.dart';
import 'package:turota_mobile/features/places/presentation/pages/place_detail_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/edit_taste_profile_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/notifications_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/privacy_security_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/location_settings_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/language_selection_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/help_center_page.dart';
import 'package:turota_mobile/features/profile/presentation/pages/about_page.dart';
import 'package:turota_mobile/features/saved/presentation/pages/saved_page.dart';
import 'package:turota_mobile/features/splash/presentation/pages/splash_page.dart';
import 'package:turota_mobile/features/discover/presentation/pages/map_page.dart';
import 'package:turota_mobile/features/discover/presentation/pages/city_lights_page.dart';
import 'package:turota_mobile/features/discover/presentation/pages/art_culture_page.dart';
import 'package:turota_mobile/features/discover/presentation/pages/gastronomy_page.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/presentation/pages/category_preference_page.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/presentation/pages/tag_preference_page.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/presentation/pages/dietary_preference_page.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/presentation/pages/budget_preference_page.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/presentation/pages/distance_preference_page.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/presentation/pages/taste_profile_result_page.dart';

// TODO: import other taste profile pages when created
abstract final class AppRouter {
  static const String splash = '/';
  static const String locationPermission = '/onboarding/location';
  static const String login = '/authentication/login';
  static const String register = '/authentication/register';
  static const String discover = '/discover';
  static const String saved = '/saved';
  static const String home = '/home';
  static const String editProfile = '/profile/edit';
  static const String editTasteProfile = '/profile/edit-taste';
  static const String privacySecurity = '/profile/privacy';
  static const String notifications = '/profile/notifications';
  static const String locationSettings = '/profile/locationSettings';
  static const String languageSelection = '/profile/language';
  static const String helpCenter = '/profile/helpCenter';
  static const String about = '/profile/about';
  static const String map = '/discover/map';
  static const String placeDetail = '/places/detail';
  static const String aiPlannerTimeline = '/ai-assistant/timeline';
  static const String aiPlannerMap = '/ai-assistant/map';
  static const String cityLights = '/discover/cityLights';
  static const String artCulture = '/discover/artCulture';
  static const String gastronomy = '/discover/gastronomy';
  static const String tasteProfileCategory = '/onboarding/taste-profile/category';
  static const String tasteProfileTag = '/onboarding/taste-profile/tag';
  static const String tasteProfileDietary = '/onboarding/taste-profile/dietary';
  static const String tasteProfileBudget = '/onboarding/taste-profile/budget';
  static const String tasteProfileDistance =
      '/onboarding/taste-profile/distance';
  static const String tasteProfileResult = '/onboarding/taste-profile/result';
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
      editTasteProfile => MaterialPageRoute<void>(
        builder: (_) => const EditTasteProfilePage(),
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
      placeDetail => MaterialPageRoute<void>(
        builder: (_) => const PlaceDetailPage(),
        settings: settings,
      ),
      aiPlannerTimeline => MaterialPageRoute<void>(
        builder: (_) => const AiPlannerTimelinePage(),
        settings: settings,
      ),
      aiPlannerMap => MaterialPageRoute<void>(
        builder: (_) => const AiPlannerMapPage(),
        settings: settings,
      ),
      cityLights => MaterialPageRoute<void>(
        builder: (_) => const CityLightsPage(),
        settings: settings,
      ),
      artCulture => MaterialPageRoute<void>(
        builder: (_) => const ArtCulturePage(),
        settings: settings,
      ),
      gastronomy => MaterialPageRoute<void>(
        builder: (_) => const GastronomyPage(),
        settings: settings,
      ),
      tasteProfileCategory => MaterialPageRoute<void>(
        builder: (_) => const CategoryPreferencePage(),
        settings: settings,
      ),
      tasteProfileTag => MaterialPageRoute<void>(
        builder: (_) => const TagPreferencePage(),
        settings: settings,
      ),
      tasteProfileDietary => MaterialPageRoute<void>(
        builder: (_) => const DietaryPreferencePage(),
        settings: settings,
      ),
      tasteProfileBudget => MaterialPageRoute<void>(
        builder: (_) => const BudgetPreferencePage(),
        settings: settings,
      ),
      tasteProfileDistance => MaterialPageRoute<void>(
        builder: (_) => const DistancePreferencePage(),
        settings: settings,
      ),
      tasteProfileResult => MaterialPageRoute<void>(
        builder: (_) => const TasteProfileResultPage(),
        settings: settings,
      ),
      // TODO: add other routes when pages are created
      _ => MaterialPageRoute<void>(
        builder: (_) => const SplashPage(),
        settings: settings,
      ),
    };
  }
}
