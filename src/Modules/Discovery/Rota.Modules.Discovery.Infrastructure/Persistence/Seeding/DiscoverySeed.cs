using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;
using Rota.Modules.Discovery.Domain.Entities;

namespace Rota.Modules.Discovery.Infrastructure.Persistence.Seeding;

/// <summary>
/// Deterministic demo data. Coordinates are WGS84 (longitude, latitude), SRID 4326.
/// Boundaries are deliberately simplified demo polygons, not administrative source data.
/// </summary>
internal static class DiscoverySeed
{
    private const int Srid = 4326;
    private static readonly GeometryFactory GeometryFactory = new(new PrecisionModel(), Srid);

    internal static readonly Guid IstanbulId = Id("10000000-0000-0000-0000-000000000001");
    internal static readonly Guid CaferagaId = Id("20000000-0000-0000-0000-000000000001");
    internal static readonly Guid BesiktasId = Id("20000000-0000-0000-0000-000000000002");
    internal static readonly Guid KarakoyId = Id("20000000-0000-0000-0000-000000000003");

    private static readonly (Guid Id, string Name, string Slug)[] CategoryRows =
    [
        (Id("30000000-0000-0000-0000-000000000001"), "Kafe", "kafe"),
        (Id("30000000-0000-0000-0000-000000000002"), "Restoran", "restoran"),
        (Id("30000000-0000-0000-0000-000000000003"), "Müze", "muze"),
        (Id("30000000-0000-0000-0000-000000000004"), "Park", "park"),
        (Id("30000000-0000-0000-0000-000000000005"), "Sanat", "sanat"),
        (Id("30000000-0000-0000-0000-000000000006"), "Alışveriş", "alisveris")
    ];

    private static readonly (Guid Id, string Name, string Slug)[] TagRows =
    [
        (Id("40000000-0000-0000-0000-000000000001"), "Aile Dostu", "aile-dostu"),
        (Id("40000000-0000-0000-0000-000000000002"), "Bütçe Dostu", "butce-dostu"),
        (Id("40000000-0000-0000-0000-000000000003"), "Manzaralı", "manzarali"),
        (Id("40000000-0000-0000-0000-000000000004"), "Tarihi", "tarihi"),
        (Id("40000000-0000-0000-0000-000000000005"), "Vegan Seçenekli", "vegan-secenekli"),
        (Id("40000000-0000-0000-0000-000000000006"), "Gece Açık", "gece-acik"),
        (Id("40000000-0000-0000-0000-000000000007"), "Evcil Hayvan Dostu", "evcil-hayvan-dostu"),
        (Id("40000000-0000-0000-0000-000000000008"), "Erişilebilir", "erisilebilir")
    ];

    private static readonly Neighborhood[] NeighborhoodRows =
    [
        new(CaferagaId, IstanbulId, "Caferağa", Rectangle(29.0200, 40.9780, 29.0350, 40.9920)),
        new(BesiktasId, IstanbulId, "Beşiktaş", Rectangle(29.0000, 41.0350, 29.0180, 41.0520)),
        new(KarakoyId, IstanbulId, "Karaköy", Rectangle(28.9680, 41.0180, 28.9900, 41.0300))
    ];

