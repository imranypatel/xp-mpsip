using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Application.Services;

public class ProjectService(IProjectRepository repo)
{
    public async Task<int> CreateAsync(CreateProjectCommand cmd)
    {
        int projectId = await repo.CreateAsync(cmd);
        if (cmd.TemplateId.HasValue)
            await repo.ApplyTemplateAsync(projectId, cmd.TemplateId.Value, cmd.OwnerId);
        return projectId;
    }

    public async Task<Project?> GetByIdAsync(int id) => await repo.GetByIdAsync(id);

    public async Task<IEnumerable<Project>> ListByOwnerAsync(int ownerId) =>
        await repo.ListByOwnerAsync(ownerId);

    public async Task UpdateAsync(UpdateProjectCommand cmd) => await repo.UpdateAsync(cmd);

    public async Task UpdateStatusAsync(int id, string statusCode, int userId) =>
        await repo.UpdateStatusAsync(id, statusCode, userId);

    public async Task<IEnumerable<ProjectPhase>> GetPhasesAsync(int projectId) =>
        await repo.GetPhasesWithTasksAsync(projectId);

    public async Task<ProjectSummaryDto?> GetSummaryAsync(int projectId) =>
        await repo.GetSummaryAsync(projectId);
}
