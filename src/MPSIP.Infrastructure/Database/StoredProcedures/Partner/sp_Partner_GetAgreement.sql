CREATE OR ALTER PROCEDURE dbo.sp_Partner_GetAgreement
    @PartnerId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, PartnerId, ContributionTerms, IncentiveTerms, RiskAcceptance,
           AcknowledgedAt, AcknowledgedByUserId, SignatureText, CreatedAt
    FROM dbo.PartnerAgreement
    WHERE PartnerId = @PartnerId;
END