    private static readonly PlaceSeed[] PlaceRows =
    [
        P(1, CaferagaId, 1, "Moda Kahve Noktası", "Moda Cd., Kadıköy", 29.0257, 40.9848),
        P(2, CaferagaId, 2, "Caferağa Sofrası", "Sakızgülü Sk., Kadıköy", 29.0272, 40.9871),
        P(3, CaferagaId, 4, "Moda Sahil Parkı", "Moda Sahili, Kadıköy", 29.0231, 40.9810),
        P(4, CaferagaId, 5, "Kadıköy Sanat Atölyesi", "Neşe Sk., Kadıköy", 29.0298, 40.9880),
        P(5, CaferagaId, 6, "Moda Tasarım Pazarı", "Moda Cd., Kadıköy", 29.0264, 40.9857),
        P(6, CaferagaId, 1, "Bahariye Kitap Kafe", "Bahariye Cd., Kadıköy", 29.0310, 40.9901),
        P(7, CaferagaId, 2, "Sahil Lokantası", "Rıhtım Yolu, Kadıköy", 29.0218, 40.9860),
        P(8, CaferagaId, 3, "Mahalle Kültür Evi", "Dr. Esat Işık Cd., Kadıköy", 29.0286, 40.9832),
        P(9, CaferagaId, 5, "Moda Sahnesi", "Halil Ethem Sk., Kadıköy", 29.0302, 40.9850),
        P(10, CaferagaId, 1, "Günbatımı Kahvesi", "Moda Burnu, Kadıköy", 29.0222, 40.9799),
        P(11, CaferagaId, 6, "Caferağa Plakçısı", "Şair Nefi Sk., Kadıköy", 29.0321, 40.9878),
        P(12, CaferagaId, 2, "Moda Vegan Mutfağı", "Leylek Sk., Kadıköy", 29.0248, 40.9890),

        P(13, BesiktasId, 1, "Çarşı Kahve Evi", "Köyiçi Cd., Beşiktaş", 29.0058, 41.0433),
        P(14, BesiktasId, 2, "Beşiktaş Esnaf Lokantası", "Şehit Asım Cd., Beşiktaş", 29.0069, 41.0445),
        P(15, BesiktasId, 3, "Deniz Müzesi Çevresi", "Dolmabahçe Cd., Beşiktaş", 29.0051, 41.0417),
        P(16, BesiktasId, 4, "Abbasağa Dinlenme Alanı", "Abbasağa, Beşiktaş", 29.0098, 41.0480),
        P(17, BesiktasId, 5, "Akaretler Galeri", "Süleyman Seba Cd., Beşiktaş", 29.0038, 41.0410),
        P(18, BesiktasId, 6, "Çarşı Tasarım Dükkanı", "Ortabahçe Cd., Beşiktaş", 29.0078, 41.0451),
        P(19, BesiktasId, 1, "Ihlamur Bahçe Kafe", "Ihlamurdere Cd., Beşiktaş", 29.0118, 41.0466),
        P(20, BesiktasId, 2, "Boğaz Balık Mutfağı", "İskele Cd., Beşiktaş", 29.0044, 41.0428),
        P(21, BesiktasId, 5, "Beşiktaş Performans Alanı", "Barbaros Blv., Beşiktaş", 29.0088, 41.0420),
        P(22, BesiktasId, 4, "Yıldız Yürüyüş Noktası", "Palanga Cd., Beşiktaş", 29.0147, 41.0495),
        P(23, BesiktasId, 1, "Vapur İskelesi Kahvesi", "Beşiktaş İskele, Beşiktaş", 29.0030, 41.0438),
        P(24, BesiktasId, 6, "Yerel Üretici Pazarı", "Nüzhetiye Cd., Beşiktaş", 29.0128, 41.0456),

        P(25, KarakoyId, 1, "Karaköy Kavurma Evi", "Kemankeş Cd., Beyoğlu", 28.9784, 41.0221),
        P(26, KarakoyId, 2, "Liman Mutfağı", "Rıhtım Cd., Beyoğlu", 28.9760, 41.0212),
        P(27, KarakoyId, 3, "Tarihi Liman Sergisi", "Tersane Cd., Beyoğlu", 28.9735, 41.0240),
        P(28, KarakoyId, 5, "Tophane Sanat Alanı", "Boğazkesen Cd., Beyoğlu", 28.9822, 41.0261),
        P(29, KarakoyId, 6, "Karaköy Tasarım Hanı", "Mumhane Cd., Beyoğlu", 28.9798, 41.0235),
        P(30, KarakoyId, 1, "Galata Altı Kahvesi", "Yüksek Kaldırım Cd., Beyoğlu", 28.9828, 41.0250),
        P(31, KarakoyId, 2, "Perşembe Pazarı Lokantası", "Perşembe Pazarı Cd., Beyoğlu", 28.9714, 41.0247),
        P(32, KarakoyId, 5, "Rıhtım Fotoğraf Galerisi", "Necatibey Cd., Beyoğlu", 28.9752, 41.0228),
        P(33, KarakoyId, 6, "Yeraltı Plak Pazarı", "Bankalar Cd., Beyoğlu", 28.9810, 41.0244),
        P(34, KarakoyId, 1, "Gün Doğumu Fırını", "Kılıç Ali Paşa Cd., Beyoğlu", 28.9851, 41.0230),
        P(35, KarakoyId, 3, "Karaköy Kent Hafızası", "Voyvoda Cd., Beyoğlu", 28.9800, 41.0258),
        P(36, KarakoyId, 4, "Liman Seyir Terası", "Karaköy Rıhtımı, Beyoğlu", 28.9730, 41.0200)
    ];

