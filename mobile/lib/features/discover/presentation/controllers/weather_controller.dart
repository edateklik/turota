import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/dto/weather_day_dto.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

final weatherControllerProvider = FutureProvider.autoDispose<WeatherForecastDto>((ref) async {
  final repository = ref.watch(weatherRepositoryProvider);
  return await repository.getForecast();
});
