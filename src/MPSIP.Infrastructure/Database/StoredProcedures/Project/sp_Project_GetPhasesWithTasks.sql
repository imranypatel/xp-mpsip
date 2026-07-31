-- sp_Project_GetPhasesWithTasks — returns phases with tasks for multi-mapping
-- Splits on second Id column (ProjectTask.Id)
CREATE OR ALTER PROCEDURE dbo.sp_Project_GetPhasesWithTasks
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ph.Id, ph.ProjectId, ph.SortOrder, ph.Name, ph.StatusCode, ph.StartedAt, ph.CompletedAt,
        -- ProjectTask columns (splitOn: Id)
        pt.Id, pt.ProjectPhaseId, pt.Name AS TaskName, pt.ResourceType,
        pt.StatusCode AS TaskStatusCode, pt.SortOrder AS TaskSortOrder,
        pt.AssignedToUserId, u.DisplayName AS AssignedToName, pt.DueDate, pt.CompletedAt AS TaskCompletedAt
    FROM dbo.ProjectPhase ph
    LEFT JOIN dbo.ProjectTask pt ON pt.ProjectPhaseId = ph.Id AND pt.IsDeleted = 0
    LEFT JOIN dbo.AppUser u ON u.Id = pt.AssignedToUserId
    WHERE ph.ProjectId = @ProjectId
    ORDER BY ph.SortOrder, pt.SortOrder;
END
