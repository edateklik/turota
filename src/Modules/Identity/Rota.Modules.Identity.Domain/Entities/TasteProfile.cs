namespace Rota.Modules.Identity.Domain.Entities;

public enum BudgetLevel
{
    Economy = 0,
    Moderate = 1,
    Premium = 2
}

public enum TravelPace
{
    Relaxed = 0,
    Balanced = 1,
    Intensive = 2
}

public sealed class TasteProfile
{
    private TasteProfile() { }

    public TasteProfile(Guid userId, DateTimeOffset updatedAt)
    {
        UserId = userId;
        UpdatedAt = updatedAt;
    }

    public Guid UserId { get; private set; }
    public Guid[] PreferredCategoryIds { get; private set; } = [];
    public Guid[] PreferredTagIds { get; private set; } = [];
    public string[] DietaryPreferences { get; private set; } = [];
    public BudgetLevel BudgetLevel { get; private set; } = BudgetLevel.Moderate;
    public TravelPace TravelPace { get; private set; } = TravelPace.Balanced;
    public DateTimeOffset UpdatedAt { get; private set; }
    public User User { get; private set; } = null!;

    public void Update(
        Guid[] preferredCategoryIds,
        Guid[] preferredTagIds,
        string[] dietaryPreferences,
        BudgetLevel budgetLevel,
        TravelPace travelPace,
        DateTimeOffset updatedAt)
    {
        PreferredCategoryIds = preferredCategoryIds;
        PreferredTagIds = preferredTagIds;
        DietaryPreferences = dietaryPreferences;
        BudgetLevel = budgetLevel;
        TravelPace = travelPace;
        UpdatedAt = updatedAt;
    }
}
