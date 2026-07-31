CREATE OR ALTER PROCEDURE dbo.sp_Task_Create
    @ProjectPhaseId INT,
    @Name           NVARCHAR(200),
    @Description    NVARCHAR(1000) = NULL,
    @ResourceType   NVARCHAR(20),
    @SortOrder      INT = 999,
    @CreatedBy      INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.ProjectTask (ProjectPhaseId, SortOrder, Name, Description, ResourceType, CreatedBy)
    VALUES (@ProjectPhaseId, @SortOrder, @Name, @Description, @ResourceType, @CreatedBy);
    SELECT SCOPE_IDENTITY() AS Id;
END

