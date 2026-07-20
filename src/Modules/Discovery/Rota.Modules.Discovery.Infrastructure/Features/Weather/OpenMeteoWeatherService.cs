using System.Text.Json;
using System.Text.Json.Serialization;
using Rota.Modules.Discovery.Application.Features.Weather;
using System.Globalization;

namespace Rota.Modules.Discovery.Infrastructure.Features.Weather;

public class OpenMeteoWeatherService : IWeatherService
{
    private readonly HttpClient _httpClient;

    public OpenMeteoWeatherService(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<WeatherForecastDto> GetSevenDayForecastAsync(double latitude, double longitude, CancellationToken cancellationToken = default)
    {
        // Format latitude and longitude manually to ensure correct dot separator instead of comma depending on locale.
        var latStr = latitude.ToString(CultureInfo.InvariantCulture);
        var lonStr = longitude.ToString(CultureInfo.InvariantCulture);
        
        var url = $"https://api.open-meteo.com/v1/forecast?latitude={latStr}&longitude={lonStr}&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto";

        var response = await _httpClient.GetAsync(url, cancellationToken);
        response.EnsureSuccessStatusCode();

        var content = await response.Content.ReadAsStringAsync(cancellationToken);
        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var meteoData = JsonSerializer.Deserialize<OpenMeteoResponse>(content, options);

        if (meteoData?.Daily == null)
        {
            throw new Exception("Failed to parse OpenMeteo response or daily data is null.");
        }

        var dailyForecasts = new List<WeatherDayDto>();
        for (int i = 0; i < meteoData.Daily.Time.Count; i++)
        {
            dailyForecasts.Add(new WeatherDayDto
            {
                Date = DateTime.Parse(meteoData.Daily.Time[i]),
                MaxTemperature = meteoData.Daily.Temperature2mMax[i],
                MinTemperature = meteoData.Daily.Temperature2mMin[i],
                WeatherCode = meteoData.Daily.WeatherCode[i]
            });
        }

        return new WeatherForecastDto
        {
            Latitude = latitude,
            Longitude = longitude,
            DailyForecasts = dailyForecasts
        };
    }

    private class OpenMeteoResponse
    {
        public OpenMeteoDaily? Daily { get; set; }
    }

    private class OpenMeteoDaily
    {
        public List<string> Time { get; set; } = new();
        
        [JsonPropertyName("weather_code")]
        public List<int> WeatherCode { get; set; } = new();
        
        [JsonPropertyName("temperature_2m_max")]
        public List<double> Temperature2mMax { get; set; } = new();
        
        [JsonPropertyName("temperature_2m_min")]
        public List<double> Temperature2mMin { get; set; } = new();
    }
}
