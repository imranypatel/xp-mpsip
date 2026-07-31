namespace MPSIP.Domain.Entities;

public class Contribution
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public int? ProjectTaskId { get; set; }
    public int ContributorId { get; set; }
    public string ResourceType { get; set; } = "";  // Man | Material | Money
    public string Description { get; set; } = "";
    public decimal Quantity { get; set; }
    public string? Unit { get; set; }
    public decimal? MonetaryValue { get; set; }
    public DateOnly ContributionDate { get; set; }
    public bool IsDeleted { get; set; } = false;
    public DateTime CreatedAt { get; set; }
    public int CreatedBy { get; set; }

    // Navigation
    public string? ContributorName { get; set; }
    public string? TaskName { get; set; }
}
