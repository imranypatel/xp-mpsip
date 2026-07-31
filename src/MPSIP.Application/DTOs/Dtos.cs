namespace MPSIP.Application.DTOs;

public record AuthUserDto(int Id, string Email, string DisplayName, bool IsActive);
public record LoginDto(string Email, string Password);
public record RegisterDto(string Email, string Password, string DisplayName);
public record AcceptInvitationDto(Guid Token, string Password, string DisplayName);
public record InvitationInfoDto(Guid Token, int ProjectId, string Email, bool IsValid, string? ProjectName = null);

public record CreateProjectCommand(
    int OwnerId, string Name, string? Description,
    int OpportunityKindId, int? TemplateId,
    DateOnly StartDate, DateOnly ExpectedEndDate,
    string? RiskDeclaration, string? Contingency);

public record UpdateProjectCommand(
    int Id, string Name, string? Description,
    DateOnly StartDate, DateOnly ExpectedEndDate,
    string? RiskDeclaration, string? Contingency, int ModifiedBy);

public record InvitePartnerCommand(int ProjectId, string Email, string[] Roles, decimal StakePct,
    string? ContributionTerms, string? IncentiveTerms, string? RiskAcceptance, int InvitedBy);

public record AcknowledgeAgreementCommand(int PartnerId, string SignatureText, int UserId);

public record LogContributionCommand(int ProjectId, int? ProjectTaskId, int ContributorId,
    string ResourceType, string Description, decimal Quantity, string? Unit,
    decimal? MonetaryValue, DateOnly ContributionDate);

public record CreateDistributionCommand(int ProjectId, string Name, decimal TotalAmount,
    DateOnly EventDate, string? Notes, int CreatedBy);

public record CreateNotificationCommand(int UserId, string TypeCode, string Title, string Body, int? ProjectId = null);

public record InitiateClosureCommand(int ProjectId, string? ClosureNotes, int? FinalDistEventId, int InitiatedBy);

public record SubmitFeedbackCommand(int ClosureId, int PartnerId, byte? Rating, string? Comments);

public record OwnerDashboardDto(
    IEnumerable<ProjectSummaryDto> Projects,
    int TotalProjects, int ActiveProjects,
    decimal TotalContributions, decimal PendingDistributions);

public record ProjectSummaryDto(
    int Id, string Name, string StatusCode, string OpportunityKindName,
    int PhaseCount, int CompletedPhaseCount, int PartnerCount,
    decimal TotalContributions, decimal PendingDistributions,
    DateOnly StartDate, DateOnly ExpectedEndDate);

public record PartnerDashboardDto(
    IEnumerable<PartnerProjectDto> Projects,
    decimal TotalContributed, decimal TotalReceived);

public record PartnerProjectDto(
    int ProjectId, string ProjectName, string StatusCode, decimal StakePct,
    decimal MyContributions, decimal MyPendingIncentives, string[] Roles);
