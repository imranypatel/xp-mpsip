using System.Data;
using System.Reflection;
using System.Text.RegularExpressions;
using Dapper;
using Microsoft.Extensions.Logging;
using MPSIP.Application.Interfaces;

namespace MPSIP.Infrastructure.Database;

/// <summary>
/// Runs SQL migration scripts embedded as resources in the assembly.
/// Scripts are run in V### order, each only once (tracked in SchemaVersion table).
/// All scripts must be idempotent (safe to re-run).
/// </summary>
public class DatabaseMigrator(IDbConnectionFactory factory, ILogger<DatabaseMigrator> logger)
{
    static readonly Regex VersionPattern = new(@"V(\d+)__", RegexOptions.IgnoreCase);

    public void Run()
    {
        using var conn = factory.Create();
        conn.Open();

        EnsureSchemaVersionTable(conn);

        var applied = conn.Query<int>("SELECT Version FROM dbo.SchemaVersion").ToHashSet();

        var scripts = GetOrderedMigrationScripts();
        foreach (var (version, name, sql) in scripts)
        {
            if (applied.Contains(version))
            {
                logger.LogDebug("Migration V{Version} already applied, skipping.", version);
                continue;
            }

            logger.LogInformation("Applying migration V{Version}: {Name}", version, name);
            try
            {
                using var tx = conn.BeginTransaction();
                try
                {
                    conn.Execute(sql, transaction: tx, commandTimeout: 120);
                    conn.Execute(
                        "INSERT INTO dbo.SchemaVersion (Version, Description) VALUES (@Version, @Description)",
                        new { Version = version, Description = name },
                        transaction: tx);
                    tx.Commit();
                    logger.LogInformation("Migration V{Version} applied successfully.", version);
                }
                catch
                {
                    tx.Rollback();
                    throw;
                }
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Migration V{Version} failed.", version);
                throw;
            }
        }
    }

    public void RunStoredProcedures()
    {
        using var conn = factory.Create();
        conn.Open();

        var spScripts = GetStoredProcedureScripts();
        logger.LogInformation("Applying {Count} stored procedures.", spScripts.Count);

        foreach (var (name, sql) in spScripts)
        {
            try
            {
                // Split on GO batches
                var batches = Regex.Split(sql, @"^\s*GO\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase)
                    .Where(b => !string.IsNullOrWhiteSpace(b));
                foreach (var batch in batches)
                    conn.Execute(batch.Trim(), commandTimeout: 60);

                logger.LogDebug("Stored procedure applied: {Name}", name);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Failed to apply stored procedure: {Name}", name);
                throw;
            }
        }
    }

    public void RunSeeds(bool devOnly = false)
    {
        using var conn = factory.Create();
        conn.Open();

        var seeds = GetSeedScripts(devOnly);
        foreach (var (name, sql) in seeds)
        {
            try
            {
                conn.Execute(sql, commandTimeout: 60);
                logger.LogInformation("Seed applied: {Name}", name);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Seed failed: {Name}", name);
                throw;
            }
        }
    }

    static void EnsureSchemaVersionTable(IDbConnection conn)
    {
        const string sql = """
            IF OBJECT_ID('dbo.SchemaVersion', 'U') IS NULL
            CREATE TABLE dbo.SchemaVersion (
                Version     INT           NOT NULL PRIMARY KEY,
                Description NVARCHAR(200) NOT NULL,
                AppliedAt   DATETIME2     NOT NULL DEFAULT GETUTCDATE()
            );
            """;
        conn.Execute(sql);
    }

    static List<(int Version, string Name, string Sql)> GetOrderedMigrationScripts()
    {
        var baseDir = GetDatabaseDir("Migrations");
        if (!Directory.Exists(baseDir)) return [];

        return Directory.GetFiles(baseDir, "V*.sql")
            .Select(path =>
            {
                var file = Path.GetFileNameWithoutExtension(path);
                var match = VersionPattern.Match(file);
                if (!match.Success) return (Version: -1, Name: file, Sql: "");
                int version = int.Parse(match.Groups[1].Value);
                string sql = File.ReadAllText(path);
                return (Version: version, Name: file, Sql: sql);
            })
            .Where(x => x.Version > 0)
            .OrderBy(x => x.Version)
            .ToList();
    }

    static List<(string Name, string Sql)> GetStoredProcedureScripts()
    {
        var baseDir = GetDatabaseDir("StoredProcedures");
        if (!Directory.Exists(baseDir)) return [];

        return Directory.GetFiles(baseDir, "sp_*.sql", SearchOption.AllDirectories)
            .Select(path => (Path.GetFileName(path), File.ReadAllText(path)))
            .OrderBy(x => x.Item1)
            .ToList();
    }

    static List<(string Name, string Sql)> GetSeedScripts(bool devOnly)
    {
        var baseDir = GetDatabaseDir("Seeds");
        if (!Directory.Exists(baseDir)) return [];

        var all = Directory.GetFiles(baseDir, "Seed_*.sql")
            .Select(path => (Path.GetFileName(path), File.ReadAllText(path)))
            .Where(x => devOnly || !x.Item1.Contains("DevData"))
            .OrderBy(x => x.Item1)
            .ToList();
        return all;
    }

    static string GetDatabaseDir(string sub)
    {
        // Locate relative to executing assembly location
        var asmDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)!;
        // Walk up from bin/Debug/net10.0 to src/MPSIP.Infrastructure
        // In dev: asmDir = .../src/MPSIP.Infrastructure/bin/Debug/net10.0
        // In publish: scripts are copied to output/Database/...
        var candidate = Path.Combine(asmDir, "Database", sub);
        if (Directory.Exists(candidate)) return candidate;

        // Dev fallback: source tree
        var dir = new DirectoryInfo(asmDir);
        while (dir != null && dir.Name != "MPSIP.Infrastructure")
            dir = dir.Parent;
        if (dir != null)
        {
            candidate = Path.Combine(dir.FullName, "Database", sub);
            if (Directory.Exists(candidate)) return candidate;
        }
        return candidate; // return anyway, caller checks
    }
}
