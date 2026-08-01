<#
.SYNOPSIS
    Run MPSIP on Kestrel backed by a locally installed SQL Server instance.

.DESCRIPTION
    Sets up the database (idempotent), overrides the connection string via
    environment variable, builds the solution, and launches MPSIP.Web on Kestrel.

    This script complements run-dev.ps1 (LocalDB). Use this one when you have
    a full SQL Server instance installed (Express, Developer, or Standard/Enterprise).

.PARAMETER Instance
    SQL Server instance name. Default: .\SQLEXPRESS
    Examples: .\SQLEXPRESS  |  .  |  localhost  |  .\MSSQLSERVER  |  SERVER\INSTANCE

.PARAMETER Database
    Database name to create (if it does not exist) and connect to. Default: MPSIP_DEV

.PARAMETER SqlAuth
    Switch to use SQL Server Authentication instead of Windows Authentication.
    When set, -SqlUser and -SqlPassword are required.

.PARAMETER SqlUser
    SQL Server login name. Only used with -SqlAuth. Default: mpsip_dev

.PARAMETER SqlPassword
    SQL Server login password. Only used with -SqlAuth. Required when -SqlAuth is set.

.PARAMETER Https
    Use the 'https' Kestrel profile (https://localhost:7098) instead of http.

.PARAMETER NoBrowser
    Skip opening the browser automatically.

.PARAMETER NoBuild
    Skip the build step (use when you have just built with no code changes).

.EXAMPLE
    # Windows Auth (default) — most common for local SQL Server
    .\scripts\run-dev-sqlserver.ps1

    # Specify a named instance
    .\scripts\run-dev-sqlserver.ps1 -Instance ".\MSSQLSERVER"

    # SQL Server Auth
    .\scripts\run-dev-sqlserver.ps1 -SqlAuth -SqlPassword "MyP@ssword1"

    # Full SQL Server, HTTPS, no browser
    .\scripts\run-dev-sqlserver.ps1 -Instance "." -Https -NoBrowser
#>
[CmdletBinding()]
param(
    [string]$Instance    = ".\SQLEXPRESS",
    [string]$Database    = "MPSIP_DEV",
    [switch]$SqlAuth,
    [string]$SqlUser     = "mpsip_dev",
    [string]$SqlPassword = "",
    [switch]$Https,
    [switch]$NoBrowser,
    [switch]$NoBuild
)

$ErrorActionPreference = "Stop"
$RepoRoot   = Split-Path $PSScriptRoot -Parent
$WebProject = Join-Path $RepoRoot "src\MPSIP.Web\MPSIP.Web.csproj"

# ── Validate params ───────────────────────────────────────────────────────────
if ($SqlAuth -and [string]::IsNullOrWhiteSpace($SqlPassword)) {
    Write-Error "When using -SqlAuth you must also supply -SqlPassword."
    exit 1
}

# ── 1. Prerequisite: .NET SDK ─────────────────────────────────────────────────
Write-Host "`n[1/5] Checking .NET SDK..." -ForegroundColor Cyan
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error "dotnet CLI not found. Install the .NET 10 SDK: https://dotnet.microsoft.com/download/dotnet/10.0"
    exit 1
}
Write-Host "      Found: dotnet $(dotnet --version)" -ForegroundColor Green

# ── 2. Prerequisite: sqlcmd ───────────────────────────────────────────────────
Write-Host "`n[2/5] Checking sqlcmd availability..." -ForegroundColor Cyan
$hasSqlcmd = Get-Command sqlcmd -ErrorAction SilentlyContinue
$hasSqlPs  = Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue
if (-not $hasSqlcmd -and -not $hasSqlPs) {
    Write-Error @"
Neither 'sqlcmd' nor 'Invoke-Sqlcmd' found. Install one of:
  - sqlcmd (standalone): https://learn.microsoft.com/sql/tools/sqlcmd/sqlcmd-utility
  - SqlServer PowerShell module: Install-Module -Name SqlServer
"@
    exit 1
}
Write-Host "      Found: $(if ($hasSqlcmd) { 'sqlcmd' } else { 'Invoke-Sqlcmd' })" -ForegroundColor Green

