CREATE OR ALTER PROCEDURE dbo.sp_Notification_Create
    @UserId    INT,
    @ProjectId INT = NULL,
    @TypeCode  NVARCHAR(50),
    @Title     NVARCHAR(200),
    @Body      NVARCHAR(1000)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Notification (UserId, ProjectId, TypeCode, Title, Body)
    VALUES (@UserId, @ProjectId, @TypeCode, @Title, @Body);
    SELECT SCOPE_IDENTITY() AS Id;
END

