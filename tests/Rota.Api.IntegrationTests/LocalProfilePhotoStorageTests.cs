using Rota.Modules.Identity.Infrastructure.Services;
using Xunit;

namespace Rota.Api.IntegrationTests;

public sealed class LocalProfilePhotoStorageTests : IDisposable
{
    private readonly string _testRoot = Path.Combine(
        Path.GetTempPath(),
        $"rota-profile-photo-storage-{Guid.NewGuid():N}");

    [Fact]
    public async Task SaveAsync_MissingRoot_CreatesDirectoryAndFileWithMappedUrl()
    {
        var storage = CreateStorage();
        await using var content = new MemoryStream([1, 2, 3, 4]);

        var publicUrl = await storage.SaveAsync(content, ".jpg");

        Assert.True(Directory.Exists(_testRoot));
        Assert.StartsWith("/uploads/profile-photos/", publicUrl, StringComparison.Ordinal);
        var fileName = publicUrl["/uploads/profile-photos/".Length..];
        var physicalPath = Path.Combine(_testRoot, fileName);
        Assert.True(File.Exists(physicalPath));
        Assert.Equal([1, 2, 3, 4], await File.ReadAllBytesAsync(physicalPath));
    }

    [Fact]
    public async Task DeleteAsync_StoredPhoto_RemovesPhysicalFile()
    {
        var storage = CreateStorage();
        await using var content = new MemoryStream([5, 6, 7]);
        var publicUrl = await storage.SaveAsync(content, ".png");
        var physicalPath = Path.Combine(
            _testRoot,
            publicUrl["/uploads/profile-photos/".Length..]);

        await storage.DeleteAsync(publicUrl);

        Assert.False(File.Exists(physicalPath));
    }

    [Fact]
    public async Task DeleteAsync_TraversalUrl_DoesNotDeleteOutsideRoot()
    {
        Directory.CreateDirectory(_testRoot);
        var outsidePath = Path.Combine(
            Path.GetDirectoryName(_testRoot)!,
            $"outside-{Guid.NewGuid():N}.jpg");
        await File.WriteAllBytesAsync(outsidePath, [8, 9]);
        try
        {
            var storage = CreateStorage();

            await storage.DeleteAsync($"/uploads/profile-photos/../{Path.GetFileName(outsidePath)}");

            Assert.True(File.Exists(outsidePath));
        }
        finally
        {
            File.Delete(outsidePath);
        }
    }

    [Fact]
    public async Task SaveAsync_InvalidExtension_CannotEscapeStorageRoot()
    {
        var storage = CreateStorage();
        await using var content = new MemoryStream([1]);

        await Assert.ThrowsAsync<ArgumentException>(
            () => storage.SaveAsync(content, "/../../outside.jpg"));
    }

    [Fact]
    public async Task SaveAsync_UnusableRoot_ReturnsConsistentStorageException()
    {
        Directory.CreateDirectory(Path.GetDirectoryName(_testRoot)!);
        await File.WriteAllTextAsync(_testRoot, "root path is a file");
        var storage = CreateStorage();
        await using var content = new MemoryStream([1, 2]);

        var exception = await Assert.ThrowsAsync<ProfilePhotoStorageException>(
            () => storage.SaveAsync(content, ".jpg"));

        Assert.Equal("Profil fotoğrafı depolama işlemi tamamlanamadı.", exception.Message);
        Assert.IsAssignableFrom<IOException>(exception.InnerException);
    }

    public void Dispose()
    {
        if (Directory.Exists(_testRoot))
            Directory.Delete(_testRoot, recursive: true);
        else if (File.Exists(_testRoot))
            File.Delete(_testRoot);
    }

    private LocalProfilePhotoStorage CreateStorage() =>
        new(new ProfilePhotoStorageOptions
        {
            RootPath = _testRoot,
            RequestPath = "/uploads/profile-photos"
        });
}
