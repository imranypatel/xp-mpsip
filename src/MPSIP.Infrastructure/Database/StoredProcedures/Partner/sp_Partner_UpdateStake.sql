CREATE OR ALTER PROCEDURE dbo.sp_Partner_UpdateStake
    @PartnerId INT,
    @StakePct  DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Partner SET StakePct = @StakePct WHERE Id = @PartnerId;
END

