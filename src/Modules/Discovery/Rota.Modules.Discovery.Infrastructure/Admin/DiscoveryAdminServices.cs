using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;
using NetTopologySuite.IO;
using Rota.Modules.Discovery.Application.Admin;
using Rota.Modules.Discovery.Application.Features;
using Rota.Modules.Discovery.Domain.Entities;
using Rota.Modules.Discovery.Infrastructure.Persistence;

namespace Rota.Modules.Discovery.Infrastructure.Admin;

public sealed class CityAdminService(DiscoveryDbContext dbContext) : ICityAdminService
{
    public async Task<IReadOnlyList<CityDto>> GetAllAsync(CancellationToken cancellationToken = default) =>
        await dbContext.Cities.AsNoTracking().OrderBy(x => x.Name)
            .Select(x => new CityDto(x.Id, x.Name, x.CountryCode)).ToListAsync(cancellationToken);

    public Task<CityDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default) =>
        dbContext.Cities.AsNoTracking().Where(x => x.Id == id)
            .Select(x => new CityDto(x.Id, x.Name, x.CountryCode)).SingleOrDefaultAsync(cancellationToken);

    public async Task<CityDto> CreateAsync(SaveCityRequest request, CancellationToken cancellationToken = default)
    {
        var city = new City(Guid.NewGuid(), Text.Required(request.Name, 120), CountryCode(request.CountryCode));
        dbContext.Cities.Add(city);
        await dbContext.SaveChangesAsync(cancellationToken);
        return new(city.Id, city.Name, city.CountryCode);
    }

    public async Task<CityDto?> UpdateAsync(Guid id, SaveCityRequest request, CancellationToken cancellationToken = default)
    {
        var city = await dbContext.Cities.FindAsync([id], cancellationToken);
        if (city is null) return null;
        city.Update(Text.Required(request.Name, 120), CountryCode(request.CountryCode));
        await dbContext.SaveChangesAsync(cancellationToken);
        return new(city.Id, city.Name, city.CountryCode);
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var city = await dbContext.Cities.FindAsync([id], cancellationToken);
        if (city is null) return false;
        dbContext.Cities.Remove(city);
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    private static string CountryCode(string value)
    {
        var code = Text.Required(value, 2).ToUpperInvariant();
        return code.Length == 2 ? code : throw new ArgumentException("Ülke kodu iki karakter olmalıdır.", nameof(value));
    }
}

public sealed class NeighborhoodAdminService(DiscoveryDbContext dbContext) : INeighborhoodAdminService
{
    public async Task<IReadOnlyList<NeighborhoodDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var items = await dbContext.Neighborhoods.AsNoTracking().OrderBy(x => x.Name).ToListAsync(cancellationToken);
        return items.Select(Map).ToList();
    }

    public async Task<NeighborhoodDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Neighborhoods.AsNoTracking().SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
        return item is null ? null : Map(item);
    }

    public async Task<NeighborhoodDto> CreateAsync(SaveNeighborhoodRequest request, CancellationToken cancellationToken = default)
    {
        await EnsureCityExists(request.CityId, cancellationToken);
        var item = new Neighborhood(Guid.NewGuid(), request.CityId, Text.Required(request.Name, 160), Geometry.ParseBoundary(request.BoundaryWkt));
        dbContext.Neighborhoods.Add(item);
        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(item);
    }

    public async Task<NeighborhoodDto?> UpdateAsync(Guid id, SaveNeighborhoodRequest request, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Neighborhoods.FindAsync([id], cancellationToken);
        if (item is null) return null;
        await EnsureCityExists(request.CityId, cancellationToken);
        var boundary = Geometry.ParseBoundary(request.BoundaryWkt);
        var allPlacesInside = await dbContext.Places.AsNoTracking()
            .Where(x => x.NeighborhoodId == id)
            .AllAsync(x => boundary.Covers(x.Location), cancellationToken);
        if (!allPlacesInside)
            throw new InvalidOperationException("Yeni sınır mevcut mekanlardan en az birini dışarıda bırakıyor.");

        item.Update(request.CityId, Text.Required(request.Name, 160), boundary);
        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(item);
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Neighborhoods.FindAsync([id], cancellationToken);
        if (item is null) return false;
        dbContext.Neighborhoods.Remove(item);
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    private async Task EnsureCityExists(Guid cityId, CancellationToken cancellationToken)
    {
        if (!await dbContext.Cities.AnyAsync(x => x.Id == cityId, cancellationToken))
            throw new ArgumentException("Şehir bulunamadı.", nameof(cityId));
    }

    private static NeighborhoodDto Map(Neighborhood item) => new(item.Id, item.CityId, item.Name, item.Boundary.AsText());
}

