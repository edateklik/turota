namespace Rota.Modules.Identity.Domain.Entities;

public enum BudgetLevel
{
    Economy = 0,
    Moderate = 1,
    Premium = 2,
    Mixed = 3
}

public enum TravelPace
{
    Relaxed = 0,
    Balanced = 1,
    Intensive = 2
}

public enum DietaryPreference
{
    Everything = 0,
    Vegetarian = 1,
    Vegan = 2,
    GlutenFree = 3,
    NoPreference = 4
}

public enum DistancePreference
{
    WalkingDistance = 0,
    Max3Km = 1,
    Max10Km = 2,
    CityWide = 3,
    Flexible = 4
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

    /// <summary>Eski çoğul alan — yeni kayıtlarda kullanılmaz, geriye dönük uyumluluk için tutulur.</summary>
    public string[] DietaryPreferences { get; private set; } = [];

    public DietaryPreference DietaryPreference { get; private set; } = DietaryPreference.NoPreference;
    public BudgetLevel BudgetLevel { get; private set; } = BudgetLevel.Moderate;
    public TravelPace TravelPace { get; private set; } = TravelPace.Balanced;
    public DistancePreference DistancePreference { get; private set; } = DistancePreference.Flexible;
    public DateTimeOffset UpdatedAt { get; private set; }
    public User User { get; private set; } = null!;

    public void Update(
        Guid[] preferredCategoryIds,
        Guid[] preferredTagIds,
        DietaryPreference dietaryPreference,
        BudgetLevel budgetLevel,
        TravelPace travelPace,
        DistancePreference distancePreference,
        DateTimeOffset updatedAt)
    {
        PreferredCategoryIds = preferredCategoryIds;
        PreferredTagIds = preferredTagIds;
        DietaryPreference = dietaryPreference;
        DietaryPreferences = []; // legacy field cleared
        BudgetLevel = budgetLevel;
        TravelPace = travelPace;
        DistancePreference = distancePreference;
        UpdatedAt = updatedAt;
    }
}
