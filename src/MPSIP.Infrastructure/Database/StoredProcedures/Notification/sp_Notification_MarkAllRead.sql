CREATE OR ALTER PROCEDURE dbo.sp_Notification_MarkAllRead
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Notification SET IsRead = 1 WHERE UserId = @UserId AND IsRead = 0;
END

