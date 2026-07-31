CREATE OR ALTER PROCEDURE dbo.sp_Partner_GetByUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Id, p.ProjectId, p.UserId, p.StakePct, p.JoinedAt, p.StatusCode,
           p.CreatedAt, p.CreatedBy,
           proj.Name AS ProjectName,
           CASE WHEN pa.AcknowledgedAt IS NOT NULL THEN 1 ELSE 0 END AS HasAcknowledged
    FROM dbo.Partner p
    INNER JOIN dbo.Project proj ON proj.Id = p.ProjectId
    LEFT JOIN dbo.PartnerAgreement pa ON pa.PartnerId = p.Id
    WHERE p.UserId = @UserId AND p.IsDeleted = 0;
END

