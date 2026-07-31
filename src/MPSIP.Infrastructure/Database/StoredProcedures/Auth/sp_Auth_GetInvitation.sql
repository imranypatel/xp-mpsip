-- Alias: sp_Auth_GetInvitation — repository uses this name
CREATE OR ALTER PROCEDURE dbo.sp_Auth_GetInvitation
    @Token UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    SELECT it.Id, it.Token, it.ProjectId, it.Email, it.ExpiresAt, it.UsedAt,
           CASE WHEN it.UsedAt IS NULL AND it.ExpiresAt > GETUTCDATE() THEN 1 ELSE 0 END AS IsValid,
           p.Name AS ProjectName
    FROM dbo.InvitationToken it
    LEFT JOIN dbo.Project p ON p.Id = it.ProjectId
    WHERE it.Token = @Token;
END
