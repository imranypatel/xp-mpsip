# Running MPSIP on Kestrel with a Local SQL Server Instance

Use this guide when you have a locally installed SQL Server (Express, Developer, or full) and want to run MPSIP on Kestrel without LocalDB.

> **LocalDB instead?** See [kestrel-run.md](kestrel-run.md).

---

## Prerequisites

| Requirement | Install / Check |
|-------------|----------------|
| .NET 10 SDK | [download](https://dotnet.microsoft.com/download/dotnet/10.0) · `dotnet --version` |
| SQL Server (any edition) | [Express](https://www.microsoft.com/sql-server/sql-server-downloads) is free · verify: `sqlcmd -S .\SQLEXPRESS -E -Q "SELECT @@VERSION"` |
| `sqlcmd` **or** `Invoke-Sqlcmd` | `sqlcmd` ships with SQL Server tools · or `Install-Module SqlServer` for PowerShell |

### Find your SQL Server instance name

```powershell
# List all local SQL Server instances
Get-Service | Where-Object { $_.Name -like "MSSQL*" } | Select-Object Name, Status

# Or use sqlcmd to test connectivity
sqlcmd -S .\SQLEXPRESS -E -Q "SELECT @@SERVERNAME"
sqlcmd -S . -E -Q "SELECT @@SERVERNAME"   # default instance
```

Common instance names:

| Installed by | Instance name |
|--------------|--------------|
| SQL Server Express (default) | `.\SQLEXPRESS` |
| SQL Server Developer/Standard (default) | `.` or `localhost` |
| Named instance | `.\<InstanceName>` |

---

## Quick Start (One Command)

```powershell
# Windows Authentication — most common for local SQL Server
.\scripts\run-dev-sqlserver.ps1

# Different instance
.\scripts\run-dev-sqlserver.ps1 -Instance "."

# SQL Server Authentication
.\scripts\run-dev-sqlserver.ps1 -SqlAuth -SqlPassword "MyP@ssword1"
```

The script will:
1. Check .NET SDK + `sqlcmd` availability
2. Create database `MPSIP_DEV` if it doesn't exist (idempotent)
3. Create SQL login + user + permissions if using `-SqlAuth`
4. Build the solution
5. Set connection string via environment variable override
6. Start Kestrel on `http://localhost:5093`
7. Open your browser

> **Default login** (dev seed data):  
> Email: `owner@mpsip.dev` · Password: `Dev@1234`

---

## Script Parameters

```powershell
.\scripts\run-dev-sqlserver.ps1 [options]
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-Instance` | `.\SQLEXPRESS` | SQL Server instance name |
| `-Database` | `MPSIP_DEV` | Database to create/use |
| `-SqlAuth` | (off) | Use SQL Server Authentication |
| `-SqlUser` | `mpsip_dev` | SQL login name (used with `-SqlAuth`) |
| `-SqlPassword` | _(required)_ | SQL login password (used with `-SqlAuth`) |
| `-Https` | (off) | Use HTTPS profile (`https://localhost:7098`) |
| `-NoBrowser` | (off) | Skip browser auto-open |
| `-NoBuild` | (off) | Skip build step |

### Examples

```powershell
# Default instance, Windows Auth
.\scripts\run-dev-sqlserver.ps1 -Instance "."

# Named instance, custom DB
.\scripts\run-dev-sqlserver.ps1 -Instance ".\SQL2022" -Database "MPSIP_TEST"

# SQL Auth with HTTPS, no browser
.\scripts\run-dev-sqlserver.ps1 -SqlAuth -SqlPassword "P@ss1" -Https -NoBrowser

# Fast restart (already built)
.\scripts\run-dev-sqlserver.ps1 -NoBuild
```

---

## How the Connection String Override Works

The script sets the environment variable:

```
ConnectionStrings__DefaultConnection = "Server=...;Database=...;..."
```

ASP.NET Core reads configuration in this order (highest wins):
1. **Environment variables** ← script sets this
2. `appsettings.{Environment}.json`
3. `appsettings.json`

So the app uses your SQL Server instance without any file edits.

### Manual override (alternative)

You can also edit `src/MPSIP.Web/appsettings.SqlServer.json` and add it as a custom environment:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.\\SQLEXPRESS;Database=MPSIP_DEV;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

Then run with:
```powershell
$env:ASPNETCORE_ENVIRONMENT = "SqlServer"
dotnet run --project src/MPSIP.Web --launch-profile http
```

> This file is committed as a template. Copy it to `appsettings.SqlServer.Local.json` (gitignored) for SQL Auth credentials.

---

## Manual Setup (Without the Script)

If you prefer to set up the database yourself:

### 1 — Create database and user

**Windows Auth:**
```sql
-- Run in SSMS or sqlcmd against master
CREATE DATABASE MPSIP_DEV;
```

**SQL Auth:**
```sql
CREATE DATABASE MPSIP_DEV;
CREATE LOGIN mpsip_dev WITH PASSWORD = 'YourPassword', CHECK_POLICY = OFF;
USE MPSIP_DEV;
CREATE USER mpsip_dev FOR LOGIN mpsip_dev;
ALTER ROLE db_datareader ADD MEMBER mpsip_dev;
ALTER ROLE db_datawriter ADD MEMBER mpsip_dev;
GRANT EXECUTE TO mpsip_dev;
```

### 2 — Set connection string and run

```powershell
# Windows Auth
$env:ASPNETCORE_ENVIRONMENT = "Development"
$env:ConnectionStrings__DefaultConnection = "Server=.\SQLEXPRESS;Database=MPSIP_DEV;Trusted_Connection=True;TrustServerCertificate=True;"
dotnet run --project src/MPSIP.Web --launch-profile http

# SQL Auth
$env:ConnectionStrings__DefaultConnection = "Server=.\SQLEXPRESS;Database=MPSIP_DEV;User Id=mpsip_dev;Password=YourPassword;TrustServerCertificate=True;"
```

Migrations + seeds run automatically on first start.

---

## First-Run Notes

On first start, `DatabaseMigrator` creates all tables and installs stored procedures automatically. Watch the console for:

```
info: DatabaseMigrator Applied migration V001__CreateSchemaVersion.sql
...
info: DatabaseMigrator Seed Seed_DevData.sql applied (dev-only).
```

Subsequent starts skip already-applied migrations.

---

## Stop the App

Press **Ctrl+C** in the terminal.

---

## Troubleshooting

### Cannot connect to SQL Server instance

```powershell
# Test connectivity manually
sqlcmd -S .\SQLEXPRESS -E -Q "SELECT 1"

# Check the SQL Server service is running
Get-Service | Where-Object Name -like "MSSQL*"

# Start it if stopped
Start-Service MSSQL`$SQLEXPRESS   # adjust instance name
```

Make sure:
- SQL Server Browser service is running (needed for named instances)
- TCP/IP is enabled in SQL Server Configuration Manager
- Windows Firewall allows SQL Server (port 1433 for default instance)

### Mixed Mode Auth required for SQL Auth

If you get "Login failed for user" with `-SqlAuth`:
1. Open **SQL Server Management Studio**
2. Right-click the server → **Properties** → **Security**
3. Select **SQL Server and Windows Authentication mode**
4. Restart the SQL Server service

### Login failed for Windows Auth

Ensure your Windows account has access. In SSMS:
```sql
-- Grant sysadmin (dev machine only, not for UAT/PROD)
ALTER SERVER ROLE sysadmin ADD MEMBER [DOMAIN\YourUser];
```

Or grant minimal rights to the specific DB:
```sql
USE MPSIP_DEV;
CREATE USER [DOMAIN\YourUser] FOR LOGIN [DOMAIN\YourUser];
ALTER ROLE db_datareader ADD MEMBER [DOMAIN\YourUser];
ALTER ROLE db_datawriter ADD MEMBER [DOMAIN\YourUser];
GRANT EXECUTE TO [DOMAIN\YourUser];
```

### Port conflict

```powershell
netstat -ano | findstr :5093
Stop-Process -Id <PID>
```

### Build errors

```powershell
cd src
dotnet build MPSIP.slnx
```
