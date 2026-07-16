using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Rota.Api.Security;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetRequiredUserId(this ClaimsPrincipal principal)
    {
        var subject = principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
        return Guid.TryParse(subject, out var userId)
            ? userId
            : throw new UnauthorizedAccessException("JWT subject claim geçersiz.");
    }
}