# ── Helper: run T-SQL via sqlcmd or Invoke-Sqlcmd ────────────────────────────
function Invoke-TSql {
    param([string]$Sql, [string]$Db = "master")

    if ($hasSqlcmd) {
        $authArgs = if ($SqlAuth) {
            @("-U", $SqlUser, "-P", $SqlPassword)
        } else {
            @("-E")  # Windows Auth
        }
        $result = sqlcmd -S $Instance -d $Db @authArgs -Q $Sql 2>&1
        if ($LASTEXITCODE -ne 0) { throw "sqlcmd failed:`n$result" }
        return $result
    } else {
        $authArgs = if ($SqlAuth) {
            @{ Username = $SqlUser; Password = $SqlPassword }
        } else {
            @{}
        }
        return Invoke-Sqlcmd -ServerInstance $Instance -Database $Db -Query $Sql @authArgs -ErrorAction Stop
    }
}

# ── 3. Create database (idempotent) ───────────────────────────────────────────
Write-Host "`n[3/5] Setting up database '$Database' on '$Instance'..." -ForegroundColor Cyan

Invoke-TSql -Sql @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'$Database')
BEGIN
    CREATE DATABASE [$Database];
    PRINT 'Database $Database created.';
END
ELSE
    PRINT 'Database $Database already exists.';
"@

if ($SqlAuth) {
    Write-Host "      Ensuring SQL login '$SqlUser'..." -ForegroundColor DarkGray
    Invoke-TSql -Sql @"
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'$SqlUser')
BEGIN
    CREATE LOGIN [$SqlUser] WITH PASSWORD = N'$SqlPassword', CHECK_POLICY = OFF;
    PRINT 'Login $SqlUser created.';
END
"@
    Invoke-TSql -Db $Database -Sql @"
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = N'$SqlUser')
BEGIN
    CREATE USER [$SqlUser] FOR LOGIN [$SqlUser];
    ALTER ROLE db_datareader ADD MEMBER [$SqlUser];
    ALTER ROLE db_datawriter ADD MEMBER [$SqlUser];
    GRANT EXECUTE TO [$SqlUser];
    PRINT 'User $SqlUser configured.';
END
"@
}

Write-Host "      Database ready." -ForegroundColor Green

# ── 4. Build ──────────────────────────────────────────────────────────────────
if (-not $NoBuild) {
    Write-Host "`n[4/5] Building solution..." -ForegroundColor Cyan
    Push-Location (Join-Path $RepoRoot "src")
    try {
        dotnet restore MPSIP.slnx --verbosity quiet
        dotnet build MPSIP.slnx --no-restore --verbosity minimal
        if ($LASTEXITCODE -ne 0) { throw "Build failed." }
    } finally {
        Pop-Location
    }
    Write-Host "      Build succeeded." -ForegroundColor Green
} else {
    Write-Host "`n[4/5] Skipping build (-NoBuild flag set)." -ForegroundColor Yellow
}

# ── 5. Run on Kestrel ─────────────────────────────────────────────────────────
$profile = if ($Https) { "https" } else { "http" }
$url     = if ($Https) { "https://localhost:7098" } else { "http://localhost:5093" }

# Build connection string — env var overrides appsettings at runtime
$connStr = if ($SqlAuth) {
    "Server=$Instance;Database=$Database;User Id=$SqlUser;Password=$SqlPassword;TrustServerCertificate=True;"
} else {
    "Server=$Instance;Database=$Database;Trusted_Connection=True;TrustServerCertificate=True;"
}

Write-Host "`n[5/5] Starting MPSIP on Kestrel ($url)..." -ForegroundColor Cyan
Write-Host "      Instance  : $Instance" -ForegroundColor DarkGray
Write-Host "      Database  : $Database" -ForegroundColor DarkGray
Write-Host "      Auth      : $(if ($SqlAuth) { "SQL ($SqlUser)" } else { "Windows Integrated" })" -ForegroundColor DarkGray
Write-Host "      Press Ctrl+C to stop.`n" -ForegroundColor DarkGray

if (-not $NoBrowser) {
    Start-Job -ScriptBlock {
        param($u)
        Start-Sleep -Seconds 4
        Start-Process $u
    } -ArgumentList $url | Out-Null
}

# Override connection string via env var (highest precedence in .NET config)
$env:ASPNETCORE_ENVIRONMENT = "Development"
$env:ConnectionStrings__DefaultConnection = $connStr

$runArgs = @("run", "--project", $WebProject, "--launch-profile", $profile)
if ($NoBuild) { $runArgs += "--no-build" }

& dotnet @runArgs