public sealed class PlaceAdminService(
    DiscoveryDbContext dbContext,
    IPlaceFeatureVectorService featureVectorService) : IPlaceAdminService
{
    public async Task<IReadOnlyList<PlaceDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var items = await dbContext.Places.AsNoTracking().Include(x => x.Tags).OrderBy(x => x.Name).ToListAsync(cancellationToken);
        return items.Select(Map).ToList();
    }

    public async Task<PlaceDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Places.AsNoTracking().Include(x => x.Tags)
            .SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
        return item is null ? null : Map(item);
    }

    public async Task<PlaceDto> CreateAsync(SavePlaceRequest request, CancellationToken cancellationToken = default)
    {
        var point = Geometry.Point(request.Longitude, request.Latitude);
        await ValidateRelationsAndLocation(request.NeighborhoodId, request.CategoryId, point, cancellationToken);
        var item = new Place(
            Guid.NewGuid(),
            request.NeighborhoodId,
            request.CategoryId,
            Text.Required(request.Name, 180),
            Text.Required(request.Address, 300),
            point);
        await ReplaceTags(item, request.TagIds, cancellationToken);
        dbContext.Places.Add(item);
        await dbContext.SaveChangesAsync(cancellationToken);
        await featureVectorService.RebuildAsync(item.Id, cancellationToken);
        return Map(item);
    }

    public async Task<PlaceDto?> UpdateAsync(Guid id, SavePlaceRequest request, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Places.Include(x => x.Tags).SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
        if (item is null) return null;
        var point = Geometry.Point(request.Longitude, request.Latitude);
        await ValidateRelationsAndLocation(request.NeighborhoodId, request.CategoryId, point, cancellationToken);
        item.Update(
            request.NeighborhoodId,
            request.CategoryId,
            Text.Required(request.Name, 180),
            Text.Required(request.Address, 300),
            point);
        await ReplaceTags(item, request.TagIds, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
        await featureVectorService.RebuildAsync(item.Id, cancellationToken);
        return Map(item);
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Places.FindAsync([id], cancellationToken);
        if (item is null) return false;
        dbContext.Places.Remove(item);
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }

    private async Task ValidateRelationsAndLocation(Guid neighborhoodId, Guid categoryId, Point point, CancellationToken cancellationToken)
    {
        var boundary = await dbContext.Neighborhoods.AsNoTracking().Where(x => x.Id == neighborhoodId)
            .Select(x => x.Boundary).SingleOrDefaultAsync(cancellationToken)
            ?? throw new ArgumentException("Mahalle bulunamadı.", nameof(neighborhoodId));
        if (!boundary.Covers(point))
            throw new ArgumentException("Mekan koordinatı seçilen mahalle sınırının dışında.", nameof(point));
        if (!await dbContext.Categories.AnyAsync(x => x.Id == categoryId, cancellationToken))
            throw new ArgumentException("Kategori bulunamadı.", nameof(categoryId));
    }

    private async Task ReplaceTags(Place item, IReadOnlyList<Guid>? tagIds, CancellationToken cancellationToken)
    {
        var ids = (tagIds ?? []).Distinct().ToArray();
        var tags = await dbContext.Tags.Where(x => ids.Contains(x.Id)).ToListAsync(cancellationToken);
        if (tags.Count != ids.Length)
            throw new ArgumentException("Etiketlerden en az biri bulunamadı.", nameof(tagIds));
        item.Tags.Clear();
        foreach (var tag in tags) item.Tags.Add(tag);
    }

    private static PlaceDto Map(Place item) => new(
        item.Id,
        item.NeighborhoodId,
        item.CategoryId,
        item.Name,
        item.Address,
        item.Location.X,
        item.Location.Y,
        item.Tags.Select(x => x.Id).Order().ToArray());
}

public sealed class CategoryAdminService(DiscoveryDbContext dbContext) : ICategoryAdminService
{
    public async Task<IReadOnlyList<CategoryDto>> GetAllAsync(CancellationToken cancellationToken = default) =>
        await dbContext.Categories.AsNoTracking().OrderBy(x => x.Name)
            .Select(x => new CategoryDto(x.Id, x.Name, x.Slug)).ToListAsync(cancellationToken);

