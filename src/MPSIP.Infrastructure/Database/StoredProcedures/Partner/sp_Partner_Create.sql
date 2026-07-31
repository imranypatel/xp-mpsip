CREATE OR ALTER PROCEDURE dbo.sp_Partner_Create
    @ProjectId INT,
    @UserId    INT,
    @StakePct  DECIMAL(5,2),
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Partner (ProjectId, UserId, StakePct, CreatedBy)
    VALUES (@ProjectId, @UserId, @StakePct, @CreatedBy);
    SELECT SCOPE_IDENTITY() AS Id;
END

