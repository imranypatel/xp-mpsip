CREATE OR ALTER PROCEDURE dbo.sp_Closure_Complete
    @ClosureId   INT,
    @CompletedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectClosure SET CompletedAt = GETUTCDATE() WHERE Id = @ClosureId;

    UPDATE dbo.Project SET StatusCode = 'Closed', ModifiedAt = GETUTCDATE(), ModifiedBy = @CompletedBy
    WHERE Id = (SELECT ProjectId FROM dbo.ProjectClosure WHERE Id = @ClosureId);
END

