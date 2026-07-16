namespace Rota.Modules.Identity.Infrastructure.Security;

public sealed class AdminBootstrapOptions
{
    public const string SectionName = "AdminBootstrap";

    public bool Enabled { get; init; }
    public string Email { get; init; } = string.Empty;
    public string Password { get; init; } = string.Empty;
    public string FirstName { get; init; } = "Rota";
    public string LastName { get; init; } = "Admin";
}
