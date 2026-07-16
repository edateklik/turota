using Microsoft.EntityFrameworkCore;
using Rota.Modules.Identity.Domain.Entities;

namespace Rota.Modules.Identity.Infrastructure.Persistence;

public sealed class IdentityDbContext(DbContextOptions<IdentityDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<TasteProfile> TasteProfiles => Set<TasteProfile>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.HasDefaultSchema("identity");

        modelBuilder.Entity<User>(builder =>
        {
            builder.ToTable("users");
            builder.HasKey(x => x.Id);
            builder.Property(x => x.Id).HasColumnName("id").ValueGeneratedNever();
            builder.Property(x => x.Email).HasColumnName("email").HasMaxLength(254).IsRequired();
            builder.Property(x => x.NormalizedEmail).HasColumnName("normalized_email").HasMaxLength(254).IsRequired();
            builder.Property(x => x.PasswordHash).HasColumnName("password_hash").HasMaxLength(500).IsRequired();
            builder.Property(x => x.FirstName).HasColumnName("first_name").HasMaxLength(80).IsRequired();
            builder.Property(x => x.LastName).HasColumnName("last_name").HasMaxLength(80).IsRequired();
            builder.Property(x => x.Role).HasColumnName("role").HasConversion<string>().HasMaxLength(20).IsRequired();
            builder.Property(x => x.IsActive).HasColumnName("is_active");
            builder.Property(x => x.CreatedAt).HasColumnName("created_at");
            builder.HasIndex(x => x.NormalizedEmail).IsUnique().HasDatabaseName("ux_users_normalized_email");
        });

        modelBuilder.Entity<TasteProfile>(builder =>
        {
            builder.ToTable("taste_profiles");
            builder.HasKey(x => x.UserId);
            builder.Property(x => x.UserId).HasColumnName("user_id").ValueGeneratedNever();
            builder.Property(x => x.PreferredCategoryIds).HasColumnName("preferred_category_ids").HasColumnType("uuid[]").IsRequired();
            builder.Property(x => x.PreferredTagIds).HasColumnName("preferred_tag_ids").HasColumnType("uuid[]").IsRequired();
            builder.Property(x => x.DietaryPreferences).HasColumnName("dietary_preferences").HasColumnType("text[]").IsRequired();
            builder.Property(x => x.BudgetLevel).HasColumnName("budget_level").HasConversion<string>().HasMaxLength(20).IsRequired();
            builder.Property(x => x.TravelPace).HasColumnName("travel_pace").HasConversion<string>().HasMaxLength(20).IsRequired();
            builder.Property(x => x.UpdatedAt).HasColumnName("updated_at");
            builder.HasOne(x => x.User).WithOne(x => x.TasteProfile).HasForeignKey<TasteProfile>(x => x.UserId).OnDelete(DeleteBehavior.Cascade);
        });
    }
}
