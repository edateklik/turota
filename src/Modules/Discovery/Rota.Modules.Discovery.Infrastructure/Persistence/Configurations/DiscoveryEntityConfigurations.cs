using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Rota.Modules.Discovery.Domain.Entities;

namespace Rota.Modules.Discovery.Infrastructure.Persistence.Configurations;

internal sealed class CityConfiguration : IEntityTypeConfiguration<City>
{
    public void Configure(EntityTypeBuilder<City> builder)
    {
        builder.ToTable("cities");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.Name).HasColumnName("name").HasMaxLength(120).IsRequired();
        builder.Property(x => x.CountryCode).HasColumnName("country_code").HasMaxLength(2).IsFixedLength().IsRequired();
        builder.HasIndex(x => new { x.CountryCode, x.Name }).IsUnique();
    }
}

internal sealed class NeighborhoodConfiguration : IEntityTypeConfiguration<Neighborhood>
{
    public void Configure(EntityTypeBuilder<Neighborhood> builder)
    {
        builder.ToTable("neighborhoods");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.CityId).HasColumnName("city_id");
        builder.Property(x => x.Name).HasColumnName("name").HasMaxLength(160).IsRequired();
        builder.Property(x => x.Boundary).HasColumnName("boundary").HasColumnType("geometry(MultiPolygon,4326)").IsRequired();
        builder.HasOne(x => x.City).WithMany(x => x.Neighborhoods).HasForeignKey(x => x.CityId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => new { x.CityId, x.Name }).IsUnique();
        builder.HasIndex(x => x.Boundary).HasMethod("gist").HasDatabaseName("ix_neighborhoods_boundary_gist");
    }
}

internal sealed class PlaceConfiguration : IEntityTypeConfiguration<Place>
{
    public void Configure(EntityTypeBuilder<Place> builder)
    {
        builder.ToTable("places");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.NeighborhoodId).HasColumnName("neighborhood_id");
        builder.Property(x => x.CategoryId).HasColumnName("category_id");
        builder.Property(x => x.Name).HasColumnName("name").HasMaxLength(180).IsRequired();
        builder.Property(x => x.Address).HasColumnName("address").HasMaxLength(300).IsRequired();
        builder.Property(x => x.Location).HasColumnName("location").HasColumnType("geometry(Point,4326)").IsRequired();
        builder.HasOne(x => x.Neighborhood).WithMany(x => x.Places).HasForeignKey(x => x.NeighborhoodId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.Category).WithMany(x => x.Places).HasForeignKey(x => x.CategoryId).OnDelete(DeleteBehavior.Restrict);
        builder.HasIndex(x => x.Location).HasMethod("gist").HasDatabaseName("ix_places_location_gist");
        builder.HasIndex(x => new { x.NeighborhoodId, x.CategoryId });
        builder.HasMany(x => x.Tags).WithMany(x => x.Places).UsingEntity<Dictionary<string, object>>(
            "PlaceTag",
            right => right.HasOne<Tag>().WithMany().HasForeignKey("tag_id").OnDelete(DeleteBehavior.Cascade),
            left => left.HasOne<Place>().WithMany().HasForeignKey("place_id").OnDelete(DeleteBehavior.Cascade),
            join =>
            {
                join.ToTable("place_tags");
                join.HasKey("place_id", "tag_id");
                join.HasIndex("tag_id");
            });
    }
}

internal sealed class CategoryConfiguration : IEntityTypeConfiguration<Category>
{
    public void Configure(EntityTypeBuilder<Category> builder)
    {
        builder.ToTable("categories");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.Name).HasColumnName("name").HasMaxLength(100).IsRequired();
        builder.Property(x => x.Slug).HasColumnName("slug").HasMaxLength(100).IsRequired();
        builder.HasIndex(x => x.Slug).IsUnique();
    }
}

internal sealed class TagConfiguration : IEntityTypeConfiguration<Tag>
{
    public void Configure(EntityTypeBuilder<Tag> builder)
    {
        builder.ToTable("tags");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
        builder.Property(x => x.Name).HasColumnName("name").HasMaxLength(100).IsRequired();
        builder.Property(x => x.Slug).HasColumnName("slug").HasMaxLength(100).IsRequired();
        builder.HasIndex(x => x.Slug).IsUnique();
    }
}

internal sealed class PlaceFeatureVectorConfiguration : IEntityTypeConfiguration<PlaceFeatureVector>
{
    public void Configure(EntityTypeBuilder<PlaceFeatureVector> builder)
    {
        builder.ToTable("place_feature_vectors");
        builder.HasKey(x => x.PlaceId);
        builder.Property(x => x.PlaceId).HasColumnName("place_id").ValueGeneratedNever();
        builder.Property(x => x.Version).HasColumnName("version");
        builder.Property(x => x.Values).HasColumnName("values").HasColumnType("real[]").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at");
        builder.HasOne(x => x.Place).WithOne(x => x.FeatureVector).HasForeignKey<PlaceFeatureVector>(x => x.PlaceId).OnDelete(DeleteBehavior.Cascade);
        builder.HasIndex(x => x.Version);
    }
}
