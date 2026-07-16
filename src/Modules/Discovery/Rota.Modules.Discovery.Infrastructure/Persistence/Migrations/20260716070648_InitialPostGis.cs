using System;
using Microsoft.EntityFrameworkCore.Migrations;
using NetTopologySuite.Geometries;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Rota.Modules.Discovery.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class InitialPostGis : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "discovery");

            migrationBuilder.AlterDatabase()
                .Annotation("Npgsql:PostgresExtension:postgis", ",,");

            migrationBuilder.CreateTable(
                name: "categories",
                schema: "discovery",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    slug = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_categories", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "cities",
                schema: "discovery",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(120)", maxLength: 120, nullable: false),
                    country_code = table.Column<string>(type: "character(2)", fixedLength: true, maxLength: 2, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_cities", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "tags",
                schema: "discovery",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    slug = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tags", x => x.id);
                });

            migrationBuilder.CreateTable(
                name: "neighborhoods",
                schema: "discovery",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    city_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(160)", maxLength: 160, nullable: false),
                    boundary = table.Column<MultiPolygon>(type: "geometry(MultiPolygon,4326)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_neighborhoods", x => x.id);
                    table.ForeignKey(
                        name: "FK_neighborhoods_cities_city_id",
                        column: x => x.city_id,
                        principalSchema: "discovery",
                        principalTable: "cities",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "places",
                schema: "discovery",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    neighborhood_id = table.Column<Guid>(type: "uuid", nullable: false),
                    category_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "character varying(180)", maxLength: 180, nullable: false),
                    address = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
                    location = table.Column<Point>(type: "geometry(Point,4326)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_places", x => x.id);
                    table.ForeignKey(
                        name: "FK_places_categories_category_id",
                        column: x => x.category_id,
                        principalSchema: "discovery",
                        principalTable: "categories",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_places_neighborhoods_neighborhood_id",
                        column: x => x.neighborhood_id,
                        principalSchema: "discovery",
                        principalTable: "neighborhoods",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "place_tags",
                schema: "discovery",
                columns: table => new
                {
                    place_id = table.Column<Guid>(type: "uuid", nullable: false),
                    tag_id = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_place_tags", x => new { x.place_id, x.tag_id });
                    table.ForeignKey(
                        name: "FK_place_tags_places_place_id",
                        column: x => x.place_id,
                        principalSchema: "discovery",
                        principalTable: "places",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_place_tags_tags_tag_id",
                        column: x => x.tag_id,
                        principalSchema: "discovery",
                        principalTable: "tags",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                schema: "discovery",
                table: "categories",
                columns: new[] { "id", "name", "slug" },
                values: new object[,]
                {
                    { new Guid("30000000-0000-0000-0000-000000000001"), "Kafe", "kafe" },
                    { new Guid("30000000-0000-0000-0000-000000000002"), "Restoran", "restoran" },
                    { new Guid("30000000-0000-0000-0000-000000000003"), "Müze", "muze" },
                    { new Guid("30000000-0000-0000-0000-000000000004"), "Park", "park" },
                    { new Guid("30000000-0000-0000-0000-000000000005"), "Sanat", "sanat" },
                    { new Guid("30000000-0000-0000-0000-000000000006"), "Alışveriş", "alisveris" }
                });

            migrationBuilder.InsertData(
                schema: "discovery",
                table: "cities",
                columns: new[] { "id", "country_code", "name" },
                values: new object[] { new Guid("10000000-0000-0000-0000-000000000001"), "TR", "İstanbul" });

            migrationBuilder.InsertData(
                schema: "discovery",
                table: "tags",
                columns: new[] { "id", "name", "slug" },
                values: new object[,]
                {
                    { new Guid("40000000-0000-0000-0000-000000000001"), "Aile Dostu", "aile-dostu" },
                    { new Guid("40000000-0000-0000-0000-000000000002"), "Bütçe Dostu", "butce-dostu" },
                    { new Guid("40000000-0000-0000-0000-000000000003"), "Manzaralı", "manzarali" },
                    { new Guid("40000000-0000-0000-0000-000000000004"), "Tarihi", "tarihi" },
                    { new Guid("40000000-0000-0000-0000-000000000005"), "Vegan Seçenekli", "vegan-secenekli" },
                    { new Guid("40000000-0000-0000-0000-000000000006"), "Gece Açık", "gece-acik" },
                    { new Guid("40000000-0000-0000-0000-000000000007"), "Evcil Hayvan Dostu", "evcil-hayvan-dostu" },
                    { new Guid("40000000-0000-0000-0000-000000000008"), "Erişilebilir", "erisilebilir" }
                });

            migrationBuilder.InsertData(
                schema: "discovery",
                table: "neighborhoods",
                columns: new[] { "id", "boundary", "city_id", "name" },
                values: new object[,]
                {
                    { new Guid("20000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.MultiPolygon)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;MULTIPOLYGON (((29.02 40.978, 29.035 40.978, 29.035 40.992, 29.02 40.992, 29.02 40.978)))"), new Guid("10000000-0000-0000-0000-000000000001"), "Caferağa" },
                    { new Guid("20000000-0000-0000-0000-000000000002"), (NetTopologySuite.Geometries.MultiPolygon)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;MULTIPOLYGON (((29 41.035, 29.018 41.035, 29.018 41.052, 29 41.052, 29 41.035)))"), new Guid("10000000-0000-0000-0000-000000000001"), "Beşiktaş" },
                    { new Guid("20000000-0000-0000-0000-000000000003"), (NetTopologySuite.Geometries.MultiPolygon)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;MULTIPOLYGON (((28.968 41.018, 28.99 41.018, 28.99 41.03, 28.968 41.03, 28.968 41.018)))"), new Guid("10000000-0000-0000-0000-000000000001"), "Karaköy" }
                });

            migrationBuilder.InsertData(
                schema: "discovery",
                table: "places",
                columns: new[] { "id", "address", "category_id", "location", "name", "neighborhood_id" },
                values: new object[,]
                {
                    { new Guid("50000000-0000-0000-0000-000000000001"), "Moda Cd., Kadıköy", new Guid("30000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0257 40.9848)"), "Moda Kahve Noktası", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000002"), "Sakızgülü Sk., Kadıköy", new Guid("30000000-0000-0000-0000-000000000002"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0272 40.9871)"), "Caferağa Sofrası", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000003"), "Moda Sahili, Kadıköy", new Guid("30000000-0000-0000-0000-000000000004"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0231 40.981)"), "Moda Sahil Parkı", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000004"), "Neşe Sk., Kadıköy", new Guid("30000000-0000-0000-0000-000000000005"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0298 40.988)"), "Kadıköy Sanat Atölyesi", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000005"), "Moda Cd., Kadıköy", new Guid("30000000-0000-0000-0000-000000000006"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0264 40.9857)"), "Moda Tasarım Pazarı", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000006"), "Bahariye Cd., Kadıköy", new Guid("30000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.031 40.9901)"), "Bahariye Kitap Kafe", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000007"), "Rıhtım Yolu, Kadıköy", new Guid("30000000-0000-0000-0000-000000000002"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0218 40.986)"), "Sahil Lokantası", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000008"), "Dr. Esat Işık Cd., Kadıköy", new Guid("30000000-0000-0000-0000-000000000003"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0286 40.9832)"), "Mahalle Kültür Evi", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000009"), "Halil Ethem Sk., Kadıköy", new Guid("30000000-0000-0000-0000-000000000005"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0302 40.985)"), "Moda Sahnesi", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000010"), "Moda Burnu, Kadıköy", new Guid("30000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0222 40.9799)"), "Günbatımı Kahvesi", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000011"), "Şair Nefi Sk., Kadıköy", new Guid("30000000-0000-0000-0000-000000000006"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0321 40.9878)"), "Caferağa Plakçısı", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000012"), "Leylek Sk., Kadıköy", new Guid("30000000-0000-0000-0000-000000000002"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0248 40.989)"), "Moda Vegan Mutfağı", new Guid("20000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000013"), "Köyiçi Cd., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0058 41.0433)"), "Çarşı Kahve Evi", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000014"), "Şehit Asım Cd., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000002"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0069 41.0445)"), "Beşiktaş Esnaf Lokantası", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000015"), "Dolmabahçe Cd., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000003"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0051 41.0417)"), "Deniz Müzesi Çevresi", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000016"), "Abbasağa, Beşiktaş", new Guid("30000000-0000-0000-0000-000000000004"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0098 41.048)"), "Abbasağa Dinlenme Alanı", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000017"), "Süleyman Seba Cd., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000005"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0038 41.041)"), "Akaretler Galeri", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000018"), "Ortabahçe Cd., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000006"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0078 41.0451)"), "Çarşı Tasarım Dükkanı", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000019"), "Ihlamurdere Cd., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0118 41.0466)"), "Ihlamur Bahçe Kafe", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000020"), "İskele Cd., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000002"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0044 41.0428)"), "Boğaz Balık Mutfağı", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000021"), "Barbaros Blv., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000005"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0088 41.042)"), "Beşiktaş Performans Alanı", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000022"), "Palanga Cd., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000004"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0147 41.0495)"), "Yıldız Yürüyüş Noktası", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000023"), "Beşiktaş İskele, Beşiktaş", new Guid("30000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.003 41.0438)"), "Vapur İskelesi Kahvesi", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000024"), "Nüzhetiye Cd., Beşiktaş", new Guid("30000000-0000-0000-0000-000000000006"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (29.0128 41.0456)"), "Yerel Üretici Pazarı", new Guid("20000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000025"), "Kemankeş Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.9784 41.0221)"), "Karaköy Kavurma Evi", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000026"), "Rıhtım Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000002"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.976 41.0212)"), "Liman Mutfağı", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000027"), "Tersane Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000003"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.9735 41.024)"), "Tarihi Liman Sergisi", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000028"), "Boğazkesen Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000005"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.9822 41.0261)"), "Tophane Sanat Alanı", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000029"), "Mumhane Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000006"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.9798 41.0235)"), "Karaköy Tasarım Hanı", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000030"), "Yüksek Kaldırım Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.9828 41.025)"), "Galata Altı Kahvesi", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000031"), "Perşembe Pazarı Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000002"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.9714 41.0247)"), "Perşembe Pazarı Lokantası", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000032"), "Necatibey Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000005"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.9752 41.0228)"), "Rıhtım Fotoğraf Galerisi", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000033"), "Bankalar Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000006"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.981 41.0244)"), "Yeraltı Plak Pazarı", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000034"), "Kılıç Ali Paşa Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000001"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.9851 41.023)"), "Gün Doğumu Fırını", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000035"), "Voyvoda Cd., Beyoğlu", new Guid("30000000-0000-0000-0000-000000000003"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.98 41.0258)"), "Karaköy Kent Hafızası", new Guid("20000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000036"), "Karaköy Rıhtımı, Beyoğlu", new Guid("30000000-0000-0000-0000-000000000004"), (NetTopologySuite.Geometries.Point)new NetTopologySuite.IO.WKTReader().Read("SRID=4326;POINT (28.973 41.02)"), "Liman Seyir Terası", new Guid("20000000-0000-0000-0000-000000000003") }
                });

            migrationBuilder.InsertData(
                schema: "discovery",
                table: "place_tags",
                columns: new[] { "place_id", "tag_id" },
                values: new object[,]
                {
                    { new Guid("50000000-0000-0000-0000-000000000001"), new Guid("40000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000001"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000002"), new Guid("40000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000002"), new Guid("40000000-0000-0000-0000-000000000005") },
                    { new Guid("50000000-0000-0000-0000-000000000003"), new Guid("40000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000003"), new Guid("40000000-0000-0000-0000-000000000006") },
                    { new Guid("50000000-0000-0000-0000-000000000004"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000004"), new Guid("40000000-0000-0000-0000-000000000007") },
                    { new Guid("50000000-0000-0000-0000-000000000005"), new Guid("40000000-0000-0000-0000-000000000005") },
                    { new Guid("50000000-0000-0000-0000-000000000005"), new Guid("40000000-0000-0000-0000-000000000008") },
                    { new Guid("50000000-0000-0000-0000-000000000006"), new Guid("40000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000006"), new Guid("40000000-0000-0000-0000-000000000006") },
                    { new Guid("50000000-0000-0000-0000-000000000007"), new Guid("40000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000007"), new Guid("40000000-0000-0000-0000-000000000007") },
                    { new Guid("50000000-0000-0000-0000-000000000008"), new Guid("40000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000008"), new Guid("40000000-0000-0000-0000-000000000008") },
                    { new Guid("50000000-0000-0000-0000-000000000009"), new Guid("40000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000009"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000010"), new Guid("40000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000010"), new Guid("40000000-0000-0000-0000-000000000005") },
                    { new Guid("50000000-0000-0000-0000-000000000011"), new Guid("40000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000011"), new Guid("40000000-0000-0000-0000-000000000006") },
                    { new Guid("50000000-0000-0000-0000-000000000012"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000012"), new Guid("40000000-0000-0000-0000-000000000007") },
                    { new Guid("50000000-0000-0000-0000-000000000013"), new Guid("40000000-0000-0000-0000-000000000005") },
                    { new Guid("50000000-0000-0000-0000-000000000013"), new Guid("40000000-0000-0000-0000-000000000008") },
                    { new Guid("50000000-0000-0000-0000-000000000014"), new Guid("40000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000014"), new Guid("40000000-0000-0000-0000-000000000006") },
                    { new Guid("50000000-0000-0000-0000-000000000015"), new Guid("40000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000015"), new Guid("40000000-0000-0000-0000-000000000007") },
                    { new Guid("50000000-0000-0000-0000-000000000016"), new Guid("40000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000016"), new Guid("40000000-0000-0000-0000-000000000008") },
                    { new Guid("50000000-0000-0000-0000-000000000017"), new Guid("40000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000017"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000018"), new Guid("40000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000018"), new Guid("40000000-0000-0000-0000-000000000005") },
                    { new Guid("50000000-0000-0000-0000-000000000019"), new Guid("40000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000019"), new Guid("40000000-0000-0000-0000-000000000006") },
                    { new Guid("50000000-0000-0000-0000-000000000020"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000020"), new Guid("40000000-0000-0000-0000-000000000007") },
                    { new Guid("50000000-0000-0000-0000-000000000021"), new Guid("40000000-0000-0000-0000-000000000005") },
                    { new Guid("50000000-0000-0000-0000-000000000021"), new Guid("40000000-0000-0000-0000-000000000008") },
                    { new Guid("50000000-0000-0000-0000-000000000022"), new Guid("40000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000022"), new Guid("40000000-0000-0000-0000-000000000006") },
                    { new Guid("50000000-0000-0000-0000-000000000023"), new Guid("40000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000023"), new Guid("40000000-0000-0000-0000-000000000007") },
                    { new Guid("50000000-0000-0000-0000-000000000024"), new Guid("40000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000024"), new Guid("40000000-0000-0000-0000-000000000008") },
                    { new Guid("50000000-0000-0000-0000-000000000025"), new Guid("40000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000025"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000026"), new Guid("40000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000026"), new Guid("40000000-0000-0000-0000-000000000005") },
                    { new Guid("50000000-0000-0000-0000-000000000027"), new Guid("40000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000027"), new Guid("40000000-0000-0000-0000-000000000006") },
                    { new Guid("50000000-0000-0000-0000-000000000028"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000028"), new Guid("40000000-0000-0000-0000-000000000007") },
                    { new Guid("50000000-0000-0000-0000-000000000029"), new Guid("40000000-0000-0000-0000-000000000005") },
                    { new Guid("50000000-0000-0000-0000-000000000029"), new Guid("40000000-0000-0000-0000-000000000008") },
                    { new Guid("50000000-0000-0000-0000-000000000030"), new Guid("40000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000030"), new Guid("40000000-0000-0000-0000-000000000006") },
                    { new Guid("50000000-0000-0000-0000-000000000031"), new Guid("40000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000031"), new Guid("40000000-0000-0000-0000-000000000007") },
                    { new Guid("50000000-0000-0000-0000-000000000032"), new Guid("40000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000032"), new Guid("40000000-0000-0000-0000-000000000008") },
                    { new Guid("50000000-0000-0000-0000-000000000033"), new Guid("40000000-0000-0000-0000-000000000001") },
                    { new Guid("50000000-0000-0000-0000-000000000033"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000034"), new Guid("40000000-0000-0000-0000-000000000002") },
                    { new Guid("50000000-0000-0000-0000-000000000034"), new Guid("40000000-0000-0000-0000-000000000005") },
                    { new Guid("50000000-0000-0000-0000-000000000035"), new Guid("40000000-0000-0000-0000-000000000003") },
                    { new Guid("50000000-0000-0000-0000-000000000035"), new Guid("40000000-0000-0000-0000-000000000006") },
                    { new Guid("50000000-0000-0000-0000-000000000036"), new Guid("40000000-0000-0000-0000-000000000004") },
                    { new Guid("50000000-0000-0000-0000-000000000036"), new Guid("40000000-0000-0000-0000-000000000007") }
                });

            migrationBuilder.CreateIndex(
                name: "IX_categories_slug",
                schema: "discovery",
                table: "categories",
                column: "slug",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_cities_country_code_name",
                schema: "discovery",
                table: "cities",
                columns: new[] { "country_code", "name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_neighborhoods_city_id_name",
                schema: "discovery",
                table: "neighborhoods",
                columns: new[] { "city_id", "name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "ix_neighborhoods_boundary_gist",
                schema: "discovery",
                table: "neighborhoods",
                column: "boundary")
                .Annotation("Npgsql:IndexMethod", "gist");

            migrationBuilder.CreateIndex(
                name: "IX_place_tags_tag_id",
                schema: "discovery",
                table: "place_tags",
                column: "tag_id");

            migrationBuilder.CreateIndex(
                name: "IX_places_category_id",
                schema: "discovery",
                table: "places",
                column: "category_id");

            migrationBuilder.CreateIndex(
                name: "IX_places_neighborhood_id_category_id",
                schema: "discovery",
                table: "places",
                columns: new[] { "neighborhood_id", "category_id" });

            migrationBuilder.CreateIndex(
                name: "ix_places_location_gist",
                schema: "discovery",
                table: "places",
                column: "location")
                .Annotation("Npgsql:IndexMethod", "gist");

            migrationBuilder.CreateIndex(
                name: "IX_tags_slug",
                schema: "discovery",
                table: "tags",
                column: "slug",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "place_tags",
                schema: "discovery");

            migrationBuilder.DropTable(
                name: "places",
                schema: "discovery");

            migrationBuilder.DropTable(
                name: "tags",
                schema: "discovery");

            migrationBuilder.DropTable(
                name: "categories",
                schema: "discovery");

            migrationBuilder.DropTable(
                name: "neighborhoods",
                schema: "discovery");

            migrationBuilder.DropTable(
                name: "cities",
                schema: "discovery");
        }
    }
}
