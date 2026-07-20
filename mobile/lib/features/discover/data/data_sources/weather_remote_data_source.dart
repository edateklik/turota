import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../dto/weather_day_dto.dart';

class WeatherRemoteDataSource {
  final http.Client _client;
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator
  final String _baseUrl = Platform.isAndroid ? 'http://10.0.2.2:5121' : 'http://localhost:5121';

  WeatherRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<WeatherForecastDto> getWeather() async {
    final response = await _client.get(Uri.parse('$_baseUrl/api/discovery/weather'));

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body);
      return WeatherForecastDto.fromJson(jsonMap);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
