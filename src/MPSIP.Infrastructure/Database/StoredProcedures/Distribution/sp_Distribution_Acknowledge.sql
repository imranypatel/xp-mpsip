CREATE OR ALTER PROCEDURE dbo.sp_Distribution_Acknowledge
    @DistributionShareId INT,
    @UserId              INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.DistributionShare
    SET AcknowledgedAt = GETUTCDATE(), AcknowledgedByUserId = @UserId
    WHERE Id = @DistributionShareId AND AcknowledgedAt IS NULL;
END

