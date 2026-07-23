using System.Diagnostics;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Rota.Modules.Identity.Application.Errors;
using Rota.Modules.Identity.Infrastructure.Services;
using Rota.Modules.Recommendation.Application.Errors;
using Rota.Modules.Trip.Application.Errors;

namespace Rota.Api.Errors;

public sealed class GlobalExceptionHandler(
    ILogger<GlobalExceptionHandler> logger,
    IProblemDetailsService problemDetailsService,
    TimeProvider timeProvider) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        var error = Map(exception);
        if (error.Status >= 500)
            logger.LogError(exception, "Request failed: {ErrorCode} {TraceId}", error.Code, httpContext.TraceIdentifier);
        else
            logger.LogWarning(exception, "Request rejected: {ErrorCode} {TraceId}", error.Code, httpContext.TraceIdentifier);

        var problem = new ApiProblemDetails
        {
            Type = $"https://api.rota.local/errors/{error.Code.ToLowerInvariant()}",
            Title = error.Title,
            Status = error.Status,
            Detail = error.ExposeDetail ? exception.Message : "İstek işlenirken beklenmeyen bir hata oluştu.",
            Instance = httpContext.Request.Path,
            ErrorCode = error.Code,
            TraceId = Activity.Current?.Id ?? httpContext.TraceIdentifier,
            Timestamp = timeProvider.GetUtcNow()
        };

        httpContext.Response.StatusCode = error.Status;
        return await problemDetailsService.TryWriteAsync(new ProblemDetailsContext
        {
            HttpContext = httpContext,
            ProblemDetails = problem,
            Exception = exception
        });
    }

    private static ErrorDescriptor Map(Exception exception) => exception switch
    {
        InvalidCredentialsException => new(401, "Kimlik doğrulama başarısız", "INVALID_CREDENTIALS", true),
        UnauthorizedAccessException => new(401, "Yetkisiz istek", "UNAUTHORIZED", true),
        InactiveUserException => new(403, "Hesap aktif değil", "USER_INACTIVE", true),
        EmailAlreadyExistsException => new(409, "E-posta zaten kayıtlı", "EMAIL_ALREADY_EXISTS", true),
        IdentityConflictException => new(409, "Kimlik erişimi çakışıyor", "IDENTITY_CONFLICT", true),
        InvalidProfilePhotoException => new(400, "Geçersiz profil fotoğrafı", "INVALID_PROFILE_PHOTO", true),
        ProfilePhotoStorageException => new(500, "Profil fotoğrafı depolanamadı", "PROFILE_PHOTO_STORAGE_ERROR", false),
        TripStateConflictException => new(409, "Rota durumu çakışıyor", "TRIP_STATE_CONFLICT", true),
        AiContractException integration => new(502, "AI yanıtı geçersiz", integration.ErrorCode, true),
        AiServiceUnavailableException integration => new(503, "AI servisi kullanılamıyor", integration.ErrorCode, true),
        AiServiceTimeoutException integration => new(504, "AI servisi zaman aşımı", integration.ErrorCode, true),
        BadHttpRequestException => new(400, "Geçersiz istek gövdesi", "INVALID_REQUEST_BODY", true),
        ArgumentException => new(400, "Geçersiz istek", "VALIDATION_ERROR", true),
        KeyNotFoundException => new(404, "Kayıt bulunamadı", "NOT_FOUND", true),
        DbUpdateConcurrencyException => new(409, "Eşzamanlı güncelleme çakışması", "CONCURRENCY_CONFLICT", false),
        DbUpdateException => new(409, "Veritabanı kısıtı ihlali", "DATABASE_CONFLICT", false),
        OperationCanceledException => new(408, "İstek zaman aşımı", "REQUEST_TIMEOUT", false),
        _ => new(500, "Beklenmeyen sunucu hatası", "INTERNAL_ERROR", false)
    };

    private sealed record ErrorDescriptor(int Status, string Title, string Code, bool ExposeDetail);
}
