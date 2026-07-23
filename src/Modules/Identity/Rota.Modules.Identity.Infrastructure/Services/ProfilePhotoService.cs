using Microsoft.EntityFrameworkCore;
using Rota.Modules.Identity.Application.Contracts;
using Rota.Modules.Identity.Application.Errors;
using Rota.Modules.Identity.Infrastructure.Persistence;

namespace Rota.Modules.Identity.Infrastructure.Services;

public sealed class ProfilePhotoService(
    IdentityDbContext dbContext,
    IProfilePhotoStorage storage) : IProfilePhotoService
{
    public const long MaximumBytes = 5 * 1024 * 1024;

    public async Task<ProfilePhotoResponse> UploadAsync(
        Guid userId,
        Stream content,
        string contentType,
        long length,
        CancellationToken cancellationToken = default)
    {
        if (length is <= 0 or > MaximumBytes)
            throw new InvalidProfilePhotoException("Fotoğraf en fazla 5 MB olabilir.");

        await using var validated = new MemoryStream((int)length);
        await content.CopyToAsync(validated, cancellationToken);
        if (validated.Length != length || validated.Length > MaximumBytes)
            throw new InvalidProfilePhotoException("Fotoğraf boyutu geçersiz.");
        var extension = ProfilePhotoFileValidator.Validate(validated.ToArray(), contentType);
        validated.Position = 0;

        var user = await dbContext.Users.SingleOrDefaultAsync(x => x.Id == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Kullanıcı bulunamadı.");
        var oldUrl = user.ProfilePhotoUrl;
        var newUrl = await storage.SaveAsync(validated, extension, cancellationToken);
        user.SetProfilePhotoUrl(newUrl);
        try
        {
            await dbContext.SaveChangesAsync(cancellationToken);
        }
        catch
        {
            await storage.DeleteAsync(newUrl, cancellationToken);
            throw;
        }
        await storage.DeleteAsync(oldUrl, cancellationToken);
        return new ProfilePhotoResponse(newUrl);
    }

    public async Task<ProfilePhotoResponse> DeleteAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await dbContext.Users.SingleOrDefaultAsync(x => x.Id == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Kullanıcı bulunamadı.");
        var oldUrl = user.ProfilePhotoUrl;
        if (oldUrl is null) return new ProfilePhotoResponse(null);
        user.SetProfilePhotoUrl(null);
        await dbContext.SaveChangesAsync(cancellationToken);
        await storage.DeleteAsync(oldUrl, cancellationToken);
        return new ProfilePhotoResponse(null);
    }
}

internal static class ProfilePhotoFileValidator
{
    public static string Validate(byte[] bytes, string contentType)
    {
        return contentType.ToLowerInvariant() switch
        {
            "image/jpeg" when IsJpeg(bytes) => ".jpg",
            "image/png" when IsPng(bytes) => ".png",
            _ => throw new InvalidProfilePhotoException("Yalnızca geçerli JPEG veya PNG fotoğrafları yüklenebilir.")
        };
    }

    private static bool IsJpeg(byte[] bytes)
    {
        if (bytes.Length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8 ||
            bytes[^2] != 0xFF || bytes[^1] != 0xD9) return false;
        for (var index = 2; index < bytes.Length - 1; index++)
        {
            if (bytes[index] != 0xFF) continue;
            var marker = bytes[index + 1];
            if (marker is >= 0xC0 and <= 0xC3 or >= 0xC5 and <= 0xC7 or
                >= 0xC9 and <= 0xCB or >= 0xCD and <= 0xCF) return true;
        }
        return false;
    }

    private static bool IsPng(byte[] bytes) =>
        bytes.Length >= 33 &&
        bytes.AsSpan(0, 8).SequenceEqual(new byte[] { 137, 80, 78, 71, 13, 10, 26, 10 }) &&
        bytes.AsSpan(12, 4).SequenceEqual("IHDR"u8) &&
        bytes.AsSpan(bytes.Length - 8, 4).SequenceEqual("IEND"u8);
}
