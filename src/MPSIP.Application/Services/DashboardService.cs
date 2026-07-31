using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;

namespace MPSIP.Application.Services;

public class DashboardService(IProjectRepository projectRepo, IPartnerRepository partnerRepo,
    IContributionRepository contributionRepo, IDistributionRepository distributionRepo)
{
    public async Task<OwnerDashboardDto> GetOwnerDashboardAsync(int ownerId)
    {
        var projects = (await projectRepo.ListByOwnerAsync(ownerId)).ToList();
        var summaries = new List<ProjectSummaryDto>();
        decimal totalContrib = 0, pendingDist = 0;

        foreach (var p in projects.Where(p => !p.IsDeleted))
        {
            var summary = await projectRepo.GetSummaryAsync(p.Id);
            if (summary != null)
            {
                summaries.Add(summary);
                totalContrib += summary.TotalContributions;
                pendingDist += summary.PendingDistributions;
            }
        }

        return new OwnerDashboardDto(summaries, projects.Count,
            projects.Count(p => p.StatusCode == "Active"), totalContrib, pendingDist);
    }

    public async Task<PartnerDashboardDto> GetPartnerDashboardAsync(int userId)
    {
        var partners = (await partnerRepo.GetByUserAsync(userId)).ToList();
        var projectDtos = new List<PartnerProjectDto>();

        foreach (var p in partners)
        {
            var contributions = await contributionRepo.ListByUserAsync(userId);
            decimal myContrib = contributions
                .Where(c => c.ProjectId == p.ProjectId)
                .Sum(c => c.MonetaryValue ?? 0);

            projectDtos.Add(new PartnerProjectDto(
                p.ProjectId, p.ProjectName ?? "", p.StatusCode, p.StakePct,
                myContrib, 0, [.. p.Roles]));
        }

        return new PartnerDashboardDto(projectDtos,
            projectDtos.Sum(p => p.MyContributions),
            projectDtos.Sum(p => p.MyPendingIncentives));
    }
}
