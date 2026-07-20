class WeatherDayDto {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;

  WeatherDayDto({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
  });

  factory WeatherDayDto.fromJson(Map<String, dynamic> json) {
    return WeatherDayDto(
      date: DateTime.parse(json['date']),
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      minTemperature: (json['minTemperature'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
    );
  }
}

class WeatherForecastDto {
  final double latitude;
  final double longitude;
  final List<WeatherDayDto> dailyForecasts;

  WeatherForecastDto({
    required this.latitude,
    required this.longitude,
    required this.dailyForecasts,
  });

  factory WeatherForecastDto.fromJson(Map<String, dynamic> json) {
    return WeatherForecastDto(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      dailyForecasts: (json['dailyForecasts'] as List)
          .map((item) => WeatherDayDto.fromJson(item))
          .toList(),
    );
  }
}
