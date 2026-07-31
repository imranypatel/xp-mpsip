using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Application.Services;

public class TaskService(ITaskRepository repo)
{
    public async Task<IEnumerable<ProjectPhase>> ListByProjectAsync(int projectId) =>
        await repo.ListByProjectAsync(projectId);

    public async Task UpdateStatusAsync(int taskId, string statusCode, int userId) =>
        await repo.UpdateStatusAsync(taskId, statusCode, userId);

    public async Task AssignUserAsync(int taskId, int userId, int modifiedBy) =>
        await repo.AssignUserAsync(taskId, userId, modifiedBy);

    public async Task<int> CreateAdHocAsync(int phaseId, string name, string resourceType, int userId) =>
        await repo.CreateAsync(phaseId, name, resourceType, userId);
}
