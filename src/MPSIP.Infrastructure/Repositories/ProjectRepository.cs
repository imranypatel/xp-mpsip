using System.Data;
using Dapper;
using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Infrastructure.Repositories;

public class ProjectRepository(IDbConnectionFactory factory) : IProjectRepository
{
    public async Task<int> CreateAsync(CreateProjectCommand cmd)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>("sp_Project_Create", cmd, commandType: CommandType.StoredProcedure);
    }

    public async Task<Project?> GetByIdAsync(int id)
    {
        using var conn = factory.Create();
        return await conn.QuerySingleOrDefaultAsync<Project>(
            "sp_Project_GetById", new { Id = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Project>> ListByOwnerAsync(int ownerId)
    {
        using var conn = factory.Create();
        return await conn.QueryAsync<Project>(
            "sp_Project_ListByOwner", new { OwnerId = ownerId }, commandType: CommandType.StoredProcedure);
    }

    public async Task UpdateAsync(UpdateProjectCommand cmd)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Project_Update", cmd, commandType: CommandType.StoredProcedure);
    }

    public async Task UpdateStatusAsync(int id, string statusCode, int modifiedBy)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Project_UpdateStatus",
            new { Id = id, StatusCode = statusCode, ModifiedBy = modifiedBy },
            commandType: CommandType.StoredProcedure);
    }

    public async Task ApplyTemplateAsync(int projectId, int templateId, int createdBy)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Project_ApplyTemplate",
            new { ProjectId = projectId, TemplateId = templateId, CreatedBy = createdBy },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<ProjectPhase>> GetPhasesWithTasksAsync(int projectId)
    {
        using var conn = factory.Create();
        var phaseLookup = new Dictionary<int, ProjectPhase>();
        await conn.QueryAsync<ProjectPhase, ProjectTask, ProjectPhase>(
            "sp_Project_GetPhasesWithTasks",
            (phase, task) =>
            {
                if (!phaseLookup.TryGetValue(phase.Id, out var existing))
                {
                    existing = phase;
                    phaseLookup[phase.Id] = existing;
                }
                if (task != null) existing.Tasks.Add(task);
                return existing;
            },
            new { ProjectId = projectId },
            splitOn: "Id",
            commandType: CommandType.StoredProcedure);
        return phaseLookup.Values.OrderBy(p => p.SortOrder);
    }

    public async Task<ProjectSummaryDto?> GetSummaryAsync(int projectId)
    {
        using var conn = factory.Create();
        var row = await conn.QuerySingleOrDefaultAsync(
            "sp_Project_GetSummary", new { ProjectId = projectId }, commandType: CommandType.StoredProcedure);
        if (row == null) return null;
        return new ProjectSummaryDto(row.Id, row.Name, row.StatusCode, row.OpportunityKindName ?? "",
            (int)row.PhaseCount, (int)row.CompletedPhaseCount, (int)row.PartnerCount,
            (decimal)row.TotalContributions, (decimal)row.PendingDistributions,
            DateOnly.FromDateTime((DateTime)row.StartDate),
            DateOnly.FromDateTime((DateTime)row.ExpectedEndDate));
    }
}
