CREATE OR ALTER PROCEDURE dbo.sp_Task_AssignUser
    @TaskId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ProjectTask SET AssignedToUserId = @UserId WHERE Id = @TaskId;
END

