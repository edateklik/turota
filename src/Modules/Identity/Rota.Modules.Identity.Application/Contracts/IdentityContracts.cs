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
    DateTimeOffset CreatedAt);

/// <summary>Kullanıcının kişiselleştirme girdileri. Discovery kimlikleri modüller arası gevşek referanstır.</summary>
public sealed class UpdateTasteProfileRequest
{
    public IReadOnlyList<Guid> PreferredCategoryIds { get; init; } = [];
    public IReadOnlyList<Guid> PreferredTagIds { get; init; } = [];
    public IReadOnlyList<string> DietaryPreferences { get; init; } = [];
    public BudgetLevel BudgetLevel { get; init; } = BudgetLevel.Moderate;
    public TravelPace TravelPace { get; init; } = TravelPace.Balanced;
}

public sealed record TasteProfileResponse(
    Guid UserId,
    IReadOnlyList<Guid> PreferredCategoryIds,
    IReadOnlyList<Guid> PreferredTagIds,
    IReadOnlyList<string> DietaryPreferences,
    BudgetLevel BudgetLevel,
    TravelPace TravelPace,
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
