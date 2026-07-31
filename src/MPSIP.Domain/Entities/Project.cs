namespace MPSIP.Domain.Entities;

public class Project
{
    public int Id { get; set; }
    public int OwnerId { get; set; }
    public int OpportunityKindId { get; set; }
    public int? TemplateId { get; set; }
    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public DateOnly StartDate { get; set; }
    public DateOnly ExpectedEndDate { get; set; }
    public DateOnly? ActualEndDate { get; set; }
    public string? RiskDeclaration { get; set; }
    public string? Contingency { get; set; }
    public string StatusCode { get; set; } = "Active";
    public bool IsDeleted { get; set; } = false;
    public DateTime CreatedAt { get; set; }
    public int CreatedBy { get; set; }
    public DateTime? ModifiedAt { get; set; }
    public int? ModifiedBy { get; set; }

    // Navigation helpers (not DB columns)
    public string? OpportunityKindName { get; set; }
    public int PhaseCount { get; set; }
    public int CompletedPhaseCount { get; set; }
    public int PartnerCount { get; set; }
}
