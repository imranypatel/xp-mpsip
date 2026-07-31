CREATE OR ALTER PROCEDURE dbo.sp_Contribution_Delete
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Contribution SET IsDeleted = 1 WHERE Id = @Id;
END

