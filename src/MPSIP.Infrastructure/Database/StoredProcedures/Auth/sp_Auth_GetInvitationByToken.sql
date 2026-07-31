CREATE OR ALTER PROCEDURE dbo.sp_Auth_GetInvitationByToken
    @Token UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Token, ProjectId, Email, ExpiresAt, UsedAt,
           CASE WHEN UsedAt IS NULL AND ExpiresAt > GETUTCDATE() THEN 1 ELSE 0 END AS IsValid
    FROM dbo.InvitationToken
    WHERE Token = @Token;
END

