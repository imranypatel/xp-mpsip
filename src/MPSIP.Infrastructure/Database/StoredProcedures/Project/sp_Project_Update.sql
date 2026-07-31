CREATE OR ALTER PROCEDURE dbo.sp_Project_Update
    @Id             INT,
    @Name           NVARCHAR(200),
    @Description    NVARCHAR(2000) = NULL,
    @StartDate      DATE,
    @ExpectedEndDate DATE,
    @RiskDeclaration NVARCHAR(2000) = NULL,
    @Contingency    NVARCHAR(2000) = NULL,
    @ModifiedBy     INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Project
    SET Name = @Name, Description = @Description,
        StartDate = @StartDate, ExpectedEndDate = @ExpectedEndDate,
        RiskDeclaration = @RiskDeclaration, Contingency = @Contingency,
        ModifiedAt = GETUTCDATE(), ModifiedBy = @ModifiedBy
    WHERE Id = @Id AND IsDeleted = 0;
END

