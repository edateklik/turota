namespace Rota.Modules.Discovery.Application.Features;

public sealed record PlaceFeatureVectorResult(
    Guid PlaceId,
    int Version,
    IReadOnlyList<float> Values,
    DateTimeOffset UpdatedAt);

public sealed record FeatureVectorBuildReport(int UpdatedPlaceCount, int Dimension, int Version);
public sealed record FeatureDimension(int Index, string Kind, Guid SourceId, string Slug);
public sealed record FeatureVectorSchemaResult(int Version, IReadOnlyList<FeatureDimension> Dimensions);

public interface IPlaceFeatureVectorService
{
    Task<PlaceFeatureVectorResult?> GetAsync(Guid placeId, CancellationToken cancellationToken = default);
    Task<FeatureVectorSchemaResult> GetSchemaAsync(CancellationToken cancellationToken = default);
    Task<PlaceFeatureVectorResult> RebuildAsync(Guid placeId, CancellationToken cancellationToken = default);
    Task<FeatureVectorBuildReport> RebuildAllAsync(CancellationToken cancellationToken = default);
}
