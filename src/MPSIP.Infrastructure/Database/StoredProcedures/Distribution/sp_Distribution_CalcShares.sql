CREATE OR ALTER PROCEDURE dbo.sp_Distribution_CalcShares
    @DistributionEventId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TotalAmount DECIMAL(18,2);
    SELECT @TotalAmount = TotalAmount FROM dbo.DistributionEvent WHERE Id = @DistributionEventId;

    DELETE FROM dbo.DistributionShare WHERE DistributionEventId = @DistributionEventId;

    INSERT INTO dbo.DistributionShare (DistributionEventId, PartnerId, SharePct, Amount)
    SELECT @DistributionEventId, p.Id, p.StakePct,
           CAST(@TotalAmount * p.StakePct / 100.0 AS DECIMAL(18,2))
    FROM dbo.Partner p
    INNER JOIN dbo.DistributionEvent de ON de.ProjectId = p.ProjectId
    WHERE de.Id = @DistributionEventId AND p.IsDeleted = 0 AND p.StatusCode = 'Active';

    UPDATE dbo.DistributionEvent SET StatusCode = 'Distributed' WHERE Id = @DistributionEventId;
END

