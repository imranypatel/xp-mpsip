CREATE OR ALTER PROCEDURE dbo.sp_Project_ListByOwner
    @OwnerId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.*, ok.Name AS OpportunityKindName,
        (SELECT COUNT(*) FROM dbo.ProjectPhase ph WHERE ph.ProjectId = p.Id) AS PhaseCount,
        (SELECT COUNT(*) FROM dbo.ProjectPhase ph WHERE ph.ProjectId = p.Id AND ph.StatusCode = 'Completed') AS CompletedPhaseCount,
        (SELECT COUNT(*) FROM dbo.Partner pt WHERE pt.ProjectId = p.Id AND pt.IsDeleted = 0) AS PartnerCount
    FROM dbo.Project p
    INNER JOIN dbo.OpportunityKind ok ON ok.Id = p.OpportunityKindId
    WHERE p.OwnerId = @OwnerId AND p.IsDeleted = 0
    ORDER BY p.CreatedAt DESC;
END

