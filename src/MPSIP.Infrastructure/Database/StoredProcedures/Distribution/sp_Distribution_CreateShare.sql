-- sp_Distribution_CreateShare — insert a single distribution share
CREATE OR ALTER PROCEDURE dbo.sp_Distribution_CreateShare
    @DistributionEventId INT,
    @PartnerId           INT,
    @SharePct            DECIMAL(5,2),
    @Amount              DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.DistributionShare (DistributionEventId, PartnerId, SharePct, Amount)
    VALUES (@DistributionEventId, @PartnerId, @SharePct, @Amount);
    SELECT SCOPE_IDENTITY() AS Id;
END
