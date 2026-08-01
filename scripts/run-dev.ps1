<#
.SYNOPSIS
    Run MPSIP on Kestrel (Development environment).

.DESCRIPTION
    Checks prerequisites, starts SQL Server LocalDB, builds the solution,
    then launches MPSIP.Web on Kestrel and opens the browser.

.PARAMETER Https
    Use the 'https' launch profile (https://localhost:7098) instead of plain http.

.PARAMETER NoBrowser
    Skip opening the browser automatically.

.PARAMETER NoBuild
    Skip the build step (use when you've just built and want a faster restart).

.EXAMPLE
    .\scripts\run-dev.ps1                    # http://localhost:5093
    .\scripts\run-dev.ps1 -Https             # https://localhost:7098
    .\scripts\run-dev.ps1 -NoBuild           # skip build, run immediately
    .\scripts\run-dev.ps1 -Https -NoBrowser  # https, no browser pop-up
#>
[CmdletBinding()]
param(
    [switch]$Https,
    [switch]$NoBrowser,
    [switch]$NoBuild
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path $PSScriptRoot -Parent
$SolutionFile = Join-Path $RepoRoot "src\MPSIP.slnx"
$WebProject  = Join-Path $RepoRoot "src\MPSIP.Web\MPSIP.Web.csproj"

# ── 1. Prerequisite: .NET SDK ─────────────────────────────────────────────────
Write-Host "`n[1/4] Checking .NET SDK..." -ForegroundColor Cyan
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Error "dotnet CLI not found. Install the .NET 10 SDK from https://dotnet.microsoft.com/download/dotnet/10.0"
    exit 1
}
$sdkVersion = dotnet --version
Write-Host "      Found: dotnet $sdkVersion" -ForegroundColor Green

# ── 2. Start SQL Server LocalDB ───────────────────────────────────────────────
Write-Host "`n[2/4] Starting SQL Server LocalDB (MSSQLLocalDB)..." -ForegroundColor Cyan
$localdb = Get-Command sqllocaldb -ErrorAction SilentlyContinue
if ($localdb) {
    # Start is idempotent — safe if already running
    sqllocaldb start MSSQLLocalDB 2>&1 | ForEach-Object {
        Write-Host "      $_" -ForegroundColor DarkGray
    }
    Write-Host "      LocalDB ready." -ForegroundColor Green
} else {
    Write-Host "      sqllocaldb not found — assuming SQL Server is reachable via connection string." -ForegroundColor Yellow
    Write-Host "      If the app fails to connect, install SQL Server Express LocalDB." -ForegroundColor Yellow
}

# ── 3. Build ──────────────────────────────────────────────────────────────────
if (-not $NoBuild) {
    Write-Host "`n[3/4] Building solution..." -ForegroundColor Cyan
    Push-Location (Join-Path $RepoRoot "src")
    try {
        dotnet restore MPSIP.slnx --verbosity quiet
        dotnet build MPSIP.slnx --no-restore --verbosity minimal
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Build failed. Fix errors above before running."
            exit 1
        }
    } finally {
        Pop-Location
    }
    Write-Host "      Build succeeded." -ForegroundColor Green
} else {
    Write-Host "`n[3/4] Skipping build (-NoBuild flag set)." -ForegroundColor Yellow
}

# ── 4. Run on Kestrel ─────────────────────────────────────────────────────────
$profile = if ($Https) { "https" } else { "http" }
$url     = if ($Https) { "https://localhost:7098" } else { "http://localhost:5093" }

Write-Host "`n[4/4] Starting MPSIP on Kestrel ($url)..." -ForegroundColor Cyan
Write-Host "      Profile : $profile" -ForegroundColor DarkGray
Write-Host "      Env     : Development" -ForegroundColor DarkGray
Write-Host "      Press Ctrl+C to stop.`n" -ForegroundColor DarkGray

if (-not $NoBrowser) {
    # Open browser after a short delay to let Kestrel start
    Start-Job -ScriptBlock {
        param($u)
        Start-Sleep -Seconds 3
        Start-Process $u
    } -ArgumentList $url | Out-Null
}

$runArgs = @(
    "run",
    "--project", $WebProject,
    "--launch-profile", $profile
)
if ($NoBuild) { $runArgs += "--no-build" }

$env:ASPNETCORE_ENVIRONMENT = "Development"
& dotnet @runArgs
