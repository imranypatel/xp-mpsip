namespace MPSIP.Domain.Entities;

public class DistributionEvent
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public string Name { get; set; } = "";
    public decimal TotalAmount { get; set; }
    public DateOnly EventDate { get; set; }
    public string? Notes { get; set; }
    public string StatusCode { get; set; } = "Pending";
    public DateTime CreatedAt { get; set; }
    public int CreatedBy { get; set; }

    public List<DistributionShare> Shares { get; set; } = [];
}

public class DistributionShare
{
    public int Id { get; set; }
    public int DistributionEventId { get; set; }
    public int PartnerId { get; set; }
    public decimal SharePct { get; set; }
    public decimal Amount { get; set; }
    public DateTime? AcknowledgedAt { get; set; }
    public int? AcknowledgedByUserId { get; set; }

    // Navigation
    public string? PartnerName { get; set; }
}
