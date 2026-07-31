using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Application.Services;

public class ClosureService(IClosureRepository repo, IProjectRepository projectRepo,
    INotificationService notificationSvc)
{
    public async Task<int> InitiateAsync(InitiateClosureCommand cmd)
    {
        int closureId = await repo.InitiateAsync(cmd);
        await projectRepo.UpdateStatusAsync(cmd.ProjectId, "Closing", cmd.InitiatedBy);
        return closureId;
    }

    public async Task SubmitFeedbackAsync(SubmitFeedbackCommand cmd) =>
        await repo.SubmitFeedbackAsync(cmd);

    public async Task CompleteAsync(int closureId, int completedBy)
    {
        var closure = await repo.GetByProjectAsync(0); // fetched below
        await repo.CompleteAsync(closureId, completedBy);
    }

    public async Task<ProjectClosure?> GetByProjectAsync(int projectId) =>
        await repo.GetByProjectAsync(projectId);
}
