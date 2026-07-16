namespace Rota.Modules.Identity.Application.Errors;

public sealed class EmailAlreadyExistsException : Exception
{
    public EmailAlreadyExistsException() : base("Bu e-posta adresi zaten kayıtlı.") { }
}

public sealed class InvalidCredentialsException : Exception
{
    public InvalidCredentialsException() : base("E-posta adresi veya parola hatalı.") { }
}

public sealed class InactiveUserException : Exception
{
    public InactiveUserException() : base("Kullanıcı hesabı aktif değil.") { }
}

public sealed class IdentityConflictException(string message) : Exception(message);
