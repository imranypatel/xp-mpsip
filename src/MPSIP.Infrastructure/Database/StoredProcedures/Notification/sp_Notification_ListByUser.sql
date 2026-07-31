CREATE OR ALTER PROCEDURE dbo.sp_Notification_ListByUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 50 Id, UserId, ProjectId, TypeCode, Title, Body, IsRead, CreatedAt
    FROM dbo.Notification
    WHERE UserId = @UserId
    ORDER BY CreatedAt DESC;
END

