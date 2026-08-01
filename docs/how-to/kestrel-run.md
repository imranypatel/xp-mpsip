# Running MPSIP Locally with Kestrel

Use this guide to run MPSIP on your local machine before deploying to IIS.
Kestrel is .NET's built-in web server — no IIS required.

---

## Prerequisites

| Requirement | Install / Check |
|-------------|----------------|
| .NET 10 SDK | [download](https://dotnet.microsoft.com/download/dotnet/10.0) · verify: `dotnet --version` |
| SQL Server LocalDB | Included in Visual Studio installer, or [download standalone](https://learn.microsoft.com/sql/database-engine/configure-windows/sql-server-express-localdb) · verify: `sqllocaldb info` |
| Git clone | Repo checked out at any path |

> **Not required:** IIS, IIS Express, or any web server install.

---

## Quick Start (One Command)

Open a PowerShell terminal in the repository root:

```powershell
.\scripts\run-dev.ps1
```

This will:
1. Verify the .NET SDK is installed
2. Start SQL Server LocalDB (idempotent — safe to run again)
3. Build the solution
4. Start Kestrel on `http://localhost:5093`
5. Open your default browser to the app

> **Default login** (dev seed data):  
> Email: `owner@mpsip.dev` · Password: `Dev@1234`

---

## Script Options

```powershell
# HTTP (default)
.\scripts\run-dev.ps1

# HTTPS (https://localhost:7098) — requires dev certificate
.\scripts\run-dev.ps1 -Https

# Skip the build step (faster restart after a build with no code changes)
.\scripts\run-dev.ps1 -NoBuild

# Don't open a browser window
.\scripts\run-dev.ps1 -NoBrowser

# Combine flags
.\scripts\run-dev.ps1 -Https -NoBuild -NoBrowser
```

---

## Manual Commands

If you prefer to run steps yourself:

```powershell
# 1 — Start LocalDB
sqllocaldb start MSSQLLocalDB

# 2 — Build
cd src
dotnet restore MPSIP.slnx
dotnet build MPSIP.slnx --no-restore

# 3a — Run on HTTP
$env:ASPNETCORE_ENVIRONMENT = "Development"
dotnet run --project MPSIP.Web --launch-profile http

# 3b — Run on HTTPS
dotnet run --project MPSIP.Web --launch-profile https
```

---

## HTTP vs HTTPS

| Profile | URL | Notes |
|---------|-----|-------|
| `http` | `http://localhost:5093` | No certificate needed — use for quick local testing |
| `https` | `https://localhost:7098` | Requires a trusted dev cert (see below) |

**Trust the dev certificate (first time only for HTTPS):**
```powershell
dotnet dev-certs https --trust
```
Accept the browser prompt to install the cert. Only needed once per machine.

---

## First-Run Notes

On first start, `DatabaseMigrator` runs automatically:
- Creates all tables (`V001` – `V010` migrations)
- Installs all 60+ stored procedures
- Seeds `OpportunityKinds` and the Manufacturing template
- Seeds dev user + demo project (Development environment only)

You'll see log lines like:
```
info: MPSIP.Infrastructure.Database.DatabaseMigrator[0]
      Applied migration V001__CreateSchemaVersion.sql
      ...
      Seed Seed_DevData.sql applied (dev-only).
```

Subsequent starts skip already-applied migrations (idempotent).

---

## Stop the App

Press **Ctrl+C** in the terminal where `dotnet run` is running.

---

## Troubleshooting

### Port already in use
```
System.IO.IOException: Failed to bind to address http://localhost:5093
```
Find and stop the occupying process:
```powershell
netstat -ano | findstr :5093
Stop-Process -Id <PID>
```

### LocalDB won't start
```powershell
sqllocaldb info MSSQLLocalDB   # check status
sqllocaldb delete MSSQLLocalDB # delete and recreate if corrupt
sqllocaldb create MSSQLLocalDB
sqllocaldb start MSSQLLocalDB
```

### HTTPS certificate not trusted
```powershell
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

### Connection string error on startup
Check `src/MPSIP.Web/appsettings.Development.json`:
```json
"ConnectionStrings": {
  "DefaultConnection": "Server=(localdb)\\mssqllocaldb;Database=MPSIP_DEV;Trusted_Connection=True;TrustServerCertificate=True;"
}
```
If using full SQL Server instead of LocalDB, update `Server=` accordingly.

### Build errors before running
Run the build separately to see full output:
```powershell
cd src
dotnet build MPSIP.slnx
```

---

## Ports Reference

| Port | Profile | Protocol |
|------|---------|----------|
| 5093 | `http` | HTTP |
| 7098 | `https` | HTTPS |

These are defined in `src/MPSIP.Web/Properties/launchSettings.json`.
