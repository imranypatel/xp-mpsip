CREATE OR ALTER PROCEDURE dbo.sp_Distribution_CreateEvent
    @ProjectId   INT,
    @Name        NVARCHAR(200),
    @TotalAmount DECIMAL(18,2),
    @EventDate   DATE,
    @Notes       NVARCHAR(1000) = NULL,
    @CreatedBy   INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DistributionEvent (ProjectId, Name, TotalAmount, EventDate, Notes, CreatedBy)
    VALUES (@ProjectId, @Name, @TotalAmount, @EventDate, @Notes, @CreatedBy);
    SELECT SCOPE_IDENTITY() AS Id;
END

