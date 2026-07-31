CREATE OR ALTER PROCEDURE dbo.sp_Distribution_UpdateStatus
    @EventId    INT,
    @StatusCode NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.DistributionEvent SET StatusCode = @StatusCode WHERE Id = @EventId;
END

