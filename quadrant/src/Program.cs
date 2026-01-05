var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/api/feature", () => Results.Json(new
{
    colorCode = "#00FF00",
    softwareVersion = "v1.0.12"
}));

app.MapGet("/api/health", () => Results.Json(new
{
    healthy = true
}));

app.Run();
