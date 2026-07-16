using NetTopologySuite.Geometries;

namespace Rota.Modules.Discovery.Domain.Entities;

public sealed class Place
{
    private Place() { }

    public Place(Guid id, Guid neighborhoodId, Guid categoryId, string name, string address, Point location)
    {
        Id = id;
        NeighborhoodId = neighborhoodId;
        CategoryId = categoryId;
        Name = name;
        Address = address;
        Location = location;
    }

    public Guid Id { get; private set; }
    public Guid NeighborhoodId { get; private set; }
    public Guid CategoryId { get; private set; }
    public string Name { get; private set; } = null!;
    public string Address { get; private set; } = null!;
    public Point Location { get; private set; } = null!;
    public Neighborhood Neighborhood { get; private set; } = null!;
    public Category Category { get; private set; } = null!;
    public ICollection<Tag> Tags { get; } = new List<Tag>();
    public PlaceFeatureVector? FeatureVector { get; private set; }

    public void Update(Guid neighborhoodId, Guid categoryId, string name, string address, Point location)
    {
        NeighborhoodId = neighborhoodId;
        CategoryId = categoryId;
        Name = name;
        Address = address;
        Location = location;
    }
}
