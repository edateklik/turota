using System.Net.Mail;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Npgsql;
using Rota.Modules.Identity.Application.Contracts;
using Rota.Modules.Identity.Application.Errors;
using Rota.Modules.Identity.Domain.Entities;
using Rota.Modules.Identity.Infrastructure.Persistence;

namespace Rota.Modules.Identity.Infrastructure.Services;

public sealed class IdentityService(
    IdentityDbContext dbContext,
    IPasswordHasher<User> passwordHasher,
    IJwtTokenService jwtTokenService,
    TimeProvider timeProvider) : IIdentityService
{
    public async Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default)
    {
        var email = NormalizeEmail(request.Email);
        var normalizedEmail = email.ToUpperInvariant();
        ValidatePassword(request.Password);
        var firstName = Required(request.FirstName, 80, nameof(request.FirstName));
        var lastName = Required(request.LastName, 80, nameof(request.LastName));

        if (await dbContext.Users.AnyAsync(x => x.NormalizedEmail == normalizedEmail, cancellationToken))
            throw new EmailAlreadyExistsException();

        var user = new User(Guid.NewGuid(), email, normalizedEmail, firstName, lastName, timeProvider.GetUtcNow());
        user.SetPasswordHash(passwordHasher.HashPassword(user, request.Password));
        dbContext.Users.Add(user);
        dbContext.TasteProfiles.Add(new TasteProfile(user.Id, timeProvider.GetUtcNow()));

        try
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException exception) when (exception.InnerException is PostgresException { SqlState: PostgresErrorCodes.UniqueViolation })
        {
            throw new EmailAlreadyExistsException();
        }

        return jwtTokenService.CreateToken(user);
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrEmpty(request.Password) || request.Password.Length > 128)
            throw new InvalidCredentialsException();
        var normalizedEmail = NormalizeEmail(request.Email).ToUpperInvariant();
        var user = await dbContext.Users.SingleOrDefaultAsync(x => x.NormalizedEmail == normalizedEmail, cancellationToken)
            ?? throw new InvalidCredentialsException();
        if (!user.IsActive) throw new InactiveUserException();

        var verification = passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
        if (verification == PasswordVerificationResult.Failed) throw new InvalidCredentialsException();
        if (verification == PasswordVerificationResult.SuccessRehashNeeded)
        {
            user.SetPasswordHash(passwordHasher.HashPassword(user, request.Password));
            await dbContext.SaveChangesAsync(cancellationToken);
        }

        return jwtTokenService.CreateToken(user);
    }

    public async Task<UserResponse> GetUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.AsNoTracking().SingleOrDefaultAsync(x => x.Id == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Kullanıcı bulunamadı.");
        return new(user.Id, user.Email, user.FirstName, user.LastName, user.Role.ToString(), user.CreatedAt);
    }

    public async Task<TasteProfileResponse> GetTasteProfileAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var profile = await dbContext.TasteProfiles.AsNoTracking().SingleOrDefaultAsync(x => x.UserId == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Zevk profili bulunamadı.");
        return Map(profile);
    }

    public async Task<TasteProfileResponse> UpdateTasteProfileAsync(
        Guid userId,
        UpdateTasteProfileRequest request,
        CancellationToken cancellationToken = default)
    {
        var profile = await dbContext.TasteProfiles.SingleOrDefaultAsync(x => x.UserId == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Zevk profili bulunamadı.");
        var categoryIds = DistinctIds(request.PreferredCategoryIds, 50, nameof(request.PreferredCategoryIds));
        var tagIds = DistinctIds(request.PreferredTagIds, 50, nameof(request.PreferredTagIds));
        profile.Update(
            categoryIds,
            tagIds,
            request.DietaryPreference,
            request.BudgetLevel,
            request.TravelPace,
            request.DistancePreference,
            timeProvider.GetUtcNow());
        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(profile);
    }

    private static TasteProfileResponse Map(TasteProfile profile) => new(
        profile.UserId,
        profile.PreferredCategoryIds,
        profile.PreferredTagIds,
        profile.DietaryPreference,
        profile.BudgetLevel,
        profile.TravelPace,
        profile.DistancePreference,
        profile.UpdatedAt);

    private static Guid[] DistinctIds(IReadOnlyList<Guid> values, int maximum, string name)
    {
        var ids = values.Where(x => x != Guid.Empty).Distinct().ToArray();
        if (ids.Length > maximum) throw new ArgumentException($"En fazla {maximum} seçim yapılabilir.", name);
        return ids;
    }

    private static string NormalizeEmail(string value)
    {
        var email = Required(value, 254, nameof(value)).ToLowerInvariant();
        try
        {
            return new MailAddress(email).Address == email
                ? email
                : throw new ArgumentException("Geçerli bir e-posta adresi girilmelidir.", nameof(value));
        }
        catch (FormatException)
        {
            throw new ArgumentException("Geçerli bir e-posta adresi girilmelidir.", nameof(value));
        }
    }

    private static void ValidatePassword(string? password)
    {
        if (string.IsNullOrEmpty(password) || password.Length is < 8 or > 128 ||
            !password.Any(char.IsUpper) ||
            !password.Any(char.IsLower) ||
            !password.Any(char.IsDigit) ||
            password.All(char.IsLetterOrDigit))
            throw new ArgumentException("Parola 8-128 karakter olmalı; büyük harf, küçük harf, rakam ve özel karakter içermelidir.", nameof(password));
    }

    private static string Required(string value, int maximum, string name)
    {
        var normalized = value?.Trim() ?? string.Empty;
        if (normalized.Length is 0 || normalized.Length > maximum)
            throw new ArgumentException($"Değer 1-{maximum} karakter aralığında olmalıdır.", name);
        return normalized;
    }
}
