using System.Data;
using Dapper;
using MPSIP.Application.DTOs;
using MPSIP.Application.Interfaces;
using MPSIP.Domain.Entities;

namespace MPSIP.Infrastructure.Repositories;

public class PartnerRepository(IDbConnectionFactory factory) : IPartnerRepository
{
    public async Task<int> CreateAsync(int projectId, int userId, decimal stakePct, int createdBy)
    {
        using var conn = factory.Create();
        return await conn.ExecuteScalarAsync<int>("sp_Partner_Create",
            new { ProjectId = projectId, UserId = userId, StakePct = stakePct, CreatedBy = createdBy },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<Partner>> GetByProjectAsync(int projectId)
    {
        using var conn = factory.Create();
        var partnerDict = new Dictionary<int, Partner>();
        await conn.QueryAsync<Partner, PartnerRole, Partner>(
            "sp_Partner_GetByProject",
            (partner, role) =>
            {
                if (!partnerDict.TryGetValue(partner.Id, out var existing))
                {
                    existing = partner;
                    partnerDict[partner.Id] = existing;
                }
                if (role != null) existing.Roles.Add(role.RoleCode);
                return existing;
            },
            new { ProjectId = projectId },
            splitOn: "Id",
            commandType: CommandType.StoredProcedure);
        return partnerDict.Values;
    }

    public async Task<IEnumerable<Partner>> GetByUserAsync(int userId)
    {
        using var conn = factory.Create();
        return await conn.QueryAsync<Partner>("sp_Partner_GetByUser",
            new { UserId = userId }, commandType: CommandType.StoredProcedure);
    }

    public async Task UpdateStakeAsync(int partnerId, decimal stakePct)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Partner_UpdateStake",
            new { PartnerId = partnerId, StakePct = stakePct }, commandType: CommandType.StoredProcedure);
    }

    public async Task SaveAgreementAsync(int partnerId, string? contributionTerms, string? incentiveTerms, string? riskAcceptance)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Partner_SaveAgreement",
            new { PartnerId = partnerId, ContributionTerms = contributionTerms, IncentiveTerms = incentiveTerms, RiskAcceptance = riskAcceptance },
            commandType: CommandType.StoredProcedure);
    }

    public async Task AcknowledgeAsync(AcknowledgeAgreementCommand cmd)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Partner_Acknowledge",
            new { cmd.PartnerId, AcknowledgedByUserId = cmd.UserId, cmd.SignatureText },
            commandType: CommandType.StoredProcedure);
    }

    public async Task AssignRoleAsync(int partnerId, string roleCode)
    {
        using var conn = factory.Create();
        await conn.ExecuteAsync("sp_Partner_AssignRole",
            new { PartnerId = partnerId, RoleCode = roleCode }, commandType: CommandType.StoredProcedure);
    }

    public async Task<Partner?> GetByIdAsync(int id)
    {
        using var conn = factory.Create();
        return await conn.QuerySingleOrDefaultAsync<Partner>(
            "sp_Partner_GetById", new { Id = id }, commandType: CommandType.StoredProcedure);
    }

    public async Task<Partner?> GetByProjectAndUserAsync(int projectId, int userId)
    {
        using var conn = factory.Create();
        return await conn.QuerySingleOrDefaultAsync<Partner>(
            "sp_Partner_GetByProjectAndUser",
            new { ProjectId = projectId, UserId = userId },
            commandType: CommandType.StoredProcedure);
    }

    public async Task<PartnerAgreement?> GetAgreementAsync(int partnerId)
    {
        using var conn = factory.Create();
        return await conn.QuerySingleOrDefaultAsync<PartnerAgreement>(
            "sp_Partner_GetAgreement", new { PartnerId = partnerId },
            commandType: CommandType.StoredProcedure);
    }
}
