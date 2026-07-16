using Microsoft.EntityFrameworkCore;
using Rota.Modules.Identity.Application.Contracts;
using Rota.Modules.Identity.Application.Errors;
using Rota.Modules.Identity.Domain.Entities;
using Rota.Modules.Identity.Infrastructure.Persistence;

namespace Rota.Modules.Identity.Infrastructure.Services;

public sealed class AdminIdentityService(IdentityDbContext dbContext) : IAdminIdentityService
{
    public async Task<AdminUserPageResponse> GetPageAsync(
        int page,
        int pageSize,
        CancellationToken cancellationToken = default)
    {
        if (page < 1 || pageSize is < 1 or > 100)
            throw new ArgumentException("Sayfa en az 1, sayfa boyutu 1-100 olmalıdır.");
        var query = dbContext.Users.AsNoTracking();
        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query.OrderBy(user => user.Email)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(user => new AdminUserResponse(
                user.Id,
                user.Email,
                user.FirstName,
                user.LastName,
                user.Role,
                user.IsActive,
                user.CreatedAt))
            .ToListAsync(cancellationToken);
        return new AdminUserPageResponse(items, page, pageSize, totalCount);
    }

    public async Task<AdminUserResponse> UpdateAccessAsync(
        Guid actingAdminId,
        Guid userId,
        UpdateUserAccessRequest request,
        CancellationToken cancellationToken = default)
    {
        if (!Enum.IsDefined(request.Role))
            throw new ArgumentException("Kullanıcı rolü geçersizdir.");
        var user = await dbContext.Users.SingleOrDefaultAsync(item => item.Id == userId, cancellationToken)
            ?? throw new KeyNotFoundException("Kullanıcı bulunamadı.");
        var removesAdminAccess = user.Role == UserRole.Admin &&
            (request.Role != UserRole.Admin || !request.IsActive);
        if (removesAdminAccess)
        {
            if (user.Id == actingAdminId)
                throw new IdentityConflictException("Admin kendi yönetim yetkisini veya erişimini kaldıramaz.");
            var activeAdminCount = await dbContext.Users.CountAsync(
                item => item.Role == UserRole.Admin && item.IsActive,
                cancellationToken);
            if (activeAdminCount <= 1)
                throw new IdentityConflictException("Sistemde en az bir aktif Admin bulunmalıdır.");
        }

        user.ChangeRole(request.Role);
        if (request.IsActive) user.Activate();
        else user.Deactivate();
        await dbContext.SaveChangesAsync(cancellationToken);
        return Map(user);
    }

    private static AdminUserResponse Map(User user) => new(
        user.Id,
        user.Email,
        user.FirstName,
        user.LastName,
        user.Role,
        user.IsActive,
        user.CreatedAt);
}