    public Task<CategoryDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default) =>
        dbContext.Categories.AsNoTracking().Where(x => x.Id == id)
            .Select(x => new CategoryDto(x.Id, x.Name, x.Slug)).SingleOrDefaultAsync(cancellationToken);

    public async Task<CategoryDto> CreateAsync(SaveCategoryRequest request, CancellationToken cancellationToken = default)
    {
        var item = new Category(Guid.NewGuid(), Text.Required(request.Name, 100), Text.Slug(request.Slug));
        dbContext.Categories.Add(item);
        await dbContext.SaveChangesAsync(cancellationToken);
        return new(item.Id, item.Name, item.Slug);
    }

    public async Task<CategoryDto?> UpdateAsync(Guid id, SaveCategoryRequest request, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Categories.FindAsync([id], cancellationToken);
        if (item is null) return null;
        item.Update(Text.Required(request.Name, 100), Text.Slug(request.Slug));
        await dbContext.SaveChangesAsync(cancellationToken);
        return new(item.Id, item.Name, item.Slug);
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Categories.FindAsync([id], cancellationToken);
        if (item is null) return false;
        dbContext.Categories.Remove(item);
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }
}

public sealed class TagAdminService(DiscoveryDbContext dbContext) : ITagAdminService
{
    public async Task<IReadOnlyList<TagDto>> GetAllAsync(CancellationToken cancellationToken = default) =>
        await dbContext.Tags.AsNoTracking().OrderBy(x => x.Name)
            .Select(x => new TagDto(x.Id, x.Name, x.Slug)).ToListAsync(cancellationToken);

    public Task<TagDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default) =>
        dbContext.Tags.AsNoTracking().Where(x => x.Id == id)
            .Select(x => new TagDto(x.Id, x.Name, x.Slug)).SingleOrDefaultAsync(cancellationToken);

    public async Task<TagDto> CreateAsync(SaveTagRequest request, CancellationToken cancellationToken = default)
    {
        var item = new Tag(Guid.NewGuid(), Text.Required(request.Name, 100), Text.Slug(request.Slug));
        dbContext.Tags.Add(item);
        await dbContext.SaveChangesAsync(cancellationToken);
        return new(item.Id, item.Name, item.Slug);
    }

    public async Task<TagDto?> UpdateAsync(Guid id, SaveTagRequest request, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Tags.FindAsync([id], cancellationToken);
        if (item is null) return null;
        item.Update(Text.Required(request.Name, 100), Text.Slug(request.Slug));
        await dbContext.SaveChangesAsync(cancellationToken);
        return new(item.Id, item.Name, item.Slug);
    }

    public async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var item = await dbContext.Tags.FindAsync([id], cancellationToken);
        if (item is null) return false;
        dbContext.Tags.Remove(item);
        await dbContext.SaveChangesAsync(cancellationToken);
        return true;
    }
}

internal static class Text
{
    public static string Required(string value, int maxLength)
    {
        var normalized = value?.Trim() ?? string.Empty;
        if (normalized.Length is 0 || normalized.Length > maxLength)
            throw new ArgumentException($"Değer 1-{maxLength} karakter aralığında olmalıdır.", nameof(value));
        return normalized;
    }

    public static string Slug(string value)
    {
        var slug = Required(value, 100).ToLowerInvariant();
        return slug.All(x => char.IsLetterOrDigit(x) || x == '-')
            ? slug
            : throw new ArgumentException("Slug yalnızca harf, rakam ve tire içerebilir.", nameof(value));
    }
}

internal static class Geometry
{
    private const int Srid = 4326;
    private static readonly GeometryFactory Factory = new(new PrecisionModel(), Srid);

    public static Point Point(double longitude, double latitude)
    {
        if (longitude is < -180 or > 180 || latitude is < -90 or > 90)
            throw new ArgumentOutOfRangeException(nameof(longitude), "Geçersiz WGS84 koordinatı.");
        return Factory.CreatePoint(new Coordinate(longitude, latitude));
    }

    public static MultiPolygon ParseBoundary(string wkt)
    {
        var parsed = new WKTReader().Read(Text.Required(wkt, 100_000));
        var result = parsed switch
        {
            MultiPolygon multiPolygon => multiPolygon,
            Polygon polygon => Factory.CreateMultiPolygon([polygon]),
            _ => throw new ArgumentException("Sınır POLYGON veya MULTIPOLYGON olmalıdır.", nameof(wkt))
        };
        result.SRID = Srid;
        if (result.IsEmpty || !result.IsValid)
            throw new ArgumentException("Mahalle sınırı geçerli bir geometri olmalıdır.", nameof(wkt));
        return result;
    }
}
