CREATE OR ALTER PROCEDURE dbo.sp_Contribution_ListByUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.*, u.DisplayName AS ContributorName, pt.Name AS TaskName
    FROM dbo.Contribution c
    INNER JOIN dbo.AppUser u ON u.Id = c.ContributorId
    LEFT JOIN dbo.ProjectTask pt ON pt.Id = c.ProjectTaskId
    WHERE c.ContributorId = @UserId AND c.IsDeleted = 0
    ORDER BY c.ContributionDate DESC;
END

