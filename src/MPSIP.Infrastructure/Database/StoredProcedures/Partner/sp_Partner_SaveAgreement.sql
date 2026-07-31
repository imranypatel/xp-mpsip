CREATE OR ALTER PROCEDURE dbo.sp_Partner_SaveAgreement
    @PartnerId         INT,
    @ContributionTerms NVARCHAR(2000) = NULL,
    @IncentiveTerms    NVARCHAR(2000) = NULL,
    @RiskAcceptance    NVARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.PartnerAgreement WHERE PartnerId = @PartnerId)
        UPDATE dbo.PartnerAgreement
        SET ContributionTerms = @ContributionTerms,
            IncentiveTerms = @IncentiveTerms,
            RiskAcceptance = @RiskAcceptance
        WHERE PartnerId = @PartnerId;
    ELSE
        INSERT INTO dbo.PartnerAgreement (PartnerId, ContributionTerms, IncentiveTerms, RiskAcceptance)
        VALUES (@PartnerId, @ContributionTerms, @IncentiveTerms, @RiskAcceptance);
END

