using Rota.Modules.Trip.Domain.Entities;
using Xunit;

namespace Rota.Modules.Trip.UnitTests;

public sealed class TripTests
{
    [Fact]
    public void Constructor_OverlappingStops_RejectsTimeline()
    {
        var stops = new[]
        {
            Stop(1, new TimeOnly(9, 0), 90),
            Stop(2, new TimeOnly(10, 0), 60)
        };

        var exception = Assert.Throws<ArgumentException>(() => Create(stops));

        Assert.Contains("çakışamaz", exception.Message);
    }

    [Fact]
    public void Constructor_NonContiguousSequence_RejectsTimeline()
    {
        var stops = new[] { Stop(1, new TimeOnly(9, 0), 60), Stop(3, new TimeOnly(11, 0), 60) };

        var exception = Assert.Throws<ArgumentException>(() => Create(stops));

        Assert.Contains("kesintisiz", exception.Message);
    }

    [Fact]
    public void Cancel_PlannedTrip_CancelsAndPreventsSecondTransition()
    {
        var trip = Create([Stop(1, new TimeOnly(9, 0), 60)]);

        trip.Cancel(DateTimeOffset.UtcNow.AddMinutes(1));

        Assert.Equal(TripStatus.Cancelled, trip.Status);
        Assert.Throws<InvalidOperationException>(() => trip.Complete(DateTimeOffset.UtcNow.AddMinutes(2)));
    }

    private static Domain.Entities.Trip Create(IEnumerable<TripStop> stops) => new(
        Guid.NewGuid(),
        Guid.NewGuid(),
        Guid.NewGuid(),
        DateOnly.FromDateTime(DateTime.UtcNow),
        480,
        Guid.NewGuid(),
        "Caferağa",
        "Zevk profiline uygun rota.",
        stops,
        DateTimeOffset.UtcNow);

    private static TripStop Stop(int sequence, TimeOnly startTime, int duration) => new(
        Guid.NewGuid(),
        sequence,
        Guid.NewGuid(),
        $"Mekan {sequence}",
        startTime,
        duration,
        "Rota açıklaması",
        29.025,
        40.985);
}
