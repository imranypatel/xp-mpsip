namespace MPSIP.Domain.Entities;

public class ProjectClosure
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public string? ClosureNotes { get; set; }
    public int? FinalDistEventId { get; set; }
    public DateTime InitiatedAt { get; set; }
    public int InitiatedBy { get; set; }
    public DateTime? CompletedAt { get; set; }

    public List<PartnerFeedback> Feedback { get; set; } = [];
}

public class PartnerFeedback
{
    public int Id { get; set; }
    public int ClosureId { get; set; }
    public int PartnerId { get; set; }
    public byte? Rating { get; set; }
    public string? Comments { get; set; }
    public DateTime? SubmittedAt { get; set; }

    // Navigation
    public string? PartnerName { get; set; }
}
