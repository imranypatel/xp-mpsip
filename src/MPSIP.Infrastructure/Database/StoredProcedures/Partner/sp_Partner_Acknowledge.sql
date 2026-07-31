CREATE OR ALTER PROCEDURE dbo.sp_Partner_Acknowledge
    @PartnerId           INT,
    @AcknowledgedByUserId INT,
    @SignatureText        NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.PartnerAgreement
    SET AcknowledgedAt = GETUTCDATE(),
        AcknowledgedByUserId = @AcknowledgedByUserId,
        SignatureText = @SignatureText
    WHERE PartnerId = @PartnerId;

    UPDATE dbo.Partner
    SET StatusCode = 'Active', JoinedAt = GETUTCDATE()
    WHERE Id = @PartnerId AND StatusCode = 'Invited';
END

