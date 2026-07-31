namespace MPSIP.Domain.Entities;

public class InvitationToken
{
    public int Id { get; set; }
    public Guid Token { get; set; }
    public int ProjectId { get; set; }
    public string Email { get; set; } = "";
    public DateTime ExpiresAt { get; set; }
    public DateTime? UsedAt { get; set; }

    public bool IsExpired => DateTime.UtcNow > ExpiresAt;
    public bool IsUsed => UsedAt.HasValue;
    public bool IsValid => !IsExpired && !IsUsed;
}
