using Rota.Modules.Identity.Application.Contracts;

namespace Rota.Modules.Identity.Infrastructure.Services;

public sealed class ProfilePhotoStorageOptions
{
    public const string SectionName = "ProfilePhotos";
    public string RootPath { get; set; } = Path.Combine("uploads", "profile-photos");
    public string RequestPath { get; set; } = "/uploads/profile-photos";
}

public sealed class LocalProfilePhotoStorage(ProfilePhotoStorageOptions options) : IProfilePhotoStorage
{
    private readonly string _rootPath = NormalizeRootPath(options.RootPath);
    private readonly string _requestPath = NormalizeRequestPath(options.RequestPath);

    public async Task<string> SaveAsync(Stream content, string extension, CancellationToken cancellationToken = default)
    {
        if (extension is not ".jpg" and not ".png")
            throw new ArgumentException("Desteklenmeyen profil fotoğrafı uzantısı.", nameof(extension));

        try
        {
            Directory.CreateDirectory(_rootPath);
            var fileName = $"{Guid.NewGuid():N}{extension}";
            var destination = ResolveFilePath(fileName);
            await using var output = new FileStream(
                destination,
                FileMode.CreateNew,
                FileAccess.Write,
                FileShare.None,
                81920,
                FileOptions.Asynchronous);
            await content.CopyToAsync(output, cancellationToken);
            await output.FlushAsync(cancellationToken);
            return $"{_requestPath}/{fileName}";
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException)
        {
            throw new ProfilePhotoStorageException("Profil fotoğrafı depolama işlemi tamamlanamadı.", exception);
        }
    }

    public Task DeleteAsync(string? publicUrl, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(publicUrl)) return Task.CompletedTask;
        var prefix = $"{_requestPath}/";
        if (!publicUrl.StartsWith(prefix, StringComparison.Ordinal)) return Task.CompletedTask;
        var fileName = publicUrl[prefix.Length..];
        if (fileName != Path.GetFileName(fileName)) return Task.CompletedTask;
        try
        {
            var path = ResolveFilePath(fileName);
            if (File.Exists(path)) File.Delete(path);
            return Task.CompletedTask;
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException)
        {
            throw new ProfilePhotoStorageException("Profil fotoğrafı depolama işlemi tamamlanamadı.", exception);
        }
    }

    private string ResolveFilePath(string fileName)
    {
        var path = Path.GetFullPath(Path.Combine(_rootPath, fileName));
        var rootPrefix = _rootPath.EndsWith(Path.DirectorySeparatorChar)
            ? _rootPath
            : _rootPath + Path.DirectorySeparatorChar;
        if (!path.StartsWith(rootPrefix, StringComparison.Ordinal))
            throw new InvalidOperationException("Profil fotoğrafı yolu yapılandırılmış storage root dışına çıkamaz.");
        return path;
    }

    private static string NormalizeRootPath(string rootPath)
    {
        if (string.IsNullOrWhiteSpace(rootPath))
            throw new InvalidOperationException("ProfilePhotos:RootPath yapılandırılmalıdır.");
        return Path.GetFullPath(rootPath);
    }

    private static string NormalizeRequestPath(string requestPath)
    {
        if (string.IsNullOrWhiteSpace(requestPath) || !requestPath.StartsWith('/'))
            throw new InvalidOperationException("ProfilePhotos:RequestPath '/' ile başlayan bir URL yolu olmalıdır.");
        return requestPath.TrimEnd('/');
    }
}

public sealed class ProfilePhotoStorageException(string message, Exception innerException)
    : Exception(message, innerException);
