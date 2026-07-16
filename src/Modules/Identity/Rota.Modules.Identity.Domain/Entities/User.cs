namespace Rota.Modules.Identity.Domain.Entities;

public enum UserRole
{
    User = 0,
    Admin = 1
}

public sealed class User
{
    private User() { }

    public User(Guid id, string email, string normalizedEmail, string firstName, string lastName, DateTimeOffset createdAt)
    {
        Id = id;
        Email = email;
        NormalizedEmail = normalizedEmail;
        FirstName = firstName;
        LastName = lastName;
        CreatedAt = createdAt;
        Role = UserRole.User;
        IsActive = true;
    }

    public Guid Id { get; private set; }
    public string Email { get; private set; } = null!;
    public string NormalizedEmail { get; private set; } = null!;
    public string PasswordHash { get; private set; } = null!;
    public string FirstName { get; private set; } = null!;
    public string LastName { get; private set; } = null!;
    public UserRole Role { get; private set; }
    public bool IsActive { get; private set; }
    public DateTimeOffset CreatedAt { get; private set; }
    public TasteProfile? TasteProfile { get; private set; }

    public void SetPasswordHash(string passwordHash) => PasswordHash = passwordHash;
    public void ChangeRole(UserRole role) => Role = role;
    public void Deactivate() => IsActive = false;
    public void Activate() => IsActive = true;
}
