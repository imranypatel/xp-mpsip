CREATE OR ALTER PROCEDURE dbo.sp_Closure_Initiate
    @ProjectId       INT,
    @ClosureNotes    NVARCHAR(2000) = NULL,
    @FinalDistEventId INT = NULL,
    @InitiatedBy     INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.ProjectClosure WHERE ProjectId = @ProjectId)
    BEGIN
        SELECT Id FROM dbo.ProjectClosure WHERE ProjectId = @ProjectId;
        RETURN;
    END
    INSERT INTO dbo.ProjectClosure (ProjectId, ClosureNotes, FinalDistEventId, InitiatedBy)
    VALUES (@ProjectId, @ClosureNotes, @FinalDistEventId, @InitiatedBy);
    SELECT SCOPE_IDENTITY() AS Id;
END

