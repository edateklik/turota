namespace Rota.Modules.Discovery.Domain.Entities;

public sealed class Category
{
    private Category() { }

    public Category(Guid id, string name, string slug)
    {
        Id = id;
        Name = name;
        Slug = slug;
    }

    public Guid Id { get; private set; }
    public string Name { get; private set; } = null!;
    public string Slug { get; private set; } = null!;
    public ICollection<Place> Places { get; } = new List<Place>();

    public void Update(string name, string slug)
    {
        Name = name;
        Slug = slug;
    }
}
