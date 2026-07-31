CREATE OR ALTER PROCEDURE dbo.sp_Task_UpdateStatus
    @TaskId     INT,
    @StatusCode NVARCHAR(30),
    @UpdatedBy  INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectTask
    SET StatusCode = @StatusCode,
        CompletedAt = CASE WHEN @StatusCode = 'Completed' THEN GETUTCDATE() ELSE NULL END
    WHERE Id = @TaskId;

    -- Auto-progress phase if all tasks completed
    DECLARE @PhaseId INT;
    SELECT @PhaseId = ProjectPhaseId FROM dbo.ProjectTask WHERE Id = @TaskId;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.ProjectTask
        WHERE ProjectPhaseId = @PhaseId AND StatusCode <> 'Completed' AND IsDeleted = 0
    )
    BEGIN
        UPDATE dbo.ProjectPhase SET StatusCode = 'Completed', CompletedAt = GETUTCDATE()
        WHERE Id = @PhaseId AND StatusCode <> 'Completed';
    END
END

