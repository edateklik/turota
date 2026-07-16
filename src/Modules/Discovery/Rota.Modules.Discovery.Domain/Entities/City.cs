namespace Rota.Modules.Discovery.Domain.Entities;

public sealed class City
{
    private City() { }

    public City(Guid id, string name, string countryCode)
    {
        Id = id;
        Name = name;
        CountryCode = countryCode;
    }

    public Guid Id { get; private set; }
    public string Name { get; private set; } = null!;
    public string CountryCode { get; private set; } = null!;
    public ICollection<Neighborhood> Neighborhoods { get; } = new List<Neighborhood>();

    public void Update(string name, string countryCode)
    {
        Name = name;
        CountryCode = countryCode;
    }
}
