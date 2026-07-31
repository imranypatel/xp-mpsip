using MPSIP.Application.DTOs;
using MPSIP.Domain.Entities;

namespace MPSIP.Application.Interfaces;

public interface IDbConnectionFactory
{
    System.Data.IDbConnection Create();
}

public interface IAuthRepository
{
    Task<(AuthUserDto? User, string? PasswordHash, string? Salt)> GetUserForLoginAsync(string email);
    Task<int> CreateUserAsync(RegisterDto dto, string passwordHash, string salt);
    Task<InvitationInfoDto?> GetInvitationAsync(Guid token);
    Task<bool> RedeemInvitationAsync(Guid token, int userId);
    Task<int> CreateInvitationAsync(int projectId, string email, DateTime expiresAt);
    Task<AuthUserDto?> GetUserByIdAsync(int id);
}

public interface IProjectRepository
{
    Task<int> CreateAsync(CreateProjectCommand cmd);
    Task<Project?> GetByIdAsync(int id);
    Task<IEnumerable<Project>> ListByOwnerAsync(int ownerId);
    Task UpdateAsync(UpdateProjectCommand cmd);
    Task UpdateStatusAsync(int id, string statusCode, int modifiedBy);
    Task ApplyTemplateAsync(int projectId, int templateId, int createdBy);
    Task<IEnumerable<ProjectPhase>> GetPhasesWithTasksAsync(int projectId);
    Task<ProjectSummaryDto?> GetSummaryAsync(int projectId);
}

public interface IPartnerRepository
{
    Task<int> CreateAsync(int projectId, int userId, decimal stakePct, int createdBy);
    Task<IEnumerable<Partner>> GetByProjectAsync(int projectId);
    Task<IEnumerable<Partner>> GetByUserAsync(int userId);
    Task UpdateStakeAsync(int partnerId, decimal stakePct);
    Task SaveAgreementAsync(int partnerId, string? contributionTerms, string? incentiveTerms, string? riskAcceptance);
    Task AcknowledgeAsync(AcknowledgeAgreementCommand cmd);
    Task AssignRoleAsync(int partnerId, string roleCode);
    Task<Partner?> GetByIdAsync(int id);
    Task<Partner?> GetByProjectAndUserAsync(int projectId, int userId);
    Task<PartnerAgreement?> GetAgreementAsync(int partnerId);
}

public interface IContributionRepository
{
    Task<int> CreateAsync(LogContributionCommand cmd);
    Task<IEnumerable<Contribution>> ListByProjectAsync(int projectId);
    Task<IEnumerable<Contribution>> ListByUserAsync(int userId);
    Task SoftDeleteAsync(int id, int deletedBy);
}

public interface IDistributionRepository
{
    Task<int> CreateEventAsync(CreateDistributionCommand cmd);
    Task<IEnumerable<DistributionEvent>> ListByProjectAsync(int projectId);
    Task<DistributionEvent?> GetByIdAsync(int id);
    Task CreateShareAsync(int eventId, int partnerId, decimal pct, decimal amount);
    Task AcknowledgeShareAsync(int shareId, int userId);
    Task UpdateStatusAsync(int eventId, string statusCode);
}

public interface ITaskRepository
{
    Task<IEnumerable<ProjectPhase>> ListByProjectAsync(int projectId);
    Task UpdateStatusAsync(int taskId, string statusCode, int modifiedBy);
    Task AssignUserAsync(int taskId, int userId, int modifiedBy);
    Task<int> CreateAsync(int phaseId, string name, string resourceType, int createdBy);
}

public interface INotificationRepository
{
    Task<int> CreateAsync(CreateNotificationCommand cmd);
    Task<IEnumerable<Notification>> ListByUserAsync(int userId, int limit = 50);
    Task MarkReadAsync(int notificationId);
    Task MarkAllReadAsync(int userId);
    Task<int> GetUnreadCountAsync(int userId);
}

public interface IClosureRepository
{
    Task<int> InitiateAsync(InitiateClosureCommand cmd);
    Task SubmitFeedbackAsync(SubmitFeedbackCommand cmd);
    Task CompleteAsync(int closureId, int completedBy);
    Task<ProjectClosure?> GetByProjectAsync(int projectId);
}

public interface IEmailSender
{
    Task SendInvitationAsync(string toEmail, string toName, string projectName, string invitationLink);
}
