CREATE OR ALTER PROCEDURE dbo.sp_Auth_CreateInvitation
    @ProjectId INT,
    @Email     NVARCHAR(256),
    @ExpiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.InvitationToken (ProjectId, Email, ExpiresAt)
    VALUES (@ProjectId, @Email, @ExpiresAt);
    SELECT SCOPE_IDENTITY() AS Id;
END

