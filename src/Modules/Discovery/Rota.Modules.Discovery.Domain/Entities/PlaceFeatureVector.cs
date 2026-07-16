namespace Rota.Modules.Discovery.Domain.Entities;

public sealed class PlaceFeatureVector
{
    private PlaceFeatureVector() { }

    public PlaceFeatureVector(Guid placeId, int version, float[] values, DateTimeOffset updatedAt)
    {
        PlaceId = placeId;
        Version = version;
        Values = values;
        UpdatedAt = updatedAt;
    }

    public Guid PlaceId { get; private set; }
    public int Version { get; private set; }
    public float[] Values { get; private set; } = [];
    public DateTimeOffset UpdatedAt { get; private set; }
    public Place Place { get; private set; } = null!;

    public void Replace(int version, float[] values, DateTimeOffset updatedAt)
    {
        Version = version;
        Values = values;
        UpdatedAt = updatedAt;
    }
}
