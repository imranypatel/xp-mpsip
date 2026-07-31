CREATE OR ALTER PROCEDURE dbo.sp_Project_UpdateStatus
    @Id         INT,
    @StatusCode NVARCHAR(30),
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Project
    SET StatusCode = @StatusCode, ModifiedAt = GETUTCDATE(), ModifiedBy = @ModifiedBy
    WHERE Id = @Id;
END

