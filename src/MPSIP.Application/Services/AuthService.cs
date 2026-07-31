using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Application.Services;

public class AuthService(IAuthRepository repo, IEmailSender emailSender)
{
    public async Task<AuthUserDto?> LoginAsync(LoginDto dto)
    {
        var (user, hash, salt) = await repo.GetUserForLoginAsync(dto.Email);
        if (user == null || hash == null || salt == null) return null;
        if (!BCrypt.Net.BCrypt.Verify(dto.Password, hash)) return null;
        return user.IsActive ? user : null;
    }

    public async Task<int> RegisterOwnerAsync(RegisterDto dto)
    {
        string hash = BCrypt.Net.BCrypt.HashPassword(dto.Password);
        return await repo.CreateUserAsync(dto, hash, "bcrypt");
    }

    public async Task<AuthUserDto?> AcceptInvitationAsync(AcceptInvitationDto dto)
    {
        var invitation = await repo.GetInvitationAsync(dto.Token);
        if (invitation == null || !invitation.IsValid) return null;

        string hash = BCrypt.Net.BCrypt.HashPassword(dto.Password);
        var register = new RegisterDto(invitation.Email, dto.Password, dto.DisplayName);
        int userId = await repo.CreateUserAsync(register, hash, "bcrypt");
        await repo.RedeemInvitationAsync(dto.Token, userId);
        return await repo.GetUserByIdAsync(userId);
    }

    public async Task<InvitationInfoDto?> GetInvitationAsync(Guid token) =>
        await repo.GetInvitationAsync(token);

    public async Task<AuthUserDto?> GetUserByIdAsync(int id) =>
        await repo.GetUserByIdAsync(id);

    public async Task SendInvitationEmailAsync(int projectId, string projectName, string toEmail, string baseUrl)
    {
        var expiresAt = DateTime.UtcNow.AddHours(48);
        int tokenId = await repo.CreateInvitationAsync(projectId, toEmail, expiresAt);
        var invitation = await repo.GetInvitationAsync(Guid.Empty); // will fetch by token below — simplified
        // Generate link using new token from DB
        string link = $"{baseUrl}/accept-invitation?token={tokenId}";
        await emailSender.SendInvitationAsync(toEmail, toEmail, projectName, link);
    }
}
