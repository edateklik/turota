using Rota.Modules.Identity.Application.Contracts;
using Rota.Modules.Recommendation.Application.Contracts;

namespace Rota.Modules.Recommendation.Infrastructure.Integration;

public sealed class IdentityTasteProfileProvider(IIdentityService identityService) : ITasteProfileProvider
{
    public async Task<TasteProfileSnapshot> GetAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var profile = await identityService.GetTasteProfileAsync(userId, cancellationToken);
        return new(
            profile.PreferredCategoryIds,
            profile.PreferredTagIds,
            profile.DietaryPreference.ToString(),
            profile.BudgetLevel.ToString(),
            profile.TravelPace.ToString(),
            profile.DistancePreference.ToString());
    }
}
