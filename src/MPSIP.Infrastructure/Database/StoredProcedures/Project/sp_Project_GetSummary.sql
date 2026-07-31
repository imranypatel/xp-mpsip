CREATE OR ALTER PROCEDURE dbo.sp_Project_GetSummary
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.Id, p.Name, p.StatusCode, ok.Name AS OpportunityKindName,
        (SELECT COUNT(*) FROM dbo.ProjectPhase ph WHERE ph.ProjectId = p.Id) AS PhaseCount,
        (SELECT COUNT(*) FROM dbo.ProjectPhase ph WHERE ph.ProjectId = p.Id AND ph.StatusCode = 'Completed') AS CompletedPhaseCount,
        (SELECT COUNT(*) FROM dbo.Partner pt WHERE pt.ProjectId = p.Id AND pt.IsDeleted = 0) AS PartnerCount,
        ISNULL((SELECT SUM(c.MonetaryValue) FROM dbo.Contribution c WHERE c.ProjectId = p.Id AND c.IsDeleted = 0), 0) AS TotalContributions,
        ISNULL((SELECT SUM(ds.Amount) FROM dbo.DistributionShare ds
                INNER JOIN dbo.Partner pp ON pp.Id = ds.PartnerId
                WHERE pp.ProjectId = p.Id AND ds.AcknowledgedAt IS NULL), 0) AS PendingDistributions,
        p.StartDate, p.ExpectedEndDate
    FROM dbo.Project p
    INNER JOIN dbo.OpportunityKind ok ON ok.Id = p.OpportunityKindId
    WHERE p.Id = @ProjectId AND p.IsDeleted = 0;
END