    public static void Apply(ModelBuilder modelBuilder)
    {
        ValidateOrThrow();

        modelBuilder.Entity<City>().HasData(new City(IstanbulId, "İstanbul", "TR"));
        modelBuilder.Entity<Neighborhood>().HasData(NeighborhoodRows);
        modelBuilder.Entity<Category>().HasData(CategoryRows.Select(x => new Category(x.Id, x.Name, x.Slug)));
        modelBuilder.Entity<Tag>().HasData(TagRows.Select(x => new Tag(x.Id, x.Name, x.Slug)));
        modelBuilder.Entity<Place>().HasData(PlaceRows.Select(x =>
            new Place(x.Id, x.NeighborhoodId, x.CategoryId, x.Name, x.Address, x.Location)));

        var placeTags = PlaceRows.SelectMany((place, index) => new[]
        {
            new Dictionary<string, object> { ["place_id"] = place.Id, ["tag_id"] = TagRows[index % TagRows.Length].Id },
            new Dictionary<string, object> { ["place_id"] = place.Id, ["tag_id"] = TagRows[(index + 3) % TagRows.Length].Id }
        });
        modelBuilder.Entity("PlaceTag").HasData(placeTags);
    }

    public static void ValidateOrThrow()
    {
        var errors = new List<string>();

        if (NeighborhoodRows.Length < 3)
            errors.Add("En az 3 mahalle bulunmalıdır.");
        if (PlaceRows.Length is < 30 or > 50)
            errors.Add($"Mekan sayısı 30-50 aralığında olmalıdır; mevcut: {PlaceRows.Length}.");
        if (NeighborhoodRows.Any(x => x.Boundary.SRID != Srid || !x.Boundary.IsValid || x.Boundary.IsEmpty))
            errors.Add("Tüm mahalle sınırları geçerli, dolu MultiPolygon ve SRID 4326 olmalıdır.");
        if (PlaceRows.Any(x => x.Location.SRID != Srid || x.Location.IsEmpty))
            errors.Add("Tüm mekan noktaları dolu ve SRID 4326 olmalıdır.");
        if (PlaceRows.Select(x => x.Id).Distinct().Count() != PlaceRows.Length)
            errors.Add("Mekan kimlikleri benzersiz olmalıdır.");

        foreach (var place in PlaceRows)
        {
            var neighborhood = NeighborhoodRows.SingleOrDefault(x => x.Id == place.NeighborhoodId);
            if (neighborhood is null || !neighborhood.Boundary.Covers(place.Location))
                errors.Add($"'{place.Name}' koordinatı bağlı olduğu mahalle sınırının dışındadır.");
            if (CategoryRows.All(x => x.Id != place.CategoryId))
                errors.Add($"'{place.Name}' geçersiz kategoriye bağlıdır.");
        }

        if (errors.Count > 0)
            throw new InvalidOperationException("Discovery seed doğrulaması başarısız:" + Environment.NewLine + string.Join(Environment.NewLine, errors));
    }

    private static PlaceSeed P(int number, Guid neighborhoodId, int categoryNumber, string name, string address, double longitude, double latitude) =>
        new(Id($"50000000-0000-0000-0000-{number:000000000000}"), neighborhoodId, CategoryRows[categoryNumber - 1].Id, name, address, Point(longitude, latitude));

    private static Point Point(double longitude, double latitude) => GeometryFactory.CreatePoint(new Coordinate(longitude, latitude));

    private static MultiPolygon Rectangle(double minLongitude, double minLatitude, double maxLongitude, double maxLatitude)
    {
        var shell = GeometryFactory.CreateLinearRing(
        [
            new(minLongitude, minLatitude),
            new(maxLongitude, minLatitude),
            new(maxLongitude, maxLatitude),
            new(minLongitude, maxLatitude),
            new(minLongitude, minLatitude)
        ]);
        return GeometryFactory.CreateMultiPolygon([GeometryFactory.CreatePolygon(shell)]);
    }

    private static Guid Id(string value) => Guid.Parse(value);

    private sealed record PlaceSeed(
        Guid Id,
        Guid NeighborhoodId,
        Guid CategoryId,
        string Name,
        string Address,
        Point Location);
}
