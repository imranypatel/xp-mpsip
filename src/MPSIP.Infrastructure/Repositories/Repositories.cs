using System.Data;
using Dapper;
using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Infrastructure.Repositories;

public class ContributionRepository(IDbConnectionFactory factory) : IContributionRepository
{
    public async Task<int> CreateAsync(LogContributionCommand cmd)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>("sp_Contribution_Create", cmd, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Contribution>> ListByProjectAsync(int projectId)
    {
        using var conn = factory.Create();
        return await conn.QueryAsync<Contribution>("sp_Contribution_ListByProject",
            new { ProjectId = projectId }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Contribution>> ListByUserAsync(int userId)
    {
        using var conn = factory.Create();
        return await conn.QueryAsync<Contribution>("sp_Contribution_ListByUser",
            new { UserId = userId }, commandType: CommandType.StoredProcedure);
    }

    public async Task SoftDeleteAsync(int id, int deletedBy)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Contribution_Delete",
            new { Id = id, DeletedBy = deletedBy }, commandType: CommandType.StoredProcedure);
    }
}

public class DistributionRepository(IDbConnectionFactory factory) : IDistributionRepository
{
    public async Task<int> CreateEventAsync(CreateDistributionCommand cmd)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>("sp_Distribution_CreateEvent", cmd, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<DistributionEvent>> ListByProjectAsync(int projectId)
    {
        using var conn = factory.Create();
        return await conn.QueryAsync<DistributionEvent>("sp_Distribution_ListByProject",
            new { ProjectId = projectId }, commandType: CommandType.StoredProcedure);
    }

    public async Task<DistributionEvent?> GetByIdAsync(int id)
    {
        using var conn = factory.Create();
        return await conn.QuerySingleOrDefaultAsync<DistributionEvent>(
            "sp_Distribution_GetById", new { Id = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task CreateShareAsync(int eventId, int partnerId, decimal pct, decimal amount)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Distribution_CreateShare",
            new { DistributionEventId = eventId, PartnerId = partnerId, SharePct = pct, Amount = amount },
            commandType: CommandType.StoredProcedure);
    }

    public async Task AcknowledgeShareAsync(int shareId, int userId)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Distribution_AcknowledgeShare",
            new { ShareId = shareId, UserId = userId }, commandType: CommandType.StoredProcedure);
    }

    public async Task UpdateStatusAsync(int eventId, string statusCode)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Distribution_UpdateStatus",
            new { EventId = eventId, StatusCode = statusCode }, commandType: CommandType.StoredProcedure);
    }
}

public class TaskRepository(IDbConnectionFactory factory) : ITaskRepository
{
    public async Task<IEnumerable<ProjectPhase>> ListByProjectAsync(int projectId)
    {
        using var conn = factory.Create();
        var phaseLookup = new Dictionary<int, ProjectPhase>();
        await conn.QueryAsync<ProjectPhase, ProjectTask, ProjectPhase>(
            "sp_Task_ListByProject",
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

    public async Task UpdateStatusAsync(int taskId, string statusCode, int modifiedBy)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Task_UpdateStatus",
            new { TaskId = taskId, StatusCode = statusCode, ModifiedBy = modifiedBy },
            commandType: CommandType.StoredProcedure);
    }

    public async Task AssignUserAsync(int taskId, int userId, int modifiedBy)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Task_AssignUser",
            new { TaskId = taskId, UserId = userId, ModifiedBy = modifiedBy },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<int> CreateAsync(int phaseId, string name, string resourceType, int createdBy)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>("sp_Task_Create",
            new { ProjectPhaseId = phaseId, Name = name, ResourceType = resourceType, CreatedBy = createdBy },
            commandType: CommandType.StoredProcedure);
    }
}

public class NotificationRepository(IDbConnectionFactory factory) : INotificationRepository
{
    public async Task<int> CreateAsync(CreateNotificationCommand cmd)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>("sp_Notification_Create", cmd, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Notification>> ListByUserAsync(int userId, int limit = 50)
    {
        using var conn = factory.Create();
        return await conn.QueryAsync<Notification>("sp_Notification_ListByUser",
            new { UserId = userId, Limit = limit }, commandType: CommandType.StoredProcedure);
    }

    public async Task MarkReadAsync(int notificationId)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Notification_MarkRead",
            new { Id = notificationId }, commandType: CommandType.StoredProcedure);
    }

    public async Task MarkAllReadAsync(int userId)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Notification_MarkAllRead",
            new { UserId = userId }, commandType: CommandType.StoredProcedure);
    }

    public async Task<int> GetUnreadCountAsync(int userId)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>("sp_Notification_GetUnreadCount",
            new { UserId = userId }, commandType: CommandType.StoredProcedure);
    }
}

public class ClosureRepository(IDbConnectionFactory factory) : IClosureRepository
{
    public async Task<int> InitiateAsync(InitiateClosureCommand cmd)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>("sp_Closure_Initiate", cmd, commandType: CommandType.StoredProcedure);
    }

    public async Task SubmitFeedbackAsync(SubmitFeedbackCommand cmd)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Closure_SubmitFeedback", cmd, commandType: CommandType.StoredProcedure);
    }

    public async Task CompleteAsync(int closureId, int completedBy)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Closure_Complete",
            new { ClosureId = closureId, CompletedBy = completedBy },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<ProjectClosure?> GetByProjectAsync(int projectId)
    {
        using var conn = factory.Create();
        return await conn.QuerySingleOrDefaultAsync<ProjectClosure>(
            "sp_Closure_GetByProject", new { ProjectId = projectId }, commandType: CommandType.StoredProcedure);
    }
}
