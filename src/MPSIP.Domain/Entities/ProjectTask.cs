namespace MPSIP.Domain.Entities;

public class ProjectPhase
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public int? TemplatePhaseId { get; set; }
    public int SortOrder { get; set; }
    public string Name { get; set; } = "";
    public string StatusCode { get; set; } = "NotStarted";
    public DateTime? StartedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public List<ProjectTask> Tasks { get; set; } = [];
}

public class ProjectTask
{
    public int Id { get; set; }
    public int ProjectPhaseId { get; set; }
    public int? TemplateTaskId { get; set; }
    public int SortOrder { get; set; }
    public string Name { get; set; } = "";
    public string? Description { get; set; }
    public string ResourceType { get; set; } = "Man";
    public int? AssignedToUserId { get; set; }
    public string StatusCode { get; set; } = "NotStarted";
    public DateOnly? DueDate { get; set; }
    public DateTime? CompletedAt { get; set; }
    public bool IsDeleted { get; set; } = false;
    public DateTime CreatedAt { get; set; }
    public int CreatedBy { get; set; }

    // Navigation
    public string? AssignedToName { get; set; }
}
