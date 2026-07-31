CREATE OR ALTER PROCEDURE dbo.sp_Auth_CreateUser
    @Email        NVARCHAR(256),
    @PasswordHash NVARCHAR(512),
    @Salt         NVARCHAR(128),
    @DisplayName  NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.AppUser WHERE Email = @Email AND IsDeleted = 0)
    BEGIN
        SELECT -1 AS Id; -- already exists
        RETURN;
    END
    INSERT INTO dbo.AppUser (Email, PasswordHash, Salt, DisplayName)
    VALUES (@Email, @PasswordHash, @Salt, @DisplayName);
    SELECT SCOPE_IDENTITY() AS Id;
END

