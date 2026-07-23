using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Diagnostics;
using System.Text.Json;
using Xunit;

namespace Rota.Api.IntegrationTests;

public sealed class ApiIntegrationTests(RotaApiFactory factory) : IClassFixture<RotaApiFactory>
{
    private readonly RotaApiFactory _factory = factory;
    private readonly HttpClient _client = factory.CreateClient();

    [Fact]
    public async Task Liveness_WithValidCorrelationId_ReturnsHealthAndEchoesCorrelationId()
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, "/health/live");
        request.Headers.Add("X-Correlation-ID", "integration-health-123");
        using var response = await _client.SendAsync(request);
        var payload = await response.Content.ReadFromJsonAsync<JsonElement>();

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("Healthy", payload.GetProperty("status").GetString());
        Assert.Equal("integration-health-123", response.Headers.GetValues("X-Correlation-ID").Single());
    }

    [Fact]
    public async Task DiscoveryDataQuality_SeededPostGis_IsHealthy()
    {
        using var response = await _client.GetAsync("/api/discovery/data-quality");
        using var payload = JsonDocument.Parse(await response.Content.ReadAsStringAsync());

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.True(payload.RootElement.GetProperty("isHealthy").GetBoolean());
        Assert.Equal(3, payload.RootElement.GetProperty("neighborhoodCount").GetInt32());
        Assert.Equal(36, payload.RootElement.GetProperty("placeCount").GetInt32());
        Assert.Equal(0, payload.RootElement.GetProperty("outsideNeighborhoodCount").GetInt32());
    }

    [Fact]
    public async Task NearestPlaces_RealPostGis_ReturnsDistanceOrderedResults()
    {
        using var response = await _client.GetAsync(
            "/api/discovery/places/nearest?longitude=29.026&latitude=40.985&limit=5");
        var payload = await response.Content.ReadFromJsonAsync<JsonElement>();

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal(5, payload.GetArrayLength());
        var distances = payload.EnumerateArray()
            .Select(item => item.GetProperty("distanceMeters").GetDouble())
            .ToArray();
        Assert.Equal(distances.OrderBy(distance => distance), distances);
    }

    [Fact]
    public async Task AdminEndpoint_AnonymousUser_IsUnauthorized()
    {
        using var response = await _client.GetAsync("/api/admin/places");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        Assert.Equal("application/problem+json", response.Content.Headers.ContentType?.MediaType);
    }

    [Fact]
    public async Task AdministrationDashboardAndSimulation_AdminUser_ReturnsReadOnlyResults()
    {
        var email = $"admin-{Guid.NewGuid():N}@example.com";
        using var registerResponse = await _client.PostAsJsonAsync("/api/identity/register", new
        {
            email,
            password = "Rota123!",
            firstName = "Admin",
            lastName = "Integration"
        });
        Assert.Equal(HttpStatusCode.Created, registerResponse.StatusCode);
        await _factory.PromoteToAdminAsync(email);

        using var loginResponse = await _client.PostAsJsonAsync("/api/identity/login", new
        {
            email,
            password = "Rota123!"
        });
        var login = await loginResponse.Content.ReadFromJsonAsync<JsonElement>();
        var adminToken = login.GetProperty("accessToken").GetString()!;
        var adminUserId = login.GetProperty("user").GetProperty("id").GetGuid();

        using var usersResponse = await SendAuthorizedAsync(HttpMethod.Get, "/api/admin/users?page=1&pageSize=20", adminToken);
        var users = await usersResponse.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(HttpStatusCode.OK, usersResponse.StatusCode);
        Assert.True(users.GetProperty("totalCount").GetInt32() >= 1);

        using var selfDemotionRequest = new HttpRequestMessage(
            HttpMethod.Put,
            $"/api/admin/users/{adminUserId}/access")
        {
            Content = JsonContent.Create(new { role = "User", isActive = false })
        };
        selfDemotionRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", adminToken);
        using var selfDemotionResponse = await _client.SendAsync(selfDemotionRequest);
        Assert.Equal(HttpStatusCode.Conflict, selfDemotionResponse.StatusCode);

        using var dashboardResponse = await SendAuthorizedAsync(HttpMethod.Get, "/api/admin/dashboard", adminToken);
        var dashboard = await dashboardResponse.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(HttpStatusCode.OK, dashboardResponse.StatusCode);
        Assert.True(dashboard.GetProperty("userCount").GetInt64() >= 1);
        Assert.Equal(3, dashboard.GetProperty("neighborhoodCount").GetInt64());
        Assert.Equal(36, dashboard.GetProperty("placeCount").GetInt64());

        var runCountBefore = await _factory.GetRecommendationRunCountAsync();
        using var simulationRequest = new HttpRequestMessage(HttpMethod.Post, "/api/admin/simulations/recommendation")
        {
            Content = JsonContent.Create(new
            {
                tripDate = DateOnly.FromDateTime(DateTime.UtcNow).AddDays(1),
                startLongitude = 29.026,
                startLatitude = 40.985,
                availableMinutes = 240,
                preferredCategoryIds = new[] { "30000000-0000-0000-0000-000000000001" },
                preferredTagIds = Array.Empty<string>(),
                dietaryPreferences = Array.Empty<string>(),
                budgetLevel = "Moderate",
                travelPace = "Balanced"
            })
        };
        simulationRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", adminToken);
        using var simulationResponse = await _client.SendAsync(simulationRequest);
        var simulation = await simulationResponse.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(HttpStatusCode.OK, simulationResponse.StatusCode);
        Assert.False(simulation.GetProperty("persisted").GetBoolean());
        Assert.Equal("integration-test-v1", simulation.GetProperty("modelVersion").GetString());
        Assert.NotEmpty(simulation.GetProperty("places").EnumerateArray());
        Assert.Equal(runCountBefore, await _factory.GetRecommendationRunCountAsync());
    }

    [Fact]
    public async Task IdentityAndRecommendation_AuthenticatedUser_CompletesContract()
    {
        var email = $"integration-{Guid.NewGuid():N}@example.com";
        using var registerResponse = await _client.PostAsJsonAsync("/api/identity/register", new
        {
            email,
            password = "Rota123!",
            firstName = "Integration",
            lastName = "Test"
        });
        var registration = await registerResponse.Content.ReadFromJsonAsync<JsonElement>();
        var accessToken = registration.GetProperty("accessToken").GetString();

        Assert.Equal(HttpStatusCode.Created, registerResponse.StatusCode);
        Assert.False(string.IsNullOrWhiteSpace(accessToken));

        using var request = new HttpRequestMessage(HttpMethod.Post, "/api/recommendations/generate")
        {
            Content = JsonContent.Create(new
            {
                tripDate = DateOnly.FromDateTime(DateTime.UtcNow).AddDays(1),
                availableMinutes = 480
            })
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        var stopwatch = Stopwatch.StartNew();
        using var recommendationResponse = await _client.SendAsync(request);
        stopwatch.Stop();
        var accepted = await recommendationResponse.Content.ReadFromJsonAsync<JsonElement>();

        Assert.Equal(HttpStatusCode.Accepted, recommendationResponse.StatusCode);
        Assert.True(stopwatch.Elapsed < TimeSpan.FromSeconds(2));
        Assert.Equal("Pending", accepted.GetProperty("status").GetString());

        var runId = accepted.GetProperty("runId").GetGuid();
        var run = await WaitForTerminalRunAsync(runId, accessToken!);
        Assert.Equal("Completed", run.GetProperty("status").GetString());
        var result = run.GetProperty("result");
        Assert.Equal("integration-test-v1", result.GetProperty("modelVersion").GetString());
        Assert.Equal("Caferağa", result.GetProperty("region").GetProperty("name").GetString());
        var outbox = await WaitForProcessedOutboxAsync(runId);
        Assert.Equal("recommendation.completed.v1", outbox.Type);
        Assert.Equal(2, outbox.AttemptCount);

        using var tripsResponse = await SendAuthorizedAsync(HttpMethod.Get, "/api/trips?page=1&pageSize=20", accessToken!);
        var trips = await tripsResponse.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(HttpStatusCode.OK, tripsResponse.StatusCode);
        Assert.Equal(1, trips.GetProperty("totalCount").GetInt32());
        var tripId = trips.GetProperty("items")[0].GetProperty("id").GetGuid();

        using var tripResponse = await SendAuthorizedAsync(HttpMethod.Get, $"/api/trips/{tripId}", accessToken!);
        var trip = await tripResponse.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(runId, trip.GetProperty("sourceRecommendationRunId").GetGuid());
        Assert.Equal("Planned", trip.GetProperty("status").GetString());
        Assert.Equal(29.0257, trip.GetProperty("stops")[0].GetProperty("longitude").GetDouble(), 4);
        Assert.Equal(40.9848, trip.GetProperty("stops")[0].GetProperty("latitude").GetDouble(), 4);

        using var cancelResponse = await SendAuthorizedAsync(HttpMethod.Post, $"/api/trips/{tripId}/cancel", accessToken!);
        var cancelled = await cancelResponse.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(HttpStatusCode.OK, cancelResponse.StatusCode);
        Assert.Equal("Cancelled", cancelled.GetProperty("status").GetString());

        using var secondCancelResponse = await SendAuthorizedAsync(HttpMethod.Post, $"/api/trips/{tripId}/cancel", accessToken!);
        Assert.Equal(HttpStatusCode.Conflict, secondCancelResponse.StatusCode);
    }

    [Fact]
    public async Task RecommendationWorker_TransientFailure_RetriesAndPersistsFailedStatus()
    {
        var accessToken = await RegisterAndGetTokenAsync();
        using var request = new HttpRequestMessage(HttpMethod.Post, "/api/recommendations/generate")
        {
            Content = JsonContent.Create(new
            {
                tripDate = DateOnly.FromDateTime(DateTime.UtcNow).AddDays(1),
                availableMinutes = 63
            })
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        using var response = await _client.SendAsync(request);
        var accepted = await response.Content.ReadFromJsonAsync<JsonElement>();

        Assert.Equal(HttpStatusCode.Accepted, response.StatusCode);
        var run = await WaitForTerminalRunAsync(accepted.GetProperty("runId").GetGuid(), accessToken);
        Assert.Equal("Failed", run.GetProperty("status").GetString());
        Assert.Equal(3, run.GetProperty("attemptCount").GetInt32());
        Assert.Equal("AI_SERVICE_UNAVAILABLE", run.GetProperty("failureCode").GetString());
        Assert.Equal(JsonValueKind.Null, run.GetProperty("result").ValueKind);
        var outbox = await WaitForProcessedOutboxAsync(accepted.GetProperty("runId").GetGuid());
        Assert.Equal("recommendation.failed.v1", outbox.Type);
        Assert.Equal(2, outbox.AttemptCount);
    }

    [Fact]
    public async Task ProfilePhoto_UploadRestoreReplaceAndDelete_PersistsOnUserAccount()
    {
        using var unauthorized = new MultipartFormDataContent();
        unauthorized.Add(new ByteArrayContent(CreateJpeg()), "file", "profile.jpg");
        using var unauthorizedResponse = await _client.PutAsync(
            "/api/identity/me/profile-photo",
            unauthorized);
        Assert.Equal(HttpStatusCode.Unauthorized, unauthorizedResponse.StatusCode);

        var email = $"avatar-{Guid.NewGuid():N}@example.com";
        using var registerResponse = await _client.PostAsJsonAsync("/api/identity/register", new
        {
            email,
            password = "Rota123!",
            firstName = "Avatar",
            lastName = "Test"
        });
        var registration = await registerResponse.Content.ReadFromJsonAsync<JsonElement>();
        var token = registration.GetProperty("accessToken").GetString()!;

        using var oversized = CreatePhotoContent(
            new byte[(5 * 1024 * 1024) + 1],
            "image/jpeg",
            "large.jpg");
        using var oversizedRequest = new HttpRequestMessage(HttpMethod.Put, "/api/identity/me/profile-photo")
        {
            Content = oversized
        };
        oversizedRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        using var oversizedResponse = await _client.SendAsync(oversizedRequest);
        Assert.Equal(HttpStatusCode.BadRequest, oversizedResponse.StatusCode);

        using var wrongMime = CreatePhotoContent(CreateJpeg(), "text/plain", "fake.jpg");
        using var wrongMimeRequest = new HttpRequestMessage(HttpMethod.Put, "/api/identity/me/profile-photo")
        {
            Content = wrongMime
        };
        wrongMimeRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        using var wrongMimeResponse = await _client.SendAsync(wrongMimeRequest);
        Assert.Equal(HttpStatusCode.BadRequest, wrongMimeResponse.StatusCode);

        using var upload = CreatePhotoContent(CreateJpeg(), "image/jpeg", "profile.jpg");
        using var uploadRequest = new HttpRequestMessage(HttpMethod.Put, "/api/identity/me/profile-photo")
        {
            Content = upload
        };
        uploadRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        using var uploadResponse = await _client.SendAsync(uploadRequest);
        var uploaded = await uploadResponse.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(HttpStatusCode.OK, uploadResponse.StatusCode);
        var firstUrl = uploaded.GetProperty("profilePhotoUrl").GetString();
        Assert.False(string.IsNullOrWhiteSpace(firstUrl));

        using var currentUser = await SendAuthorizedAsync(HttpMethod.Get, "/api/identity/me", token);
        var currentUserJson = await currentUser.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(firstUrl, currentUserJson.GetProperty("profilePhotoUrl").GetString());

        using var loginResponse = await _client.PostAsJsonAsync("/api/identity/login", new
        {
            email,
            password = "Rota123!"
        });
        var login = await loginResponse.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(firstUrl, login.GetProperty("user").GetProperty("profilePhotoUrl").GetString());

        using var invalid = CreatePhotoContent("<svg/>"u8.ToArray(), "image/svg+xml", "bad.svg");
        using var invalidRequest = new HttpRequestMessage(HttpMethod.Put, "/api/identity/me/profile-photo")
        {
            Content = invalid
        };
        invalidRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        using var invalidResponse = await _client.SendAsync(invalidRequest);
        Assert.Equal(HttpStatusCode.BadRequest, invalidResponse.StatusCode);

        using var replacement = CreatePhotoContent(CreateJpeg(0x22), "image/jpeg", "replacement.jpg");
        using var replacementRequest = new HttpRequestMessage(HttpMethod.Put, "/api/identity/me/profile-photo")
        {
            Content = replacement
        };
        replacementRequest.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        using var replacementResponse = await _client.SendAsync(replacementRequest);
        var replaced = await replacementResponse.Content.ReadFromJsonAsync<JsonElement>();
        var secondUrl = replaced.GetProperty("profilePhotoUrl").GetString();
        Assert.NotEqual(firstUrl, secondUrl);
        using var oldFileResponse = await _client.GetAsync(firstUrl);
        Assert.Equal(HttpStatusCode.NotFound, oldFileResponse.StatusCode);

        using var deleteResponse = await SendAuthorizedAsync(
            HttpMethod.Delete,
            "/api/identity/me/profile-photo",
            token);
        Assert.Equal(HttpStatusCode.OK, deleteResponse.StatusCode);
        using var afterDelete = await SendAuthorizedAsync(HttpMethod.Get, "/api/identity/me", token);
        var afterDeleteJson = await afterDelete.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(JsonValueKind.Null, afterDeleteJson.GetProperty("profilePhotoUrl").ValueKind);
        using var deletedFileResponse = await _client.GetAsync(secondUrl);
        Assert.Equal(HttpStatusCode.NotFound, deletedFileResponse.StatusCode);
    }

    private static MultipartFormDataContent CreatePhotoContent(
        byte[] bytes,
        string contentType,
        string fileName)
    {
        var result = new MultipartFormDataContent();
        var file = new ByteArrayContent(bytes);
        file.Headers.ContentType = new MediaTypeHeaderValue(contentType);
        result.Add(file, "file", fileName);
        return result;
    }

    private static byte[] CreateJpeg(byte payload = 0x11) =>
    [
        0xFF, 0xD8,
        0xFF, 0xC0, 0x00, 0x05, 0x08, payload, payload,
        0xFF, 0xD9
    ];

    private async Task<string> RegisterAndGetTokenAsync()
    {
        using var response = await _client.PostAsJsonAsync("/api/identity/register", new
        {
            email = $"integration-{Guid.NewGuid():N}@example.com",
            password = "Rota123!",
            firstName = "Integration",
            lastName = "Retry"
        });
        var registration = await response.Content.ReadFromJsonAsync<JsonElement>();
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        return registration.GetProperty("accessToken").GetString()!;
    }

    private async Task<HttpResponseMessage> SendAuthorizedAsync(HttpMethod method, string path, string accessToken)
    {
        var request = new HttpRequestMessage(method, path);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        return await _client.SendAsync(request);
    }

    private async Task<JsonElement> WaitForTerminalRunAsync(Guid runId, string accessToken)
    {
        for (var attempt = 0; attempt < 50; attempt++)
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, $"/api/recommendations/{runId}");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            using var response = await _client.SendAsync(request);
            var run = await response.Content.ReadFromJsonAsync<JsonElement>();
            if (run.GetProperty("status").GetString() is "Completed" or "Failed") return run;
            await Task.Delay(100);
        }

        throw new TimeoutException("Recommendation job 5 saniye içinde terminal duruma geçmedi.");
    }

    private async Task<OutboxProbe> WaitForProcessedOutboxAsync(Guid runId)
    {
        for (var attempt = 0; attempt < 50; attempt++)
        {
            var message = await _factory.FindOutboxAsync(runId);
            if (message?.Status == "Processed")
            {
                Assert.NotNull(message.ProcessedAt);
                return message;
            }
            await Task.Delay(100);
        }

        throw new TimeoutException("Outbox mesajı 5 saniye içinde Processed durumuna geçmedi.");
    }
}
