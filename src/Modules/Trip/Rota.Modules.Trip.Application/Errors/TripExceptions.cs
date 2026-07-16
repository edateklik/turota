namespace Rota.Modules.Trip.Application.Errors;

public sealed class TripStateConflictException(string message) : Exception(message);
