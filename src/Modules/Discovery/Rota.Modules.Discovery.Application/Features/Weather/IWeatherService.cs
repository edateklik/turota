namespace Rota.Modules.Discovery.Application.Features.Weather;

public interface IWeatherService
{
    Task<WeatherForecastDto> GetSevenDayForecastAsync(double latitude, double longitude, CancellationToken cancellationToken = default);
}
