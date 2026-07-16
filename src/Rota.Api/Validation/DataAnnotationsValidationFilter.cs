using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Rota.Api.Errors;

namespace Rota.Api.Validation;

public sealed class DataAnnotationsValidationFilter<T>(TimeProvider timeProvider) : IEndpointFilter where T : class
{
    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var request = context.Arguments.OfType<T>().SingleOrDefault();
        if (request is null) return Results.BadRequest();

        var results = new List<ValidationResult>();
        if (Validator.TryValidateObject(request, new ValidationContext(request), results, validateAllProperties: true))
            return await next(context);

        var errors = results
            .SelectMany(result => result.MemberNames.DefaultIfEmpty(string.Empty)
                .Select(member => new { Member = member, Message = result.ErrorMessage ?? "Geçersiz değer." }))
            .GroupBy(x => x.Member, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(group => group.Key, group => group.Select(x => x.Message).Distinct().ToArray());
        var problem = new ApiValidationProblemDetails(errors)
        {
            Type = "https://api.rota.local/errors/validation_error",
            Title = "İstek doğrulaması başarısız",
            Status = StatusCodes.Status400BadRequest,
            Instance = context.HttpContext.Request.Path,
            TraceId = context.HttpContext.TraceIdentifier,
            Timestamp = timeProvider.GetUtcNow()
        };
        return Results.Json(problem, statusCode: StatusCodes.Status400BadRequest, contentType: "application/problem+json");
    }
}
