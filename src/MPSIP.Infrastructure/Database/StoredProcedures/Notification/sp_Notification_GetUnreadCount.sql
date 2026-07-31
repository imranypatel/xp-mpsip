CREATE OR ALTER PROCEDURE dbo.sp_Notification_GetUnreadCount
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS UnreadCount FROM dbo.Notification WHERE UserId = @UserId AND IsRead = 0;
END

