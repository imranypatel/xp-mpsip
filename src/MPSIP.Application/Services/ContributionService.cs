using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Application.Services;

public class ContributionService(IContributionRepository repo, INotificationService notificationSvc,
    IProjectRepository projectRepo)
{
    public async Task<int> LogAsync(LogContributionCommand cmd)
    {
        int id = await repo.CreateAsync(cmd);
        var project = await projectRepo.GetByIdAsync(cmd.ProjectId);
        if (project != null)
        {
            await notificationSvc.CreateAsync(new CreateNotificationCommand(
                project.OwnerId, "ContributionLogged",
                "New contribution logged",
                $"A {cmd.ResourceType} contribution was added to '{project.Name}'.",
                cmd.ProjectId));
        }
        return id;
    }

    public async Task<IEnumerable<Contribution>> ListByProjectAsync(int projectId) =>
        await repo.ListByProjectAsync(projectId);

    public async Task<IEnumerable<Contribution>> ListByUserAsync(int userId) =>
        await repo.ListByUserAsync(userId);

    public async Task DeleteAsync(int id, int requestingUserId) =>
        await repo.SoftDeleteAsync(id, requestingUserId);
}
