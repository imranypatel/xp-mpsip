CREATE OR ALTER PROCEDURE dbo.sp_Auth_GetUserById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id, Email, DisplayName, IsActive, IsDeleted
    FROM dbo.AppUser
    WHERE Id = @Id AND IsDeleted = 0;
END

