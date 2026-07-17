import 'dart:io';

abstract final class ApiConfig {
  static String get baseUrl {
    // If running in Android emulator, use 10.0.2.2 to access localhost.
    // Otherwise (iOS simulator, real device, web, desktop), use localhost.
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5121';
    }
    return 'http://localhost:5121';
  }
}
