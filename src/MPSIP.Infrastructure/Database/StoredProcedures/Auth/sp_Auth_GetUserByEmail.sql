CREATE OR ALTER PROCEDURE dbo.sp_Auth_GetUserByEmail
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Email, PasswordHash, Salt, DisplayName, IsActive, IsDeleted
    FROM dbo.AppUser
    WHERE Email = @Email AND IsDeleted = 0;
END

