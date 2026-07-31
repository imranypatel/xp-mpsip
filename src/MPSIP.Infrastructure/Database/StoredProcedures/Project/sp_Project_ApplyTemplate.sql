CREATE OR ALTER PROCEDURE dbo.sp_Project_ApplyTemplate
    @ProjectId  INT,
    @TemplateId INT,
    @CreatedBy  INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PhaseMap TABLE (TemplatePhaseId INT, NewPhaseId INT);

    INSERT INTO dbo.ProjectPhase (ProjectId, TemplatePhaseId, SortOrder, Name)
    OUTPUT inserted.TemplatePhaseId, inserted.Id INTO @PhaseMap
    SELECT @ProjectId, tp.Id, tp.SortOrder, tp.Name
    FROM dbo.TemplatePhase tp
    WHERE tp.TemplateId = @TemplateId
    ORDER BY tp.SortOrder;

    INSERT INTO dbo.ProjectTask (ProjectPhaseId, TemplateTaskId, SortOrder, Name, ResourceType, CreatedBy)
    SELECT pm.NewPhaseId, tt.Id, tt.SortOrder, tt.Name, tt.ResourceType, @CreatedBy
    FROM dbo.TemplateTask tt
    INNER JOIN @PhaseMap pm ON pm.TemplatePhaseId = tt.TemplatePhaseId;
END

