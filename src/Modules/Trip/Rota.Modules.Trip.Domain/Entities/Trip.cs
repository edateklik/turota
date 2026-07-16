namespace Rota.Modules.Trip.Domain.Entities;

public enum TripStatus
{
    Planned = 1,
    Cancelled = 2,
    Completed = 3
}

public sealed class Trip
{
    private readonly List<TripStop> _stops = [];

    private Trip() { }

    public Trip(
        Guid id,
        Guid sourceRecommendationRunId,
        Guid userId,
        DateOnly tripDate,
        int availableMinutes,
        Guid neighborhoodId,
        string regionName,
        string overallExplanation,
        IEnumerable<TripStop> stops,
        DateTimeOffset createdAt)
    {
        if (id == Guid.Empty || sourceRecommendationRunId == Guid.Empty || userId == Guid.Empty || neighborhoodId == Guid.Empty)
            throw new ArgumentException("Trip kimlikleri boş olamaz.");
        if (availableMinutes is < 30 or > 720)
            throw new ArgumentOutOfRangeException(nameof(availableMinutes), "Kullanılabilir süre 30-720 dakika olmalıdır.");
        if (string.IsNullOrWhiteSpace(regionName) || string.IsNullOrWhiteSpace(overallExplanation))
            throw new ArgumentException("Bölge ve açıklama zorunludur.");

        var validatedStops = ValidateStops(stops, availableMinutes);
        Id = id;
        SourceRecommendationRunId = sourceRecommendationRunId;
        UserId = userId;
        TripDate = tripDate;
        AvailableMinutes = availableMinutes;
        NeighborhoodId = neighborhoodId;
        RegionName = regionName.Trim();
        OverallExplanation = overallExplanation.Trim();
        Status = TripStatus.Planned;
        CreatedAt = createdAt;
        UpdatedAt = createdAt;
        _stops.AddRange(validatedStops);
    }

    public Guid Id { get; private set; }
    public Guid SourceRecommendationRunId { get; private set; }
    public Guid UserId { get; private set; }
    public DateOnly TripDate { get; private set; }
    public int AvailableMinutes { get; private set; }
    public Guid NeighborhoodId { get; private set; }
    public string RegionName { get; private set; } = string.Empty;
    public string OverallExplanation { get; private set; } = string.Empty;
    public TripStatus Status { get; private set; }
    public DateTimeOffset CreatedAt { get; private set; }
    public DateTimeOffset UpdatedAt { get; private set; }
    public IReadOnlyCollection<TripStop> Stops => _stops;

    public void Cancel(DateTimeOffset now)
    {
        EnsurePlanned();
        Status = TripStatus.Cancelled;
        UpdatedAt = now;
    }

    public void Complete(DateTimeOffset now)
    {
        EnsurePlanned();
        Status = TripStatus.Completed;
        UpdatedAt = now;
    }

    private void EnsurePlanned()
    {
        if (Status != TripStatus.Planned)
            throw new InvalidOperationException("Yalnızca planlanmış bir rota güncellenebilir.");
    }

    private static IReadOnlyList<TripStop> ValidateStops(IEnumerable<TripStop> stops, int availableMinutes)
    {
        var result = stops.OrderBy(stop => stop.Sequence).ToList();
        if (result.Count is 0 or > 50) throw new ArgumentException("Timeline 1-50 durak içermelidir.");
        if (result.Sum(stop => stop.DurationMinutes) > availableMinutes)
            throw new ArgumentException("Timeline toplam süresi kullanılabilir süreyi aşıyor.");

        for (var index = 0; index < result.Count; index++)
        {
            var current = result[index];
            if (current.Sequence != index + 1) throw new ArgumentException("Timeline sıraları 1'den başlayarak kesintisiz olmalıdır.");
            var currentEnd = current.StartTime.Hour * 60 + current.StartTime.Minute + current.DurationMinutes;
            if (currentEnd > 24 * 60) throw new ArgumentException("Bir Timeline durağı ertesi güne taşamaz.");
            if (index == result.Count - 1) continue;
            var nextStart = result[index + 1].StartTime.Hour * 60 + result[index + 1].StartTime.Minute;
            if (currentEnd > nextStart) throw new ArgumentException("Timeline durakları birbiriyle çakışamaz.");
        }

        return result;
    }
}

public sealed class TripStop
{
    private TripStop() { }

    public TripStop(
        Guid id,
        int sequence,
        Guid placeId,
        string placeName,
        TimeOnly startTime,
        int durationMinutes,
        string explanation,
        double longitude,
        double latitude)
    {
        if (id == Guid.Empty || placeId == Guid.Empty) throw new ArgumentException("Durak kimlikleri boş olamaz.");
        if (sequence <= 0 || durationMinutes is <= 0 or > 720) throw new ArgumentException("Durak sırası veya süresi geçersiz.");
        if (string.IsNullOrWhiteSpace(placeName) || string.IsNullOrWhiteSpace(explanation)) throw new ArgumentException("Durak adı ve açıklaması zorunludur.");
        if (longitude is < -180 or > 180 || latitude is < -90 or > 90) throw new ArgumentException("Durak koordinatları geçersiz.");
        Id = id;
        Sequence = sequence;
        PlaceId = placeId;
        PlaceName = placeName.Trim();
        StartTime = startTime;
        DurationMinutes = durationMinutes;
        Explanation = explanation.Trim();
        Longitude = longitude;
        Latitude = latitude;
    }

    public Guid Id { get; private set; }
    public Guid TripId { get; private set; }
    public int Sequence { get; private set; }
    public Guid PlaceId { get; private set; }
    public string PlaceName { get; private set; } = string.Empty;
    public TimeOnly StartTime { get; private set; }
    public int DurationMinutes { get; private set; }
    public string Explanation { get; private set; } = string.Empty;
    public double Longitude { get; private set; }
    public double Latitude { get; private set; }
    public Trip Trip { get; private set; } = null!;
}
