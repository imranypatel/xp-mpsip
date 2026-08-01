

# Run Kestrel Dev
Powershell:
> $env:ASPNETCORE_ENVIRONMENT = "Development"
> $env:ConnectionStrings__DefaultConnection = "Data Source=167.86.125.245,1434;Initial Catalog=MPSIP_DEV;User ID=sa;Password=oli@biek2025;TrustServerCertificate=True"
> dotnet run --project src/MPSIP.Web --launch-profile http