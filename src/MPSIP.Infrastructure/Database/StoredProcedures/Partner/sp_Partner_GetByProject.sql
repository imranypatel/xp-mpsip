CREATE OR ALTER PROCEDURE dbo.sp_Partner_GetByProject
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.ProjectId, p.UserId, p.StakePct, p.JoinedAt, p.StatusCode, p.IsDeleted,
           p.CreatedAt, p.CreatedBy,
           u.DisplayName, u.Email,
           CASE WHEN pa.AcknowledgedAt IS NOT NULL THEN 1 ELSE 0 END AS HasAcknowledged,
           pr.RoleCode
    FROM dbo.Partner p
    INNER JOIN dbo.AppUser u ON u.Id = p.UserId
    LEFT JOIN dbo.PartnerAgreement pa ON pa.PartnerId = p.Id
    LEFT JOIN dbo.PartnerRole pr ON pr.PartnerId = p.Id
    WHERE p.ProjectId = @ProjectId AND p.IsDeleted = 0;
END

