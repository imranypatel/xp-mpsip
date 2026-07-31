using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Application.Services;

public class PartnerService(IPartnerRepository repo, IAuthRepository authRepo,
    INotificationService notificationSvc, IProjectRepository projectRepo,
    IEmailSender emailSender)
{
    public async Task<int> InviteAsync(InvitePartnerCommand cmd)
    {
        // Check if user already exists by email
        var (existingUser, _, _) = await authRepo.GetUserForLoginAsync(cmd.Email);
        int userId;
        if (existingUser != null)
        {
            userId = existingUser.Id;
        }
        else
        {
            // Create a placeholder user (will complete registration via invitation)
            userId = await authRepo.CreateUserAsync(
                new RegisterDto(cmd.Email, Guid.NewGuid().ToString(), cmd.Email.Split('@')[0]),
                BCrypt.Net.BCrypt.HashPassword(Guid.NewGuid().ToString()), "bcrypt");
        }

        int partnerId = await repo.CreateAsync(cmd.ProjectId, userId, cmd.StakePct, cmd.InvitedBy);
        foreach (var role in cmd.Roles)
            await repo.AssignRoleAsync(partnerId, role);

        await repo.SaveAgreementAsync(partnerId, cmd.ContributionTerms, cmd.IncentiveTerms, cmd.RiskAcceptance);

        var project = await projectRepo.GetByIdAsync(cmd.ProjectId);
        string projectName = project?.Name ?? "Project";

        // Send invitation token + email via auth service
        var expiresAt = DateTime.UtcNow.AddHours(48);
        int tokenRowId = await authRepo.CreateInvitationAsync(cmd.ProjectId, cmd.Email, expiresAt);

        await notificationSvc.CreateAsync(new CreateNotificationCommand(
            cmd.InvitedBy, "InvitationSent",
            $"Invitation sent to {cmd.Email}",
            $"An invitation to join '{projectName}' has been sent.", cmd.ProjectId));

        return partnerId;
    }

    public async Task<IEnumerable<Partner>> GetByProjectAsync(int projectId) =>
        await repo.GetByProjectAsync(projectId);

    public async Task<PartnerAgreement?> GetAgreementAsync(int projectId, int partnerId)
    {
        var partner = await repo.GetByIdAsync(partnerId);
        if (partner?.ProjectId != projectId) return null;
        return await repo.GetAgreementAsync(partnerId);
    }

    public async Task<IEnumerable<Partner>> GetByUserAsync(int userId) =>
        await repo.GetByUserAsync(userId);

    public async Task UpdateStakeAsync(int partnerId, decimal pct) =>
        await repo.UpdateStakeAsync(partnerId, pct);

    public async Task AcknowledgeAgreementAsync(AcknowledgeAgreementCommand cmd)
    {
        await repo.AcknowledgeAsync(cmd);
        var partner = await repo.GetByIdAsync(cmd.PartnerId);
        if (partner != null)
        {
            await notificationSvc.CreateAsync(new CreateNotificationCommand(
                partner.CreatedBy, "InvitationAccepted",
                $"{partner.DisplayName ?? partner.Email} accepted",
                "A partner has acknowledged their agreement.", partner.ProjectId));
        }
    }
}
