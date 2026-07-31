CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_GetPartner
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Summary
    SELECT
        ISNULL(SUM(c.MonetaryValue), 0) AS TotalContributed,
        ISNULL((SELECT SUM(ds.Amount) FROM dbo.DistributionShare ds
                INNER JOIN dbo.Partner p2 ON p2.Id = ds.PartnerId
                WHERE p2.UserId = @UserId AND ds.AcknowledgedAt IS NOT NULL), 0) AS TotalReceived
    FROM dbo.Contribution c
    WHERE c.ContributorId = @UserId AND c.IsDeleted = 0;

    -- Projects
    SELECT p.Id AS PartnerId, proj.Name AS ProjectName, proj.StatusCode,
           p.StakePct,
           ISNULL((SELECT SUM(c2.MonetaryValue) FROM dbo.Contribution c2
                   WHERE c2.ContributorId = @UserId AND c2.ProjectId = p.ProjectId AND c2.IsDeleted = 0), 0) AS MyContributions
    FROM dbo.Partner p
    INNER JOIN dbo.Project proj ON proj.Id = p.ProjectId
    WHERE p.UserId = @UserId AND p.IsDeleted = 0
    ORDER BY proj.CreatedAt DESC;
END

