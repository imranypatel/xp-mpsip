namespace MPSIP.Domain.Entities;

public class Partner
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public int UserId { get; set; }
    public decimal StakePct { get; set; }
    public DateTime? JoinedAt { get; set; }
    public string StatusCode { get; set; } = "Invited";
    public bool IsDeleted { get; set; } = false;
    public DateTime CreatedAt { get; set; }
    public int CreatedBy { get; set; }

    // Navigation helpers
    public string? DisplayName { get; set; }
    public string? Email { get; set; }
    public List<string> Roles { get; set; } = [];
    public bool HasAcknowledged { get; set; }
}

public class PartnerRole
{
    public int Id { get; set; }
    public int PartnerId { get; set; }
    public string RoleCode { get; set; } = "";
}

public class PartnerAgreement
{
    public int Id { get; set; }
    public int PartnerId { get; set; }
    public string? ContributionTerms { get; set; }
    public string? IncentiveTerms { get; set; }
    public string? RiskAcceptance { get; set; }
    public DateTime? AcknowledgedAt { get; set; }
    public int? AcknowledgedByUserId { get; set; }
    public string? SignatureText { get; set; }
    public DateTime CreatedAt { get; set; }
}
