using Microsoft.EntityFrameworkCore;
using Rota.Modules.Discovery.Application.Features;
using Rota.Modules.Discovery.Domain.Entities;
using Rota.Modules.Discovery.Infrastructure.Persistence;

namespace Rota.Modules.Discovery.Infrastructure.Features;

public sealed class PlaceFeatureVectorService(DiscoveryDbContext dbContext) : IPlaceFeatureVectorService
{
    private const int CurrentVersion = 1;

    public async Task<PlaceFeatureVectorResult?> GetAsync(Guid placeId, CancellationToken cancellationToken = default)
    {
        var vector = await dbContext.PlaceFeatureVectors.AsNoTracking()
            .SingleOrDefaultAsync(x => x.PlaceId == placeId, cancellationToken);
        return vector is null ? null : Map(vector);
    }

    public async Task<FeatureVectorSchemaResult> GetSchemaAsync(CancellationToken cancellationToken = default)
    {
        var categories = await dbContext.Categories.AsNoTracking().OrderBy(x => x.Id)
            .Select(x => new { x.Id, x.Slug }).ToListAsync(cancellationToken);
        var tags = await dbContext.Tags.AsNoTracking().OrderBy(x => x.Id)
            .Select(x => new { x.Id, x.Slug }).ToListAsync(cancellationToken);
        var dimensions = categories.Select((item, index) => new FeatureDimension(index, "category", item.Id, item.Slug))
            .Concat(tags.Select((item, index) => new FeatureDimension(categories.Count + index, "tag", item.Id, item.Slug)))
            .ToList();
        return new(CurrentVersion, dimensions);
    }

    public async Task<PlaceFeatureVectorResult> RebuildAsync(Guid placeId, CancellationToken cancellationToken = default)
    {
        var place = await dbContext.Places.Include(x => x.Tags)
            .SingleOrDefaultAsync(x => x.Id == placeId, cancellationToken)
            ?? throw new KeyNotFoundException("Mekan bulunamadı.");
        var dimensions = await LoadDimensions(cancellationToken);
        var values = Build(place, dimensions.CategoryIds, dimensions.TagIds);
        var vector = await dbContext.PlaceFeatureVectors.SingleOrDefaultAsync(x => x.PlaceId == placeId, cancellationToken);
        var now = DateTimeOffset.UtcNow;
        if (vector is null)
        {
            vector = new PlaceFeatureVector(placeId, CurrentVersion, values, now);
            dbContext.PlaceFeatureVectors.Add(vector);
        }
        else
        {
            vector.Replace(CurrentVersion, values, now);
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(vector);
    }

    public async Task<FeatureVectorBuildReport> RebuildAllAsync(CancellationToken cancellationToken = default)
    {
        var dimensions = await LoadDimensions(cancellationToken);
        var places = await dbContext.Places.Include(x => x.Tags).ToListAsync(cancellationToken);
        var existing = await dbContext.PlaceFeatureVectors.ToDictionaryAsync(x => x.PlaceId, cancellationToken);
        var now = DateTimeOffset.UtcNow;

        foreach (var place in places)
        {
            var values = Build(place, dimensions.CategoryIds, dimensions.TagIds);
            if (existing.TryGetValue(place.Id, out var vector))
                vector.Replace(CurrentVersion, values, now);
            else
                dbContext.PlaceFeatureVectors.Add(new PlaceFeatureVector(place.Id, CurrentVersion, values, now));
        }

        await dbContext.SaveChangesAsync(cancellationToken);
        return new(places.Count, dimensions.CategoryIds.Length + dimensions.TagIds.Length, CurrentVersion);
    }

    private async Task<(Guid[] CategoryIds, Guid[] TagIds)> LoadDimensions(CancellationToken cancellationToken)
    {
        var categoryIds = await dbContext.Categories.AsNoTracking().OrderBy(x => x.Id)
            .Select(x => x.Id).ToArrayAsync(cancellationToken);
        var tagIds = await dbContext.Tags.AsNoTracking().OrderBy(x => x.Id)
            .Select(x => x.Id).ToArrayAsync(cancellationToken);
        return (categoryIds, tagIds);
    }

    private static float[] Build(Place place, Guid[] categoryIds, Guid[] tagIds)
    {
        var values = new float[categoryIds.Length + tagIds.Length];
        var categoryIndex = Array.IndexOf(categoryIds, place.CategoryId);
        if (categoryIndex >= 0) values[categoryIndex] = 1;
        var selectedTags = place.Tags.Select(x => x.Id).ToHashSet();
        for (var index = 0; index < tagIds.Length; index++)
            if (selectedTags.Contains(tagIds[index])) values[categoryIds.Length + index] = 1;

        var magnitude = MathF.Sqrt(values.Sum(x => x * x));
        if (magnitude > 0)
            for (var index = 0; index < values.Length; index++) values[index] /= magnitude;
        return values;
    }

    private static PlaceFeatureVectorResult Map(PlaceFeatureVector vector) =>
        new(vector.PlaceId, vector.Version, vector.Values, vector.UpdatedAt);
}
