CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_GetOwner
    @OwnerId INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Summary row
    SELECT
        COUNT(*) AS TotalProjects,
        SUM(CASE WHEN StatusCode = 'Active' THEN 1 ELSE 0 END) AS ActiveProjects,
        ISNULL((SELECT SUM(ds.Amount)
                FROM dbo.DistributionShare ds
                INNER JOIN dbo.Partner p ON p.Id = ds.PartnerId
                INNER JOIN dbo.Project proj ON proj.Id = p.ProjectId
                WHERE proj.OwnerId = @OwnerId AND ds.AcknowledgedAt IS NULL), 0) AS PendingDistributions
    FROM dbo.Project
    WHERE OwnerId = @OwnerId AND IsDeleted = 0;

    -- Projects list
    SELECT p.Id, p.Name, p.StatusCode,
           ok.Name AS OpportunityKindName,
           (SELECT COUNT(*) FROM dbo.ProjectPhase ph WHERE ph.ProjectId = p.Id) AS PhaseCount,
           (SELECT COUNT(*) FROM dbo.ProjectPhase ph WHERE ph.ProjectId = p.Id AND ph.StatusCode = 'Completed') AS CompletedPhaseCount,
           (SELECT COUNT(*) FROM dbo.Partner pt WHERE pt.ProjectId = p.Id AND pt.IsDeleted = 0) AS PartnerCount
    FROM dbo.Project p
    INNER JOIN dbo.OpportunityKind ok ON ok.Id = p.OpportunityKindId
    WHERE p.OwnerId = @OwnerId AND p.IsDeleted = 0
    ORDER BY p.CreatedAt DESC;
END

