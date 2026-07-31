using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Application.Services;

public class DistributionService(IDistributionRepository repo, IPartnerRepository partnerRepo,
    INotificationService notificationSvc, IProjectRepository projectRepo)
{
    public async Task<int> CreateEventAsync(CreateDistributionCommand cmd)
    {
        int eventId = await repo.CreateEventAsync(cmd);
        var partners = await partnerRepo.GetByProjectAsync(cmd.ProjectId);
        var activePartners = partners.Where(p => p.StatusCode == "Active" && p.StakePct > 0).ToList();

        foreach (var partner in activePartners)
        {
            decimal amount = Math.Round(cmd.TotalAmount * partner.StakePct / 100, 2);
            await repo.CreateShareAsync(eventId, partner.Id, partner.StakePct, amount);
        }

        var project = await projectRepo.GetByIdAsync(cmd.ProjectId);
        foreach (var partner in activePartners)
        {
            await notificationSvc.CreateAsync(new CreateNotificationCommand(
                partner.UserId, "DistributionDeclared",
                "Distribution declared",
                $"A distribution of {cmd.TotalAmount:C} has been declared for '{project?.Name}'.",
                cmd.ProjectId));
        }

        return eventId;
    }

    public async Task<IEnumerable<DistributionEvent>> ListByProjectAsync(int projectId) =>
        await repo.ListByProjectAsync(projectId);

    public async Task<DistributionEvent?> GetByIdAsync(int id) => await repo.GetByIdAsync(id);

    public async Task AcknowledgeShareAsync(int shareId, int userId) =>
        await repo.AcknowledgeShareAsync(shareId, userId);

    public async Task UpdateStatusAsync(int eventId, string status) =>
        await repo.UpdateStatusAsync(eventId, status);
}
