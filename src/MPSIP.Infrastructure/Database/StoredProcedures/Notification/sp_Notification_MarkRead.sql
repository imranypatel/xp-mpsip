CREATE OR ALTER PROCEDURE dbo.sp_Notification_MarkRead
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Notification SET IsRead = 1 WHERE Id = @Id;
END

