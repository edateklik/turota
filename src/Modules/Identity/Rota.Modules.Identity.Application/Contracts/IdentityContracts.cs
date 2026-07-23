using System.ComponentModel.DataAnnotations;
using Rota.Modules.Identity.Domain.Entities;

namespace Rota.Modules.Identity.Application.Contracts;

/// <summary>Yeni kullanıcı hesabı oluşturma isteği.</summary>
public sealed class RegisterRequest
{
    /// <example>ada@example.com</example>
    [Required, EmailAddress, StringLength(254)]
    public required string Email { get; init; }

    /// <example>Rota123!</example>
    [Required, MinLength(8), MaxLength(128)]
    public required string Password { get; init; }

    /// <example>Ada</example>
    [Required, StringLength(80, MinimumLength = 1)]
    public required string FirstName { get; init; }

    /// <example>Yılmaz</example>
    [Required, StringLength(80, MinimumLength = 1)]
    public required string LastName { get; init; }
}

/// <summary>Kullanıcı giriş isteği.</summary>
public sealed class LoginRequest
{
    /// <example>ada@example.com</example>
    [Required, EmailAddress, StringLength(254)]
    public required string Email { get; init; }

    /// <example>Rota123!</example>
    [Required, MaxLength(128)]
    public required string Password { get; init; }
}

/// <summary>Frontend uygulamalarının saklayacağı JWT ve kullanıcı özeti.</summary>
public sealed record AuthResponse(string AccessToken, string TokenType, DateTimeOffset ExpiresAt, UserResponse User);

public sealed record UserResponse(
    Guid Id,
    string Email,
    string FirstName,
    string LastName,
    string Role,
    DateTimeOffset CreatedAt,
    string? ProfilePhotoUrl);

public sealed record ProfilePhotoResponse(string? ProfilePhotoUrl);

public interface IProfilePhotoService
{
    Task<ProfilePhotoResponse> UploadAsync(Guid userId, Stream content, string contentType, long length, CancellationToken cancellationToken = default);
    Task<ProfilePhotoResponse> DeleteAsync(Guid userId, CancellationToken cancellationToken = default);
}

public interface IProfilePhotoStorage
{
    Task<string> SaveAsync(Stream content, string extension, CancellationToken cancellationToken = default);
    Task DeleteAsync(string? publicUrl, CancellationToken cancellationToken = default);
}

/// <summary>
/// Kullanıcının kişiselleştirme girdileri.
/// Discovery module kimlik referansları (CategoryIds, TagIds) gevşek bağlıdır — ID'ler
/// <c>GET /api/admin/categories</c> ve <c>GET /api/admin/tags</c> endpoint'lerinden elde edilmelidir.
/// </summary>
/// <remarks>
/// Örnek istek:
/// <code>
/// {
///   "preferredCategoryIds": ["3fa85f64-5717-4562-b3fc-2c963f66afa6"],
///   "preferredTagIds":      ["6ba7b810-9dad-11d1-80b4-00c04fd430c8"],
///   "dietaryPreference":    "Vegetarian",
///   "budgetLevel":          "Moderate",
///   "travelPace":           "Balanced",
///   "distancePreference":   "Max3Km"
/// }
/// </code>
/// </remarks>
public sealed class UpdateTasteProfileRequest
{
    /// <summary>
    /// Tercih edilen mekan kategorileri.
    /// Geçerli değerler <c>GET /api/admin/categories</c> endpoint'inden alınır.
    /// </summary>
    /// <example>["3fa85f64-5717-4562-b3fc-2c963f66afa6"]</example>
    [MaxLength(50)]
    public IReadOnlyList<Guid> PreferredCategoryIds { get; init; } = [];

    /// <summary>
    /// Tercih edilen atmosfer ve mekan etiketleri.
    /// Geçerli değerler <c>GET /api/admin/tags</c> endpoint'inden alınır.
    /// </summary>
    /// <example>["6ba7b810-9dad-11d1-80b4-00c04fd430c8"]</example>
    [MaxLength(50)]
    public IReadOnlyList<Guid> PreferredTagIds { get; init; } = [];

    /// <summary>
    /// Beslenme tercihi.
    /// Geçerli değerler: <c>Everything</c>, <c>Vegetarian</c>, <c>Vegan</c>, <c>GlutenFree</c>, <c>NoPreference</c>.
    /// </summary>
    /// <example>Vegetarian</example>
    public DietaryPreference DietaryPreference { get; init; } = DietaryPreference.NoPreference;

    /// <summary>
    /// Bütçe tercihi.
    /// Geçerli değerler: <c>Economy</c>, <c>Moderate</c>, <c>Premium</c>, <c>Mixed</c>.
    /// </summary>
    /// <example>Moderate</example>
    public BudgetLevel BudgetLevel { get; init; } = BudgetLevel.Moderate;

    /// <summary>
    /// Gezi temposu.
    /// Geçerli değerler: <c>Relaxed</c>, <c>Balanced</c>, <c>Intensive</c>.
    /// </summary>
    /// <example>Balanced</example>
    public TravelPace TravelPace { get; init; } = TravelPace.Balanced;

    /// <summary>
    /// Mesafe tercihi.
    /// Geçerli değerler: <c>WalkingDistance</c>, <c>Max3Km</c>, <c>Max10Km</c>, <c>CityWide</c>, <c>Flexible</c>.
    /// </summary>
    /// <example>Max3Km</example>
    public DistancePreference DistancePreference { get; init; } = DistancePreference.Flexible;
}

/// <summary>Kullanıcının zevk profili yanıtı.</summary>
public sealed record TasteProfileResponse(
    Guid UserId,
    IReadOnlyList<Guid> PreferredCategoryIds,
    IReadOnlyList<Guid> PreferredTagIds,
    DietaryPreference DietaryPreference,
    BudgetLevel BudgetLevel,
    TravelPace TravelPace,
    DistancePreference DistancePreference,
    DateTimeOffset UpdatedAt);

public interface IIdentityService
{
    Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default);
    Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
    Task<UserResponse> GetUserAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<TasteProfileResponse> GetTasteProfileAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<TasteProfileResponse> UpdateTasteProfileAsync(Guid userId, UpdateTasteProfileRequest request, CancellationToken cancellationToken = default);
}

public interface IJwtTokenService
{
    AuthResponse CreateToken(User user);
}

public sealed record AdminUserResponse(
    Guid Id,
    string Email,
    string FirstName,
    string LastName,
    UserRole Role,
    bool IsActive,
    DateTimeOffset CreatedAt);

public sealed record AdminUserPageResponse(
    IReadOnlyList<AdminUserResponse> Items,
    int Page,
    int PageSize,
    int TotalCount);

public sealed class UpdateUserAccessRequest
{
    public UserRole Role { get; init; }
    public bool IsActive { get; init; } = true;
}

public interface IAdminIdentityService
{
    Task<AdminUserPageResponse> GetPageAsync(int page, int pageSize, CancellationToken cancellationToken = default);
    Task<AdminUserResponse> UpdateAccessAsync(
        Guid actingAdminId,
        Guid userId,
        UpdateUserAccessRequest request,
        CancellationToken cancellationToken = default);
}
