CREATE OR ALTER PROCEDURE dbo.sp_Task_ListByProject
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ph.Id AS PhaseId, ph.ProjectId, ph.SortOrder AS PhaseSortOrder,
           ph.Name AS PhaseName, ph.StatusCode AS PhaseStatusCode,
           ph.StartedAt, ph.CompletedAt,
           pt.Id AS TaskId, pt.Name AS TaskName, pt.ResourceType,
           pt.StatusCode AS TaskStatusCode, pt.SortOrder AS TaskSortOrder,
           pt.AssignedToUserId, u.DisplayName AS AssignedToName, pt.DueDate
    FROM dbo.ProjectPhase ph
    LEFT JOIN dbo.ProjectTask pt ON pt.ProjectPhaseId = ph.Id AND pt.IsDeleted = 0
    LEFT JOIN dbo.AppUser u ON u.Id = pt.AssignedToUserId
    WHERE ph.ProjectId = @ProjectId
    ORDER BY ph.SortOrder, pt.SortOrder;
END

