using System.ComponentModel.DataAnnotations;

namespace Rota.Modules.Discovery.Application.Admin;

public interface IAdminCrudService<TRead, in TCreate, in TUpdate>
{
    Task<IReadOnlyList<TRead>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<TRead?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<TRead> CreateAsync(TCreate request, CancellationToken cancellationToken = default);
    Task<TRead?> UpdateAsync(Guid id, TUpdate request, CancellationToken cancellationToken = default);
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken = default);
}

public sealed record CityDto(Guid Id, string Name, string CountryCode);
public sealed record SaveCityRequest(
    [property: Required, StringLength(120, MinimumLength = 2)] string Name,
    [property: Required, StringLength(2, MinimumLength = 2)] string CountryCode);
public interface ICityAdminService : IAdminCrudService<CityDto, SaveCityRequest, SaveCityRequest>;

public sealed record NeighborhoodDto(Guid Id, Guid CityId, string Name, string BoundaryWkt);
public sealed record SaveNeighborhoodRequest(
    [property: Required] Guid CityId,
    [property: Required, StringLength(160, MinimumLength = 2)] string Name,
    [property: Required, StringLength(100_000, MinimumLength = 20)] string BoundaryWkt);
public interface INeighborhoodAdminService : IAdminCrudService<NeighborhoodDto, SaveNeighborhoodRequest, SaveNeighborhoodRequest>;

public sealed record PlaceDto(
    Guid Id,
    Guid NeighborhoodId,
    Guid CategoryId,
    string Name,
    string Address,
    double Longitude,
    double Latitude,
    IReadOnlyList<Guid> TagIds);
public sealed record SavePlaceRequest(
    [property: Required] 
    Guid NeighborhoodId,
    [property: Required]
    Guid CategoryId,
    [property: Required, StringLength(180, MinimumLength = 2)]
    string Name,
    [property: Required, StringLength(300, MinimumLength = 2)]
    string Address,
    [property: Range(-180, 180)]
    double Longitude,
    [property: Range(-90, 90)]
    double Latitude,
    IReadOnlyList<Guid>? TagIds);
public interface IPlaceAdminService : IAdminCrudService<PlaceDto, SavePlaceRequest, SavePlaceRequest>;

public sealed record CategoryDto(Guid Id, string Name, string Slug);
public sealed record SaveCategoryRequest(
    [property: Required, StringLength(100, MinimumLength = 2)] string Name,
    [property: Required, RegularExpression("^[a-z0-9]+(?:-[a-z0-9]+)*$")]
    string Slug);
public interface ICategoryAdminService : IAdminCrudService<CategoryDto, SaveCategoryRequest, SaveCategoryRequest>;

public sealed record TagDto(Guid Id, string Name, string Slug);
public sealed record SaveTagRequest(
    [property: Required, StringLength(100, MinimumLength = 2)] string Name,
    [property: Required, RegularExpression("^[a-z0-9]+(?:-[a-z0-9]+)*$")]
    string Slug);
public interface ITagAdminService : IAdminCrudService<TagDto, SaveTagRequest, SaveTagRequest>;
