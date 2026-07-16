using System.Net.Mail;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Rota.Modules.Identity.Domain.Entities;
using Rota.Modules.Identity.Infrastructure.Persistence;
using Rota.Modules.Identity.Infrastructure.Security;

namespace Rota.Modules.Identity.Infrastructure.Services;

public sealed class AdminBootstrapHostedService(
    IServiceScopeFactory scopeFactory,
    AdminBootstrapOptions options,
    TimeProvider timeProvider,
    ILogger<AdminBootstrapHostedService> logger) : IHostedService
{
    public async Task StartAsync(CancellationToken cancellationToken)
    {
        if (!options.Enabled) return;
        Validate(options);
        var email = new MailAddress(options.Email.Trim().ToLowerInvariant()).Address;
        var normalizedEmail = email.ToUpperInvariant();
        await using var scope = scopeFactory.CreateAsyncScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<IdentityDbContext>();
        var passwordHasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher<User>>();
        var user = await dbContext.Users.SingleOrDefaultAsync(
            item => item.NormalizedEmail == normalizedEmail,
            cancellationToken);
        if (user is null)
        {
            user = new User(
                Guid.NewGuid(),
                email,
                normalizedEmail,
                options.FirstName.Trim(),
                options.LastName.Trim(),
                timeProvider.GetUtcNow());
            user.ChangeRole(UserRole.Admin);
            user.SetPasswordHash(passwordHasher.HashPassword(user, options.Password));
            dbContext.Users.Add(user);
            dbContext.TasteProfiles.Add(new TasteProfile(user.Id, timeProvider.GetUtcNow()));
            await dbContext.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Development admin bootstrap hesabı oluşturuldu: {Email}", email);
            return;
        }

        var changed = false;
        if (user.Role != UserRole.Admin)
        {
            user.ChangeRole(UserRole.Admin);
            changed = true;
        }
        if (!user.IsActive)
        {
            user.Activate();
            changed = true;
        }
        if (changed)
        {
            await dbContext.SaveChangesAsync(cancellationToken);
            logger.LogWarning("Bootstrap hesabının Admin erişimi yeniden etkinleştirildi: {Email}", email);
        }
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;

    private static void Validate(AdminBootstrapOptions options)
    {
        if (string.IsNullOrWhiteSpace(options.Email))
            throw new InvalidOperationException("AdminBootstrap:Email zorunludur.");
        if (options.Password.Length is < 12 or > 128 ||
            !options.Password.Any(char.IsUpper) ||
            !options.Password.Any(char.IsLower) ||
            !options.Password.Any(char.IsDigit) ||
            options.Password.All(char.IsLetterOrDigit))
            throw new InvalidOperationException("Admin bootstrap parolası 12-128 karakter; büyük/küçük harf, rakam ve özel karakter içermelidir.");
        if (string.IsNullOrWhiteSpace(options.FirstName) || string.IsNullOrWhiteSpace(options.LastName))
            throw new InvalidOperationException("Admin bootstrap adı ve soyadı zorunludur.");
    }
}
