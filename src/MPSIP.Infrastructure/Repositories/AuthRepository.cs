using System.Data;
using Dapper;
using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Infrastructure.Repositories;

public class AuthRepository(IDbConnectionFactory factory) : IAuthRepository
{
    public async Task<(AuthUserDto? User, string? PasswordHash, string? Salt)> GetUserForLoginAsync(string email)
    {
        using var conn = factory.Create();
        var row = await conn.QuerySingleOrDefaultAsync(
            "sp_Auth_GetUserByEmail",
            new { Email = email },
            commandType: CommandType.StoredProcedure);
        if (row == null) return (null, null, null);
        var user = new AuthUserDto((int)row.Id, (string)row.Email, (string)row.DisplayName, (bool)row.IsActive);
        return (user, (string)row.PasswordHash, (string)row.Salt);
    }

    public async Task<int> CreateUserAsync(RegisterDto dto, string passwordHash, string salt)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>(
            "sp_Auth_CreateUser",
            new { dto.Email, PasswordHash = passwordHash, Salt = salt, dto.DisplayName },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<InvitationInfoDto?> GetInvitationAsync(Guid token)
    {
        using var conn = factory.Create();
        var row = await conn.QuerySingleOrDefaultAsync(
            "sp_Auth_GetInvitation",
            new { Token = token },
            commandType: CommandType.StoredProcedure);
        if (row == null) return null;
        bool isValid = (DateTime)row.ExpiresAt > DateTime.UtcNow && row.UsedAt == null;
        return new InvitationInfoDto((Guid)row.Token, (int)row.ProjectId, (string)row.Email, isValid, (string?)row.ProjectName);
    }

    public async Task<bool> RedeemInvitationAsync(Guid token, int userId)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync(
            "sp_Auth_RedeemInvitation",
            new { Token = token, UserId = userId },
            commandType: CommandType.StoredProcedure);
        return true;
    }

    public async Task<int> CreateInvitationAsync(int projectId, string email, DateTime expiresAt)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>(
            "sp_Auth_CreateInvitation",
            new { ProjectId = projectId, Email = email, ExpiresAt = expiresAt },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<AuthUserDto?> GetUserByIdAsync(int id)
    {
        using var conn = factory.Create();
        var row = await conn.QuerySingleOrDefaultAsync(
            "sp_Auth_GetUserById",
            new { Id = id },
            commandType: CommandType.StoredProcedure);
        if (row == null) return null;
        return new AuthUserDto((int)row.Id, (string)row.Email, (string)row.DisplayName, (bool)row.IsActive);
    }
}
