using NetTopologySuite.Geometries;

namespace Rota.Modules.Discovery.Domain.Entities;

public sealed class Neighborhood
{
    private Neighborhood() { }

    public Neighborhood(Guid id, Guid cityId, string name, MultiPolygon boundary)
    {
        Id = id;
        CityId = cityId;
        Name = name;
        Boundary = boundary;
    }

    public Guid Id { get; private set; }
    public Guid CityId { get; private set; }
    public string Name { get; private set; } = null!;
    public MultiPolygon Boundary { get; private set; } = null!;
    public City City { get; private set; } = null!;
    public ICollection<Place> Places { get; } = new List<Place>();

    public void Update(Guid cityId, string name, MultiPolygon boundary)
    {
        CityId = cityId;
        Name = name;
        Boundary = boundary;
    }
}
