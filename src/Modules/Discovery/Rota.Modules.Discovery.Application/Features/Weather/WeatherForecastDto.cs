namespace Rota.Modules.Discovery.Application.Features.Weather;

public class WeatherDayDto
{
    public required DateTime Date { get; init; }
    public required double MaxTemperature { get; init; }
    public required double MinTemperature { get; init; }
    public required int WeatherCode { get; init; }
}

public class WeatherForecastDto
{
    public required double Latitude { get; init; }
    public required double Longitude { get; init; }
    public required IReadOnlyList<WeatherDayDto> DailyForecasts { get; init; }
}
