import '../data_sources/weather_remote_data_source.dart';
import '../dto/weather_day_dto.dart';

class WeatherRepository {
  final WeatherRemoteDataSource _remoteDataSource;

  WeatherRepository({WeatherRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? WeatherRemoteDataSource();

  Future<WeatherForecastDto> getForecast() async {
    return await _remoteDataSource.getWeather();
  }
}
